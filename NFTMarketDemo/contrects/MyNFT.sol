// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract MyNFT is ERC721URIStorage {
    uint256 public nextId = 0;
    function mint(string memory uri) public {
        _mint(msg.sender, nextId);
        _setTokenURI(nextId, uri);
        nextId++;
    }
}
