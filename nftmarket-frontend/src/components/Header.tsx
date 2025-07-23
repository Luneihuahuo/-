import React from 'react';
import { ConnectButton } from '@rainbow-me/rainbowkit';

const Header = () => {
  return (
    <header className="header">
      <div style={{ fontSize: '1.5rem', fontWeight: 'bold' }}>
        NFT Market
      </div>
      <ConnectButton />
    </header>
  );
};

export default Header;