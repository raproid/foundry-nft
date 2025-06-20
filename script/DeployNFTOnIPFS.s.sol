// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {NFTOnIPFS} from "src/NFTOnIPFS.sol";

contract DeployNFTOnIPFS is Script {
    function run() external returns (NFTOnIPFS) {
        vm.startBroadcast();
        NFTOnIPFS nftOnIPFS = new NFTOnIPFS();
        vm.stopBroadcast();
        return nftOnIPFS;
    }
}