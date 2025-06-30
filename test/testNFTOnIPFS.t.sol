/*
Types of tests included:
* Unit tests - Testing individual functions of the NFT contract and the deploy script
* ERC721 compliance tests - Ensuring the contract follows the standard
* Edge case tests - Boundary conditions and error scenarios
* Fuzz tests - Random input testing
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {NFTOnIPFS} from "../src/NFTOnIPFS.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {DeployNFTOnIPFS} from "../script/DeployNFTOnIPFS.s.sol";

contract NFTOnIPFSTest is Test, IERC721Receiver {
    DeployNFTOnIPFS public deployer;
    NFTOnIPFS nft;
    address owner = address(this);
    address user1 = address(0x1);
    address user2 = address(0x2);

    string constant SAMPLE_URI_1 = "ipfs://QmSampleHash1";
    string constant SAMPLE_URI_2 = "ipfs://QmSampleHash2";
    string constant SAMPLE_URI_3 = "ipfs://QmSampleHash3";

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    function setUp() public {
        deployer = new DeployNFTOnIPFS();
        nft = new NFTOnIPFS();

        // Label addresses for better debugging
        vm.label(address(nft), "NFTOnIPFS");
        vm.label(owner, "Owner");
        vm.label(user1, "User1");
        vm.label(user2, "User2");
    }

    // ====== INTERNAL HELPER FUNCTIONS ======

    /// @dev Helper to mint multiple tokens to the owner
    function _setupWithMintedTokens(uint256 count) internal {
        for (uint256 i = 0; i < count; i++) {
            string memory uri = string(abi.encodePacked("ipfs://token", vm.toString(i)));
            nft.mintNFT(uri);
        }
    }

    /// @dev Helper to setup tokens with various approval scenarios
    function _setupWithApprovals() internal {
        nft.mintNFT(SAMPLE_URI_1);
        nft.mintNFT(SAMPLE_URI_2);
        nft.mintNFT(SAMPLE_URI_3);

        // Approve user1 for token 0
        nft.approve(user1, 0);
        // Set user2 as operator for all tokens
        nft.setApprovalForAll(user2, true);
    }

    /// @dev Helper to setup tokens owned by different users
    function _setupWithMultipleOwners() internal {
        // Owner mints token 0
        nft.mintNFT(SAMPLE_URI_1);

        // User1 mints token 1
        vm.prank(user1);
        nft.mintNFT(SAMPLE_URI_2);

        // User2 mints token 2
        vm.prank(user2);
        nft.mintNFT(SAMPLE_URI_3);
    }

    /// @dev Helper to create a fresh NFT contract instance
    function _createNFTContract() internal returns (NFTOnIPFS) {
        return new NFTOnIPFS();
    }

    /// @dev Helper to generate dynamic URI for testing
    function _generateURI(uint256 tokenId) internal pure returns (string memory) {
        return string(abi.encodePacked("ipfs://dynamic", vm.toString(tokenId)));
    }

    // ====== CONSTRUCTOR TESTS ======
    function testConstructorSetsCorrectName() public view {
        assertEq(nft.name(), "Shoosh");
    }

    function testConstructorSetsCorrectSymbol() public view {
        assertEq(nft.symbol(), "SHO");
    }

    // ====== DEPLOYMENT LOGIC TESTS ======
    function testDeploymentScript() public {
        NFTOnIPFS deployedNFT = deployer.run();

        // Test that deployment worked correctly
        assertEq(deployedNFT.name(), "Shoosh");
        assertEq(deployedNFT.symbol(), "SHO");
    }

    function testDeploymentScriptReturnsValidContract() public {
        NFTOnIPFS deployedNFT = deployer.run();

        // Verify it's a valid contract
        assertTrue(address(deployedNFT) != address(0));

        // Verify it works by minting
        deployedNFT.mintNFT("test");
        assertEq(deployedNFT.ownerOf(0), address(this));
    }

    // ====== MINTING TESTS ======
    function testMintNFTCreatesTokenWithCorrectURI() public {
        nft.mintNFT(SAMPLE_URI_1);

        assertEq(nft.tokenURI(0), SAMPLE_URI_1);
        assertEq(nft.getTokenURI(0), SAMPLE_URI_1);
    }

    function testMintNFTAssignsOwnershipToSender() public {
        nft.mintNFT(SAMPLE_URI_1);

        assertEq(nft.ownerOf(0), owner);
        assertEq(nft.balanceOf(owner), 1);
    }

    function testMintNFTIncrementsTokenCounter() public {
        nft.mintNFT(SAMPLE_URI_1);
        nft.mintNFT(SAMPLE_URI_2);
        nft.mintNFT(SAMPLE_URI_3);

        assertEq(nft.tokenURI(0), SAMPLE_URI_1);
        assertEq(nft.tokenURI(1), SAMPLE_URI_2);
        assertEq(nft.tokenURI(2), SAMPLE_URI_3);
    }

    function testMintNFTEmitsTransferEvent() public {
        vm.expectEmit(true, true, true, false);
        emit Transfer(address(0), owner, 0);

        nft.mintNFT(SAMPLE_URI_1);
    }

    function testMintNFTByDifferentUsers() public {
        // Mint by user1
        vm.prank(user1);
        nft.mintNFT(SAMPLE_URI_1);

        // Mint by user2
        vm.prank(user2);
        nft.mintNFT(SAMPLE_URI_2);

        assertEq(nft.ownerOf(0), user1);
        assertEq(nft.ownerOf(1), user2);
        assertEq(nft.balanceOf(user1), 1);
        assertEq(nft.balanceOf(user2), 1);
    }

    function testMintNFTWithEmptyURI() public {
        nft.mintNFT("");

        assertEq(nft.tokenURI(0), "");
        assertEq(nft.getTokenURI(0), "");
    }

    function testMintMultipleNFTsToSameOwner() public {
        _setupWithMintedTokens(3);

        assertEq(nft.balanceOf(owner), 3);
        assertEq(nft.ownerOf(0), owner);
        assertEq(nft.ownerOf(1), owner);
        assertEq(nft.ownerOf(2), owner);
    }

    function testMintWithHelperGeneratesCorrectURIs() public {
        _setupWithMintedTokens(5);

        for (uint256 i = 0; i < 5; i++) {
            string memory expectedUri = string(abi.encodePacked("ipfs://token", vm.toString(i)));
            assertEq(nft.tokenURI(i), expectedUri);
        }
    }

    // ====== TOKEN NAME TESTS ======
    function testTokenNameIsCorrect() public view {
        string memory expectedName = "Shoosh";
        string memory actualName = nft.name();
        assert(keccak256(abi.encodePacked(expectedName)) == keccak256(abi.encodePacked(actualName)));
    }

    // ====== TOKEN URI TESTS ======
    function testTokenURIReturnsCorrectURI() public {
        nft.mintNFT(SAMPLE_URI_1);

        assert(keccak256(abi.encodePacked(nft.tokenURI(0))) == keccak256(abi.encodePacked(SAMPLE_URI_1)));
    }

    function testTokenURIRevertsForNonexistentToken() public {
        vm.expectRevert("ERC721: URI query for nonexistent token");
        nft.tokenURI(0);
    }

    function testTokenURIRevertsForHighTokenId() public {
        nft.mintNFT(SAMPLE_URI_1);

        vm.expectRevert("ERC721: URI query for nonexistent token");
        nft.tokenURI(1);
    }

    function testGetTokenURIReturnsCorrectURI() public {
        nft.mintNFT(SAMPLE_URI_1);

        assertEq(nft.getTokenURI(0), SAMPLE_URI_1);
    }

    function testGetTokenURIForNonexistentToken() public view {
        // getTokenURI doesn't check if token exists, so it returns empty string
        assertEq(nft.getTokenURI(0), "");
    }

    // ====== ERC721 STANDARD COMPLIANCE TESTS ======
    function testSupportsInterface() public view {
        // ERC721 interface ID
        assertTrue(nft.supportsInterface(0x80ac58cd));
        // ERC721Metadata interface ID
        assertTrue(nft.supportsInterface(0x5b5e139f));
        // ERC165 interface ID
        assertTrue(nft.supportsInterface(0x01ffc9a7));
    }

    function testBalanceOfZeroForNewAddress() public view {
        assertEq(nft.balanceOf(user1), 0);
    }

    function testBalanceOfRevertsForZeroAddress() public {
        vm.expectRevert();
        nft.balanceOf(address(0));
    }

    function testOwnerOfRevertsForNonexistentToken() public {
        vm.expectRevert();
        nft.ownerOf(0);
    }

    // ====== TRANSFER TESTS ======
    function testTransferFrom() public {
        nft.mintNFT(SAMPLE_URI_1);

        nft.transferFrom(owner, user1, 0);

        assertEq(nft.ownerOf(0), user1);
        assertEq(nft.balanceOf(owner), 0);
        assertEq(nft.balanceOf(user1), 1);
    }

    function testSafeTransferFrom() public {
        nft.mintNFT(SAMPLE_URI_1);

        nft.safeTransferFrom(owner, user1, 0);

        assertEq(nft.ownerOf(0), user1);
        assertEq(nft.balanceOf(owner), 0);
        assertEq(nft.balanceOf(user1), 1);
    }

    function testTransferFromRevertsForNonexistentToken() public {
        vm.expectRevert();
        nft.transferFrom(owner, user1, 0);
    }

    function testTransferFromRevertsForUnauthorizedCaller() public {
        nft.mintNFT(SAMPLE_URI_1);

        vm.prank(user1);
        vm.expectRevert();
        nft.transferFrom(owner, user1, 0);
    }

    function testTransferBetweenMultipleOwners() public {
        _setupWithMultipleOwners();

        // User1 transfers their token to user2
        vm.prank(user1);
        nft.transferFrom(user1, user2, 1);

        assertEq(nft.ownerOf(1), user2);
        assertEq(nft.balanceOf(user1), 0);
        assertEq(nft.balanceOf(user2), 2); // user2 now has tokens 1 and 2
    }

    // ====== APPROVAL TESTS ======
    function testApprove() public {
        nft.mintNFT(SAMPLE_URI_1);

        nft.approve(user1, 0);

        assertEq(nft.getApproved(0), user1);
    }

    function testApproveRevertsForNonexistentToken() public {
        vm.expectRevert();
        nft.approve(user1, 0);
    }

    function testApprovedCanTransfer() public {
        nft.mintNFT(SAMPLE_URI_1);
        nft.approve(user1, 0);

        vm.prank(user1);
        nft.transferFrom(owner, user2, 0);

        assertEq(nft.ownerOf(0), user2);
    }

    function testSetApprovalForAll() public {
        nft.setApprovalForAll(user1, true);

        assertTrue(nft.isApprovedForAll(owner, user1));
    }

    function testOperatorCanTransferAll() public {
        _setupWithMintedTokens(3);
        nft.setApprovalForAll(user1, true);

        vm.startPrank(user1);
        nft.transferFrom(owner, user2, 0);
        nft.transferFrom(owner, user2, 1);
        nft.transferFrom(owner, user2, 2);
        vm.stopPrank();

        assertEq(nft.ownerOf(0), user2);
        assertEq(nft.ownerOf(1), user2);
        assertEq(nft.ownerOf(2), user2);
        assertEq(nft.balanceOf(user2), 3);
        assertEq(nft.balanceOf(owner), 0);
    }

    function testApprovalScenarios() public {
        _setupWithApprovals();

        // Test individual approval
        vm.prank(user1);
        nft.transferFrom(owner, user1, 0);
        assertEq(nft.ownerOf(0), user1);

        // Test operator approval
        vm.prank(user2);
        nft.transferFrom(owner, user2, 1);
        assertEq(nft.ownerOf(1), user2);

        // Verify remaining token still owned by owner
        assertEq(nft.ownerOf(2), owner);
    }

    // ====== EDGE CASES AND FUZZ TESTS ======
    function testFuzzMintWithRandomURI(string memory randomURI) public {
        vm.assume(bytes(randomURI).length > 0);

        nft.mintNFT(randomURI);

        assertEq(nft.tokenURI(0), randomURI);
        assertEq(nft.ownerOf(0), owner);
    }

    function testFuzzMultipleMints(uint8 numberOfMints) public {
        vm.assume(numberOfMints > 0 && numberOfMints <= 50); // Reasonable bounds

        _setupWithMintedTokens(numberOfMints);

        assertEq(nft.balanceOf(owner), numberOfMints);

        // Check that all tokens have correct URIs
        for (uint256 i = 0; i < numberOfMints; i++) {
            string memory expectedUri = string(abi.encodePacked("ipfs://token", vm.toString(i)));
            assertEq(nft.tokenURI(i), expectedUri);
        }
    }

    function testLongURI() public {
        string memory longURI = "ipfs://QmVeryLongHashThatExceedsNormalLengthsAndTestsEdgeCasesForStringHandling1234567890abcdefghijklmnopqrstuvwxyz";

        nft.mintNFT(longURI);

        assertEq(nft.tokenURI(0), longURI);
    }

    function testSpecialCharactersInURI() public {
        string memory specialURI = "ipfs://test!@#$%^&*()_+-=[]{}|;':\",./<>?";

        nft.mintNFT(specialURI);

        assertEq(nft.tokenURI(0), specialURI);
    }

    function testDynamicURIGeneration() public {
        for (uint256 i = 0; i < 5; i++) {
            string memory dynamicURI = _generateURI(i);
            nft.mintNFT(dynamicURI);
            assertEq(nft.tokenURI(i), dynamicURI);
        }
    }

    // ====== MULTIPLE CONTRACT INSTANCES TESTS ======
    function testMultipleContractInstances() public {
        NFTOnIPFS nft2 = _createNFTContract();
        NFTOnIPFS nft3 = _createNFTContract();

        vm.label(address(nft2), "NFTOnIPFS2");
        vm.label(address(nft3), "NFTOnIPFS3");

        nft.mintNFT(SAMPLE_URI_1);
        nft2.mintNFT(SAMPLE_URI_2);
        nft3.mintNFT(SAMPLE_URI_3);

        // Verify each contract maintains its own state
        assertEq(nft.ownerOf(0), owner);
        assertEq(nft2.ownerOf(0), owner);
        assertEq(nft3.ownerOf(0), owner);

        assertEq(nft.tokenURI(0), SAMPLE_URI_1);
        assertEq(nft2.tokenURI(0), SAMPLE_URI_2);
        assertEq(nft3.tokenURI(0), SAMPLE_URI_3);
    }

    function testCrossContractInteractions() public {
        NFTOnIPFS nft2 = _createNFTContract();

        // Mint tokens on both contracts
        nft.mintNFT(SAMPLE_URI_1);
        nft2.mintNFT(SAMPLE_URI_2);

        // Verify balances are separate
        assertEq(nft.balanceOf(owner), 1);
        assertEq(nft2.balanceOf(owner), 1);

        // Transfer from each contract
        nft.transferFrom(owner, user1, 0);
        nft2.transferFrom(owner, user2, 0);

        assertEq(nft.ownerOf(0), user1);
        assertEq(nft2.ownerOf(0), user2);
    }

    // ====== BALANCE INVARIANT TESTS ======
    function testBalanceOfSumEqualsTokenSupply() public {
        _setupWithMultipleOwners();

        // Total supply should equal sum of all balances
        uint256 totalBalance = nft.balanceOf(owner) + nft.balanceOf(user1) + nft.balanceOf(user2);
        assertEq(totalBalance, 3);
    }

    function testBalanceInvariantsAfterTransfers() public {
        _setupWithMintedTokens(5);
        uint256 initialBalance = nft.balanceOf(owner);

        // Transfer some tokens
        nft.transferFrom(owner, user1, 0);
        nft.transferFrom(owner, user1, 1);
        nft.transferFrom(owner, user2, 2);

        // Verify total balance remains constant
        uint256 finalTotalBalance = nft.balanceOf(owner) + nft.balanceOf(user1) + nft.balanceOf(user2);
        assertEq(finalTotalBalance, initialBalance);

        // Verify individual balances
        assertEq(nft.balanceOf(owner), 2);
        assertEq(nft.balanceOf(user1), 2);
        assertEq(nft.balanceOf(user2), 1);
    }

    // ====== IERC721Receiver IMPLEMENTATION ======
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}