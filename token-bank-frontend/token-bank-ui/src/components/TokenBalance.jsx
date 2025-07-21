import { useEffect, useState } from 'react';
import { ethers } from 'ethers';
import { TOKEN_ADDRESS } from '../constants/addresses';
import tokenABI from '../constants/tokenABI.json';

export default function TokenBalance({ account, provider }) {
  const [balance, setBalance] = useState('0');

  useEffect(() => {
    if (!account || !provider) return;
    const contract = new ethers.Contract(TOKEN_ADDRESS, tokenABI.abi, provider);
    contract.balanceOf(account).then(value => {
      setBalance(ethers.formatUnits(value, 18));
    });
  }, [account, provider]);

  return <p>🎯 Token Balance: {balance}</p>;
}