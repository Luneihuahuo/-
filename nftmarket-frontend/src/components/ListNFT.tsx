import React, { useState, FormEvent, useEffect } from 'react';
import { useWriteContract, useWaitForTransactionReceipt, useAccount } from 'wagmi';
import { marketplaceAddress, nftAbi, marketplaceAbi } from '../contracts';
import { parseEther } from 'viem';

interface ListNFTProps {
    onNFTListed: (data: { nftContract: `0x${string}`; tokenId: string; price: string; }) => void;
}

const ListNFT = ({ onNFTListed }: ListNFTProps) => {
    const [nftContract, setNftContract] = useState('');
    const [tokenId, setTokenId] = useState('');
    const [price, setPrice] = useState('');
    const { address } = useAccount();

    // 授权 NFT
    const {
        data: approveHash,
        isPending: isApproveLoading,
        writeContract: approve
    } = useWriteContract();

    const {
        isSuccess: isApproveSuccess
    } = useWaitForTransactionReceipt({
        hash: approveHash
    });

    // 上架 NFT
    const {
        data: listHash,
        isPending: isListLoading,
        writeContract: list
    } = useWriteContract();

    const {
        isSuccess: isListSuccess
    } = useWaitForTransactionReceipt({
        hash: listHash
    });

    // 授权成功后自动上架
    useEffect(() => {
        if (isApproveSuccess) {
            list({
                address: marketplaceAddress,
                abi: marketplaceAbi, // 用 marketplaceAbi
                functionName: 'list',
                args: [nftContract as `0x${string}`, BigInt(tokenId || 0), parseEther(price || '0')]
            });
        }
        // eslint-disable-next-line
    }, [isApproveSuccess]);

    // 上架成功后回调
    useEffect(() => {
        if (isListSuccess) {
            alert('NFT Listed Successfully!');
            onNFTListed({
                nftContract: nftContract as `0x${string}`,
                tokenId,
                price
            });
        }
        // eslint-disable-next-line
    }, [isListSuccess]);

    const handleSubmit = (e: FormEvent) => {
        e.preventDefault();
        if (!nftContract || !tokenId || !price) {
            alert('Please fill all fields and connect your wallet.');
            return;
        }
        approve({
            address: nftContract as `0x${string}`,
            abi: nftAbi,
            functionName: 'approve',
            args: [marketplaceAddress, BigInt(tokenId)]
        });
    };

    if (!address) {
        return <div>Please connect your wallet to list an NFT.</div>;
    }

    return (
        <form onSubmit={handleSubmit}>
            <h2>List Your NFT</h2>
            <input
                type="text"
                value={nftContract}
                onChange={(e) => setNftContract(e.target.value)}
                placeholder="NFT Contract Address"
                required
            />
            <input
                type="text"
                value={tokenId}
                onChange={(e) => setTokenId(e.target.value)}
                placeholder="Token ID"
                required
            />
            <input
                type="text"
                value={price}
                onChange={(e) => setPrice(e.target.value)}
                placeholder="Price in Token"
                required
            />
            <button type="submit" disabled={isApproveLoading || isListLoading}>
                {isApproveLoading ? 'Approving...' : isListLoading ? 'Listing...' : 'List NFT'}
            </button>
        </form>
    );
};

export default ListNFT;