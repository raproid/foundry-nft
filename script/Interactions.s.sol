// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {NFTOnIPFS} from "src/NFTOnIPFS.sol";

contract Interactions is Script {
    string public constant SHOO = "https://bafybeibnkvqdxg3bsryacztdqdydlytouaapxnmlftjy3xnh3k2pevg2qm.ipfs.dweb.link?filename=SHOO.json";

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "NFTOnIPFS",
            block.chainid
        );
        mintNftOnContract(mostRecentlyDeployed);
    }

    function mintNftOnContract(address contractAddress) public {
        vm.startBroadcast();
        NFTOnIPFS(contractAddress).mintNFT(SHOO);
        vm.stopBroadcast();
    }
}