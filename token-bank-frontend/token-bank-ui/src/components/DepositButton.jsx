import { ethers } from 'ethers';
import { BANK_ADDRESS, TOKEN_ADDRESS } from '../constants/addresses';
import tokenABI from '../constants/tokenABI.json';
import bankABI from '../constants/bankABI.json';

export default function DepositButton({ account, provider }) {
  const deposit = async () => {
    const signer = await provider.getSigner(account);
    const token = new ethers.Contract(TOKEN_ADDRESS, tokenABI, signer);
    const bank = new ethers.Contract(BANK_ADDRESS, bankABI, signer);

    const amount = ethers.parseUnits("1", 18);
    const tx1 = await token.approve(BANK_ADDRESS, amount);
    await tx1.wait();
    const tx2 = await bank.deposit(amount);
    await tx2.wait();
    alert("✅ Deposit complete");
  };

  return <button onClick={deposit}>💰 Deposit 1 Token</button>;
}