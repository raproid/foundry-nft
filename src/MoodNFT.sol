// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ModNFT is ERC721 {
    constructor() ERC721("MoodNFT", "MNFT") {

    }
}