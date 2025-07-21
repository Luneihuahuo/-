import { ethers } from 'ethers';
import { BANK_ADDRESS } from '../constants/addresses';
import bankABI from '../constants/bankABI.json';

export default function WithdrawButton({ account, provider }) {
  const withdraw = async () => {
    const signer = await provider.getSigner(account);
    const bank = new ethers.Contract(BANK_ADDRESS, bankABI, signer);
    const tx = await bank.withdraw();
    await tx.wait();
    alert("✅ Withdraw complete");
  };

  return <button onClick={withdraw}>🏦 Withdraw</button>;
}