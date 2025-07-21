import { useState, useEffect } from 'react';
import { ethers } from 'ethers';
import tokenAbi from './abi/MyToken.json';
import bankAbi from './abi/TokenBank.json';

const tokenAddress = import.meta.env.VITE_TOKEN_ADDRESS;
const bankAddress = import.meta.env.VITE_BANK_ADDRESS;

function App() {
  const [provider, setProvider] = useState(null);
  const [signer, setSigner] = useState(null);
  const [account, setAccount] = useState('');
  const [token, setToken] = useState(null);
  const [bank, setBank] = useState(null);
  const [tokenBalance, setTokenBalance] = useState('0');
  const [depositAmount, setDepositAmount] = useState('0');
  const [withdrawAmount, setWithdrawAmount] = useState('0');
  const [bankBalance, setBankBalance] = useState('0');

  async function connectWallet() {
    if (window.ethereum) {
      const prov = new ethers.BrowserProvider(window.ethereum);
      await window.ethereum.request({ method: 'eth_requestAccounts' });
      const signer = await prov.getSigner();
      const addr = await signer.getAddress();
      setProvider(prov);
      setSigner(signer);
      setAccount(addr);

      const token = new ethers.Contract(tokenAddress, tokenAbi.abi, signer);
      const bank = new ethers.Contract(bankAddress, bankAbi, signer);
      setToken(token);
      setBank(bank);
    }
  }

  async function fetchBalances() {
    if (token && bank && account) {
      const balance = await token.balanceOf(account);
      const deposited = await bank.balanceOf(account);
      setTokenBalance(ethers.formatUnits(balance, 18));
      setBankBalance(ethers.formatUnits(deposited, 18));
    }
  }

  useEffect(() => {
    fetchBalances();
  }, [token, bank, account]);

  async function handleDeposit() {
    const amount = ethers.parseUnits(depositAmount, 18);
    const tx1 = await token.approve(bankAddress, amount);
    await tx1.wait();
    const tx2 = await bank.deposit(amount);
    await tx2.wait();
    await fetchBalances();
  }

  async function handleWithdraw() {
    const amount = ethers.parseUnits(withdrawAmount, 18);
    const tx = await bank.withdraw(amount);
    await tx.wait();
    await fetchBalances();
  }

  return (
    <div style={{ padding: '20px' }}>
      <h2>🎉 TokenBank 前端界面</h2>
      {!account ? (
        <button onClick={connectWallet}>连接钱包</button>
      ) : (
        <div>
          <p>地址：{account}</p>
          <p>Token 余额：{tokenBalance}</p>
          <p>已存款金额：{bankBalance}</p>
          <div>
            <input placeholder="存款金额" value={depositAmount} onChange={(e) => setDepositAmount(e.target.value)} />
            <button onClick={handleDeposit}>存款</button>
          </div>
          <div>
            <input placeholder="取款金额" value={withdrawAmount} onChange={(e) => setWithdrawAmount(e.target.value)} />
            <button onClick={handleWithdraw}>取款</button>
          </div>
        </div>
      )}
    </div>
  );
}

export default App;
