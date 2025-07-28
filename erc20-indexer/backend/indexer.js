const { ethers } = require('ethers');
const Database = require('./database');

class ERC20Indexer {
  constructor(providerUrl, tokenAddress) {
    this.provider = new ethers.providers.JsonRpcProvider(providerUrl);
    this.tokenAddress = tokenAddress;
    this.database = new Database();
    
    // ERC20 Transfer事件的ABI
    this.transferEventAbi = [
      'event Transfer(address indexed from, address indexed to, uint256 value)'
    ];
    
    this.contract = new ethers.Contract(
      tokenAddress,
      this.transferEventAbi,
      this.provider
    );
  }

  async startIndexing() {
    console.log(`开始监听代币 ${this.tokenAddress} 的转账事件...`);
    
    // 监听新的Transfer事件
    this.contract.on('Transfer', async (from, to, value, event) => {
      try {
        const transfer = {
          transactionHash: event.transactionHash,
          blockNumber: event.blockNumber,
          from: from,
          to: to,
          value: value.toString(),
          tokenAddress: this.tokenAddress,
          timestamp: Date.now()
        };
        
        await this.database.insertTransfer(transfer);
        console.log(`新转账记录已保存: ${from} -> ${to}, 金额: ${ethers.utils.formatEther(value)} MTK`);
      } catch (error) {
        console.error('保存转账记录失败:', error);
      }
    });
  }

  async indexHistoricalTransfers(fromBlock = 0) {
    console.log('开始索引历史转账记录...');
    
    try {
      const filter = this.contract.filters.Transfer();
      const events = await this.contract.queryFilter(filter, fromBlock);
      
      for (const event of events) {
        const transfer = {
          transactionHash: event.transactionHash,
          blockNumber: event.blockNumber,
          from: event.args.from,
          to: event.args.to,
          value: event.args.value.toString(),
          tokenAddress: this.tokenAddress,
          timestamp: Date.now() - (events.length - events.indexOf(event)) * 1000 // 模拟时间戳
        };
        
        try {
          await this.database.insertTransfer(transfer);
          console.log(`历史转账记录已保存: ${transfer.from} -> ${transfer.to}`);
        } catch (error) {
          // 忽略重复记录错误
          if (!error.message.includes('UNIQUE constraint failed')) {
            console.error('保存历史转账记录失败:', error);
          }
        }
      }
      
      console.log(`历史转账记录索引完成，共处理 ${events.length} 条记录`);
    } catch (error) {
      console.error('索引历史转账记录失败:', error);
    }
  }

  getDatabase() {
    return this.database;
  }

  stop() {
    this.contract.removeAllListeners();
    this.database.close();
  }
}

module.exports = ERC20Indexer;