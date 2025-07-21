import './App.css';
import useWallet from './hooks/useWallet';
import TokenBalance from './components/TokenBalance';
import DepositButton from './components/DepositButton';
import WithdrawButton from './components/WithdrawButton';

function App() {
  const { account, connect, provider } = useWallet();

  return (
    <div style={{ padding: 20 }}>
      <h1>🏦 Token Bank UI</h1>
      {account ? (
        <>
          <p>😈 Connected Account: {account}</p>
          <TokenBalance account={account} provider={provider} />
          <DepositButton account={account} provider={provider} />
          <WithdrawButton account={account} provider={provider} />
        </>
      ) : (
        <button onClick={connect}>🔌 Connect Wallet</button>
      )}
    </div>
  );
}

export default App;