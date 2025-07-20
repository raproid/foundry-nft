// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {MoodNft} from "src/MoodNft.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {DeployMoodNft} from "script/DeployMoodNft.s.sol";

contract MoodNftTest is Test {
    MoodNft moodNft;

    // Test constants
    string public constant SEDUCTIVE_SVG_URI =
        "data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMjAwIDIwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3QgZmlsbD0iIzBkMGExYSIvPgo8dGV4dCB4PSIxMDAiIHk9IjMwIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSIjZmYzMzY2IiBmb250LXNpemU9IjIwIiBmb250LXdlaWdodD0iYm9sZCI+U0hPT1NIPC90ZXh0Pgo8ZWxsaXBzZSBjeD0iMTAwIiBjeT0iODAiIHJ4PSIyNSIgcnk9IjM1IiBmaWxsPSIjYzg4NTVhIi8+CjxwYXRoIGQ9Ik04MCA2NSBRMTAwIDU1IDEyMCA3NSBRMTEwIDkwIDEwMCA5NSBROTAgOTAgODAgNjVaIiBmaWxsPSIjOGI1YTNjIi8+CjxlbGxpcHNlIGN4PSI5MiIgY3k9Ijc1IiByeD0iMiIgcnk9IjIiIGZpbGw9IiMxYTBkMGEiLz4KPGVsbGlwc2UgY3g9IjEwOCIgY3k9Ijc1IiByeD0iMiIgcnk9IjIiIGZpbGw9IiMxYTBkMGEiLz4KPHBhdGggZD0iTTk1IDg1IFExMDAgODggMTA1IDg1IiBzdHJva2U9IiM2NTQzMjEiIHN0cm9rZS13aWR0aD0iMSIgZmlsbD0ibm9uZSIvPgo8cmVjdCB4PSI5NSIgeT0iOTUiIHdpZHRoPSIzIiBoZWlnaHQ9IjEyIiBmaWxsPSIjYzg4NTVhIi8+CjxlbGxpcHNlIGN4PSI5NyIgY3k9IjEwNSIgcng9IjEiIHJ5PSIyIiBmaWxsPSIjY2M0NDQ0Ii8+CjxjaXJjbGUgY3g9IjExMiIgY3k9IjgyIiByPSIxIiBmaWxsPSIjZmZkNzAwIi8+CjxyZWN0IHg9IjE4MCIgeT0iNjAiIHdpZHRoPSI4IiBoZWlnaHQ9IjE1IiBmaWxsPSIjMDBjYzQ0Ii8+Cjx0ZXh0IHg9IjE4NCIgeT0iNzIiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGZpbGw9IiNmZmYiIGZvbnQtc2l6ZT0iNiI+JDwvdGV4dD4KPC9zdmc+";
    string public constant PLAYFUL_SVG_URI =
        "data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMjAwIDIwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3QgZmlsbD0iIzFhMGQxYSIvPgo8dGV4dCB4PSIxMDAiIHk9IjMwIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSIjZmYzMzY2IiBmb250LXNpemU9IjIwIiBmb250LXdlaWdodD0iYm9sZCI+U0hPT1NIPC90ZXh0Pgo8ZWxsaXBzZSBjeD0iMTAwIiBjeT0iODAiIHJ4PSIyNSIgcnk9IjM1IiBmaWxsPSIjZDQ5MzRhIi8+CjxwYXRoIGQ9Ik03NSA3MCBRMTAwIDU1IDEyNSA3MCBRMTE1IDkwIDEwMCA5NSBRODUgOTAgNzUgNzBaIiBmaWxsPSIjYjg3MDNhIi8+CjxlbGxpcHNlIGN4PSI5MiIgY3k9Ijc1IiByeD0iMiIgcnk9IjIiIGZpbGw9IiMyYTE4MTAiLz4KPGVsbGlwc2UgY3g9IjEwOCIgY3k9Ijc1IiByeD0iMiIgcnk9IjIiIGZpbGw9IiMyYTE4MTAiLz4KPHBhdGggZD0iTTk1IDg1IFExMDAgODggMTA1IDg1IiBzdHJva2U9IiM4YjQ1MTMiIHN0cm9rZS13aWR0aD0iMSIgZmlsbD0ibm9uZSIvPgo8cmVjdCB4PSI5NSIgeT0iOTUiIHdpZHRoPSIzIiBoZWlnaHQ9IjEyIiBmaWxsPSIjZDQ5MzRhIi8+CjxlbGxpcHNlIGN4PSI5NyIgY3k9IjEwNSIgcng9IjEiIHJ5PSIyIiBmaWxsPSIjZmY2YjZiIi8+CjxyZWN0IHg9IjE4MCIgeT0iNjAiIHdpZHRoPSI4IiBoZWlnaHQ9IjE1IiBmaWxsPSIjMDBjYzQ0Ii8+Cjx0ZXh0IHg9IjE4NCIgeT0iNzIiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGZpbGw9IiNmZmYiIGZvbnQtc2l6ZT0iNiI+JDwvdGV4dD4KPC9zdmc+";
    DeployMoodNft deployer;

        // Test addresses
    address USER = makeAddr("user");
    address ALICE = makeAddr("alice");
    address BOB = makeAddr("bob");
    address ZERO_ADDRESS = address(0);

    function setUp() public {
        deployer = new DeployMoodNft();
        moodNft = deployer.run();
    }

    function testViewTokenUriIntegration() public {
        vm.prank(USER);
        moodNft.mintNft();
    }

}