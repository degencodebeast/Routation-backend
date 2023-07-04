// https://github.com/dappuniversity/nft_marketplace
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// import "hardhat/console.sol";

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface INFT{
    // empty because we're not concerned with internal details
    function ownerOf(uint256 tokenId) external view returns (address);
    function safeTransferFromWithPermit(address from, address to, uint256 tokenId, uint256 deadline, bytes memory signature) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
}