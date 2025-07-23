import { useWriteContract, useWaitForTransactionReceipt, useAccount } from 'wagmi';
import { marketplaceAddress, tokenAbi, marketplaceAbi } from '../contracts';
import React from 'react'; // Added missing import

interface BuyNFTProps {
    nftContract: `0x${string}`;
    tokenId: bigint;
    price: bigint;
    disabled: boolean;
    tokenAddress: `0x${string}`;
}

const BuyNFT = ({ nftContract, tokenId, price, disabled, tokenAddress }: BuyNFTProps) => {
    const { address } = useAccount();

    // 1. 授权 Token 给市场合约
    const { data: approveHash, isPending: isApprovePending, writeContract: approve } = useWriteContract();
    const { isSuccess: isApproveSuccess } = useWaitForTransactionReceipt({ hash: approveHash });

    // 2. 购买 NFT
    const { data: buyHash, isPending: isBuyPending, writeContract: buy } = useWriteContract();
    const { isSuccess: isBuySuccess } = useWaitForTransactionReceipt({ hash: buyHash });

    // 授权成功后自动购买
    React.useEffect(() => {
        if (isApproveSuccess) {
            buy({
                address: marketplaceAddress,
                abi: marketplaceAbi,
                functionName: 'buy',
                args: [nftContract, tokenId],
                value: price
            });
        }
    }, [isApproveSuccess]);

    const handleBuy = () => {
        if (!address) {
            alert('Please connect your wallet to buy.');
            return;
        }
        approve({
            address: tokenAddress,
            abi: tokenAbi,
            functionName: 'approve',
            args: [marketplaceAddress, price]
        });
    };

    return (
        <button onClick={handleBuy} disabled={disabled || isApprovePending || isBuyPending}>
            {isApprovePending ? 'Approving Token...' : isBuyPending ? 'Buying...' : `Buy for ${price.toString()} Tokens`}
        </button>
    );
};

export default BuyNFT;