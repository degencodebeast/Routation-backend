// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// import "hardhat/console.sol";

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ICollection {
    // empty because we're not concerned with internal details
    function ownerOf(uint256 tokenId) external view returns (address);

    // function safeTransferFromWithPermit(
    //     address from,
    //     address to,
    //     uint256 tokenId,
    //     uint256 deadline,
    //     bytes memory signature
    // ) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

    function approve(address to, uint256 tokenId) external;

    function transferCrossChain(
        string memory destChainId,
        uint256 tokenId,
        bytes memory requestMetadata
    ) external payable;

    function mintTo(address to, string memory tokenURI) external;

    function _burn(uint256 tokenId) external;
}
