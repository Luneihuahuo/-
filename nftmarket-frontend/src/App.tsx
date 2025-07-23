import { useState } from 'react';
import Header from './components/Header';
import ListNFT from './components/ListNFT';
import BuyNFT from './components/BuyNFT';
import { useAccount } from 'wagmi';
import { tokenAddress } from './contracts';
// import { tokenAddress } from '../contracts';

// NFT 信息类型
interface ListedNFT {
  nftContract: `0x${string}`;
  tokenId: string;
  price: string;
}

// BigInt 安全转换
function safeBigInt(value: string): bigint | null {
  try {
    if (!/^[0-9]+$/.test(value)) return null;
    return BigInt(value);
  } catch {
    return null;
  }
}

// NFT 信息展示组件
function NFTInfo({ nft }: { nft: ListedNFT }) {
  return (
    <>
      <p>
        <strong>Contract:</strong> {nft.nftContract}
      </p>
      <p>
        <strong>Token ID:</strong> {nft.tokenId}
      </p>
      <p>
        <strong>Price:</strong> {nft.price} Tokens
      </p>
    </>
  );
}

function App() {
  const [listedNFT, setListedNFT] = useState<ListedNFT | null>(null);
  const { address } = useAccount();

  const handleNFTListed = (data: ListedNFT) => {
    setListedNFT(data);
  };

  // 转换 tokenId 和 price
  const tokenIdBigInt = listedNFT ? safeBigInt(listedNFT.tokenId) : null;
  const priceBigInt = listedNFT ? safeBigInt(listedNFT.price) : null;

  return (
    <>
      <Header />
      <main>
        <h1>NFT Marketplace</h1>
        <div className="card">
          <ListNFT onNFTListed={handleNFTListed} />
        </div>

        {listedNFT && tokenIdBigInt !== null && priceBigInt !== null && (
          <div className="card">
            <h2>Buy Listed NFT</h2>
            <p>有新的 NFT 上架！你可以切换账号进行购买。</p>
            <NFTInfo nft={listedNFT} />
            <BuyNFT
              nftContract={listedNFT.nftContract}
              tokenId={tokenIdBigInt}
              price={priceBigInt}
              disabled={!address}
              tokenAddress={tokenAddress}
            />
          </div>
        )}
        {listedNFT && (tokenIdBigInt === null || priceBigInt === null) && (
          <div className="card">
            <p>Token ID 或 Price 格式不正确，无法购买。</p>
          </div>
        )}
      </main>
    </>
  );
}

export default App;