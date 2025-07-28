const express = require('express');
const cors = require('cors');
const path = require('path');
const ERC20Indexer = require('./indexer');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;

// 中间件
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, '../frontend')));

// 全局变量
let indexer = null;

// 初始化索引器
async function initializeIndexer() {
  const providerUrl = process.env.PROVIDER_URL || 'http://127.0.0.1:8545';
  const tokenAddress = process.env.TOKEN_ADDRESS;
  
  if (!tokenAddress) {
    console.log('等待代币地址配置...');
    return;
  }
  
  try {
    indexer = new ERC20Indexer(providerUrl, tokenAddress);
    await indexer.indexHistoricalTransfers();
    await indexer.startIndexing();
    console.log('ERC20索引器初始化成功');
  } catch (error) {
    console.error('初始化索引器失败:', error);
  }
}

// API路由

// 获取指定地址的转账记录
app.get('/api/transfers/:address', async (req, res) => {
  try {
    if (!indexer) {
      return res.status(503).json({ error: '索引器未初始化' });
    }
    
    const address = req.params.address;
    const transfers = await indexer.getDatabase().getTransfersByAddress(address);
    
    // 格式化返回数据
    const formattedTransfers = transfers.map(transfer => ({
      id: transfer.id,
      transactionHash: transfer.transaction_hash,
      blockNumber: transfer.block_number,
      from: transfer.from_address,
      to: transfer.to_address,
      value: transfer.value,
      tokenAddress: transfer.token_address,
      timestamp: transfer.timestamp,
      type: transfer.from_address.toLowerCase() === address.toLowerCase() ? 'sent' : 'received'
    }));
    
    res.json({
      success: true,
      address: address,
      transfers: formattedTransfers,
      count: formattedTransfers.length
    });
  } catch (error) {
    console.error('获取转账记录失败:', error);
    res.status(500).json({ error: '获取转账记录失败' });
  }
});

// 获取所有转账记录
app.get('/api/transfers', async (req, res) => {
  try {
    if (!indexer) {
      return res.status(503).json({ error: '索引器未初始化' });
    }
    
    const transfers = await indexer.getDatabase().getAllTransfers();
    
    const formattedTransfers = transfers.map(transfer => ({
      id: transfer.id,
      transactionHash: transfer.transaction_hash,
      blockNumber: transfer.block_number,
      from: transfer.from_address,
      to: transfer.to_address,
      value: transfer.value,
      tokenAddress: transfer.token_address,
      timestamp: transfer.timestamp
    }));
    
    res.json({
      success: true,
      transfers: formattedTransfers,
      count: formattedTransfers.length
    });
  } catch (error) {
    console.error('获取所有转账记录失败:', error);
    res.status(500).json({ error: '获取转账记录失败' });
  }
});

// 设置代币地址并初始化索引器
app.post('/api/setup', async (req, res) => {
  try {
    const { tokenAddress } = req.body;
    
    if (!tokenAddress) {
      return res.status(400).json({ error: '代币地址不能为空' });
    }
    
    // 停止现有索引器
    if (indexer) {
      indexer.stop();
    }
    
    // 设置环境变量
    process.env.TOKEN_ADDRESS = tokenAddress;
    
    // 重新初始化索引器
    await initializeIndexer();
    
    res.json({ success: true, message: '索引器设置成功', tokenAddress });
  } catch (error) {
    console.error('设置索引器失败:', error);
    res.status(500).json({ error: '设置索引器失败' });
  }
});

// 健康检查
app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    status: 'running',
    indexer: indexer ? 'initialized' : 'not initialized',
    tokenAddress: process.env.TOKEN_ADDRESS || null
  });
});

// 提供前端页面
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, '../frontend/index.html'));
});

// 启动服务器
app.listen(PORT, () => {
  console.log(`服务器运行在 http://localhost:${PORT}`);
  
  // 如果有代币地址配置，自动初始化索引器
  if (process.env.TOKEN_ADDRESS) {
    initializeIndexer();
  }
});

// 优雅关闭
process.on('SIGINT', () => {
  console.log('\n正在关闭服务器...');
  if (indexer) {
    indexer.stop();
  }
  process.exit(0);
});