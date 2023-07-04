//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "@routerprotocol/evm-gateway-contracts/contracts/IDapp.sol";
import "@routerprotocol/evm-gateway-contracts/contracts/IGateway.sol";

import "@openzeppelin/contracts/utils/Counters.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

contract NFToken is ERC721URIStorage, IDapp {
    address public owner;
    IGateway public gatewayContract;

    mapping(string => uint8) private _hashes;
    mapping(uint256 => uint8) private _tokenIds;

    // chain type + chain id => address of our contract in string format
    //chain id to nft contract
    mapping(string => string) public ourContractOnChains;

    struct TransferParams {
        uint256 nftId;
        //uint256[] nftAmounts;
        bytes nftData;
        bytes recipient;
    }

    constructor(
        string memory _name,
        sring memory _symbol,
        address payable gatewayAddress,
        string memory feePayerAddress
    ) ERC721(_name, _symbol) {
        gatewayContract = IGateway(gatewayAddress);
        owner = msg.sender;

        // minting ourselves some NFTs so that we can test out the contracts
        _mint(msg.sender, 1, 10, "");

        gatewayContract.setDappMetadata(feePayerAddress);
    }

    function mint(uint256 tokenId) external {
        require(_tokenIds[tokenId] != 1, "token ID already exists");
        _tokenIds[tokenId] = 1;
        _safeMint(_msgSender(), tokenId);
    }

    function mintWithMetadata(
        uint256 tokenId,
        string memory assetHash,
        string memory tokenURI
    ) external {
        require(_tokenIds[tokenId] != 1, "token ID already exists");
        _tokenIds[tokenId] = 1;

        require(_hashes[assetHash] != 1, "hash already exists");
        _hashes[assetHash] = 1;

        _safeMint(_msgSender(), tokenId);
        _setTokenURI(tokenId, tokenURI);
    }

    function setContractOnChain(
        string calldata chainId,
        string calldata contractAddress
    ) external {
        require(msg.sender == owner, "only admin");
        ourContractOnChains[chainId] = contractAddress;
    }

    /// @notice function to set the Router Gateway Contract.
    /// @param gateway address of the Gateway contract.
    function setGateway(address gateway) external {
        require(msg.sender == owner, "only owner");
        gatewayContract = IGateway(gateway);
    }

    /// @notice function to set the fee payer address on Router Chain.
    /// @param feePayerAddress address of the fee payer on Router Chain.
    function setDappMetadata(string memory feePayerAddress) external {
        require(msg.sender == owner, "only owner");
        gatewayContract.setDappMetadata(feePayerAddress);
    }

    /// @notice function to generate a cross-chain NFT transfer request.
    /// @param destChainId chain ID of the destination chain in string.
    /// @param transferParams transfer params struct.
    /// @param requestMetadata abi-encoded metadata according to source and destination chains
    function transferCrossChain(
        string calldata destChainId,
        TransferParams calldata transferParams,
        bytes calldata requestMetadata
    ) public payable {
        require(
            keccak256(abi.encodePacked(ourContractOnChains[destChainId])) !=
                keccak256(abi.encodePacked("")),
            "contract on dest not set"
        );

        // burning the NFTs from the address of the user calling _burnBatch function
        _burnBatch(
            msg.sender,
            transferParams.nftIds,
            transferParams.nftAmounts
        );

        // sending the transfer params struct to the destination chain as payload.
        bytes memory packet = abi.encode(transferParams);
        bytes memory requestPacket = abi.encode(
            ourContractOnChains[destChainId],
            packet
        );

        gatewayContract.iSend{value: msg.value}(
            1,
            0,
            string(""),
            destChainId,
            requestMetadata,
            requestPacket
        );
    }

    /// @notice function to get the request metadata to be used while initiating cross-chain request
    /// @return requestMetadata abi-encoded metadata according to source and destination chains
    function getRequestMetadata(
        uint64 destGasLimit,
        uint64 destGasPrice,
        uint64 ackGasLimit,
        uint64 ackGasPrice,
        uint128 relayerFees,
        uint8 ackType,
        bool isReadCall,
        bytes memory asmAddress
    ) public pure returns (bytes memory) {
        bytes memory requestMetadata = abi.encodePacked(
            destGasLimit,
            destGasPrice,
            ackGasLimit,
            ackGasPrice,
            relayerFees,
            ackType,
            isReadCall,
            asmAddress
        );
        return requestMetadata;
    }

    /// @notice function to handle the cross-chain request received from some other chain.
    /// @param packet the payload sent by the source chain contract when the request was created.
    /// @param srcChainId chain ID of the source chain in string.
    function iReceive(
        string memory, // requestSender,
        bytes memory packet,
        string memory srcChainId
    ) external override returns (bytes memory) {
        require(msg.sender == address(gatewayContract), "only gateway");
        // decoding our payload
        TransferParams memory transferParams = abi.decode(
            packet,
            (TransferParams)
        );
        _mintBatch(
            toAddress(transferParams.recipient),
            transferParams.nftIds,
            transferParams.nftAmounts,
            transferParams.nftData
        );

        return abi.encode(srcChainId);
    }

    /// @notice function to handle the acknowledgement received from the destination chain
    /// back on the source chain.
    /// @param requestIdentifier event nonce which is received when we create a cross-chain request
    /// We can use it to keep a mapping of which nonces have been executed and which did not.
    /// @param execFlag a boolean value suggesting whether the call was successfully
    /// executed on the destination chain.
    /// @param execData returning the data returned from the handleRequestFromSource
    /// function of the destination chain.
    function iAck(
        uint256 requestIdentifier,
        bool execFlag,
        bytes memory execData
    ) external override {}

    /// @notice Function to convert bytes to address
    /// @param _bytes bytes to be converted
    /// @return addr address pertaining to the bytes
    function toAddress(
        bytes memory _bytes
    ) internal pure returns (address addr) {
        bytes20 srcTokenAddress;
        assembly {
            srcTokenAddress := mload(add(_bytes, 0x20))
        }
        addr = address(srcTokenAddress);
    }
}
