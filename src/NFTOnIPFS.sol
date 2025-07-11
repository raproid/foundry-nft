// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTOnIPFS is ERC721 {
    uint256 private s_tokenCounter;
    mapping(uint256 => string) private s_tokenIdToUri;

    constructor() ERC721("Shoosh", "SHO") {
        s_tokenCounter = 0;
    }

    function mintNFT(string memory tokenUri) public {
        s_tokenIdToUri[s_tokenCounter] = tokenUri;
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter++;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "ERC721: URI query for nonexistent token");
        return s_tokenIdToUri[tokenId];
    }

    // Getters
    function getTokenURI(uint256 tokenId) external view returns (string memory) {
        return s_tokenIdToUri[tokenId];
    }
}