// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MoodNFT is ERC721 {
    uint256 private s_tokenCounter;
    string private s_seductiveSvImageUri;
    string private s_playfulSvgImageUri;

    enum Mood {
        SEDUCTIVE, PLAYFUL
    }

    mapping(uint256 => Mood) private s_tokenIdToMood;

    constructor(string memory seductiveSvImageUri, string memory playfulSvgImageUri) ERC721("MoodNFT", "MNFT") {
        s_tokenCounter = 0;
        s_seductiveSvImageUri = seductiveSvImageUri;
        s_playfulSvgImageUri = playfulSvgImageUri;
    }

    function mintNft() public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenIdToMood[s_tokenCounter] = Mood.SEDUCTIVE ;
        s_tokenCounter++;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64";
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        string memory imageURI;
        if (s_tokenIdToMood[tokenId] == Mood.SEDUCTIVE) {
            imageURI = s_seductiveSvImageUri;
        } else {
            imageURI = s_playfulSvgImageUri;
        }

        return
        string(
            abi.encodePacked(
                _baseURI(),
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name": "', name(), '", "description": "An  NFT that changes the mood", "attributes": [{"trait_type": "charm", "value": 101}], "image": "', imageURI, '"}'
                            )
                        )
                    )
                )
            );
    }
}