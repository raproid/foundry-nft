// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DeployMoodNft} from "script/DeployMoodNft.s.sol";

contract DeployMoodNftTest is Test {
    DeployMoodNft public deployer;

    function setUp() public {
        deployer = new DeployMoodNft();
    }

    function testConvertSvgToUri() public view {
        string memory expectedUri = "data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMjAwIDIwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3QgZmlsbD0iIzBkMGExYSIvPgo8dGV4dCB4PSIxMDAiIHk9IjMwIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSIjZmYzMzY2IiBmb250LXNpemU9IjIwIiBmb250LXdlaWdodD0iYm9sZCI+U0hPT1NIPC90ZXh0Pgo8ZWxsaXBzZSBjeD0iMTAwIiBjeT0iODAiIHJ4PSIyNSIgcnk9IjM1IiBmaWxsPSIjYzg4NTVhIi8+CjxwYXRoIGQ9Ik04MCA2NSBRMTAwIDU1IDEyMCA3NSBRMTEwIDkwIDEwMCA5NSBROTAgOTAgODAgNjVaIiBmaWxsPSIjOGI1YTNjIi8+CjxlbGxpcHNlIGN4PSI5MiIgY3k9Ijc1IiByeD0iMiIgcnk9IjIiIGZpbGw9IiMxYTBkMGEiLz4KPGVsbGlwc2UgY3g9IjEwOCIgY3k9Ijc1IiByeD0iMiIgcnk9IjIiIGZpbGw9IiMxYTBkMGEiLz4KPHBhdGggZD0iTTk1IDg1IFExMDAgODggMTA1IDg1IiBzdHJva2U9IiM2NTQzMjEiIHN0cm9rZS13aWR0aD0iMSIgZmlsbD0ibm9uZSIvPgo8cmVjdCB4PSI5NSIgeT0iOTUiIHdpZHRoPSIzIiBoZWlnaHQ9IjEyIiBmaWxsPSIjYzg4NTVhIi8+CjxlbGxpcHNlIGN4PSI5NyIgY3k9IjEwNSIgcng9IjEiIHJ5PSIyIiBmaWxsPSIjY2M0NDQ0Ii8+CjxjaXJjbGUgY3g9IjExMiIgY3k9IjgyIiByPSIxIiBmaWxsPSIjZmZkNzAwIi8+CjxyZWN0IHg9IjE4MCIgeT0iNjAiIHdpZHRoPSI4IiBoZWlnaHQ9IjE1IiBmaWxsPSIjMDBjYzQ0Ii8+Cjx0ZXh0IHg9IjE4NCIgeT0iNzIiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGZpbGw9IiNmZmYiIGZvbnQtc2l6ZT0iNiI+JDwvdGV4dD4KPC9zdmc+";
        string memory svg = vm.readFile("img/shoosh/simplified_seductive.svg");
        string memory actualUri = deployer.svgToImageURI(svg);
        assert(keccak256(abi.encodePacked(actualUri)) == keccak256(abi.encodePacked(expectedUri)));
    }
}