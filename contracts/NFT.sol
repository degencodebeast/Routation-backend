// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { ERC721, ERC721Permit } from "@soliditylabs/erc721-permit/contracts/ERC721Permit.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Strings.sol";

/**
 * @dev ERC721 token with storage based token URI management.
 */
abstract contract ERC721URIStoragePermit is ERC721Permit {
    using Strings for uint256;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev See {ERC721-_burn}. This override additionally checks to see if a
     * token-specific URI was set for the token, and if so, it deletes the token URI from
     * the storage mapping.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}

contract NFT is ERC721URIStoragePermit {
    using Counters for Counters.Counter;
    address owner;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;
    Counters.Counter private _nextTokenId;

    function getCurrentId() public view returns (uint256) {
        return _nextTokenId.current();
    }

    constructor(string memory name, string memory symbol) ERC721Permit(name, symbol) {
        owner = msg.sender;
        // token id 0 hv higher gas fee, so skip 0
    }

    // function getOperator() public view returns (address) {
    //     return operator;
    // }

    // function updateOperator(address _operator) public {
    //     require(owner == msg.sender, "Only owner can update operator");
    //     operator = _operator;
    // }

    function GetHolderNfts(address holder) public view returns (uint[] memory) {
        uint256 total = _nextTokenId.current();

        uint[] memory tokenIds = new uint[](total);

        for (uint256 i; i < total; i++) {
            if (ownerOf(i+1) == holder) {
                tokenIds[i] = i+1;
            }
        }
        return tokenIds;
    }

    function GetAllNftOwnerAddress() public view returns (address[] memory) {
        uint256 total = _nextTokenId.current();

        address[] memory ownerAddresses = new address[](total);

        for (uint256 i; i < total; i++) {
            ownerAddresses[i] = ownerOf(i+1);
        }
        return ownerAddresses;
    }

    function mint(string memory _tokenURI) external returns(uint) {
        _nextTokenId.increment();
        uint currentId = _nextTokenId.current();
        _safeMint(msg.sender, currentId);
        _setTokenURI(currentId, _tokenURI);
        return(currentId);
    }

    function mintTo(address receiver, string memory _tokenURI) external returns(uint) {
        _nextTokenId.increment();
        uint currentId = _nextTokenId.current();
        _safeMint(receiver, currentId);
        _setTokenURI(currentId, _tokenURI);
        return(currentId);
    }

    function safeTransferFromWithPermit(
        address from,
        address to,
        uint256 tokenId,
        uint256 deadline,
        bytes memory signature
    ) external {
        _safeTransferFromWithPermit(from, to, tokenId, deadline, signature);
    }

    function _safeTransferFromWithPermit(
        address from,
        address to,
        uint256 tokenId,
        uint256 deadline,
        bytes memory signature
    ) internal {
        _permit(msg.sender, tokenId, deadline, signature);
        // safeTransferFrom(from, to, tokenId, "");
        _transfer(from, to, tokenId);
    }
}