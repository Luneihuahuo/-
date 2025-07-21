import { useState, useEffect } from 'react';
import { ethers } from 'ethers';

export default function useWallet() {
  const [account, setAccount] = useState(null);
  const [provider, setProvider] = useState(null);

  useEffect(() => {
    if (window.ethereum) {
      const ethProvider = new ethers.BrowserProvider(window.ethereum);
      setProvider(ethProvider);

      // 初始获取账户
      window.ethereum.request({ method: 'eth_accounts' }).then(accounts => {
        if (accounts.length > 0) setAccount(accounts[0]);
        else setAccount(null);
      });

      // 账户变更监听
      const handleAccountsChanged = (accounts) => {
        if (accounts.length > 0) setAccount(accounts[0]);
        else setAccount(null);
      };
      window.ethereum.on('accountsChanged', handleAccountsChanged);

      // 清理监听器
      return () => {
        window.ethereum.removeListener('accountsChanged', handleAccountsChanged);
      };
    }
  }, []);

  const connect = async () => {
    if (!window.ethereum) {
      alert("Please install MetaMask");
      return;
    }
    const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
    if (accounts.length > 0) setAccount(accounts[0]);
    else setAccount(null);
  };

  return { account, connect, provider };
}