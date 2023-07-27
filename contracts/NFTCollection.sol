//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "@routerprotocol/evm-gateway-contracts/contracts/IDapp.sol";
import "@routerprotocol/evm-gateway-contracts/contracts/IGateway.sol";

import "@openzeppelin/contracts/utils/Counters.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
//import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTCollection is ERC721URIStorage, IDapp {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    uint256 public collectionRoyalty;
    address collectionOwner;

    event TokenCreated(
    string ipfsURL,
    uint256 tokenId
    );

    address public owner;
    IGateway public gatewayContract;

    //Cross-chain NFT Marketplace Allow buying any NFT from any chain and selling 
    //any NFT on any chain. The markets should be focused on natively cross-chain NFTs.

    //mapping(string => uint8) private _hashes;
    mapping(uint256 => uint8) private _tokenIds;

    // chain type + chain id => address of our contract in string format
    //chain id to nft contract
    mapping(string => string) public ourContractOnChains;
    
  // gas limit required to handle cross-chain request on the destination chain
  uint64 public _destGasLimit;

    // transfer params struct where we specify which NFTs should be transferred to
    // the destination chain and to which address
    struct TransferParams {
        uint256 nftId;
        //uint256[] nftAmounts;
        //bytes nftData;
        bytes recipient;
        string uri;
    }

    
//   struct TransferTemp{
//     uint256 nftId;
//     string uri;
//   }

    constructor(
        string memory _name,
        string memory _symbol,
        address payable gatewayAddress,
        string memory feePayerAddress,
        uint256 _royalty,
        address _collectionOwner
    ) ERC721(_name, _symbol) {
        require(_royalty < 10000, "Royalty should be less than 10%");
        collectionRoyalty = _royalty;
        collectionOwner = _collectionOwner;
        
        gatewayContract = IGateway(gatewayAddress);
        owner = msg.sender;

        // // minting ourselves some NFTs so that we can test out the contracts
        // _mint(msg.sender, 1, 10, "");

        gatewayContract.setDappMetadata(feePayerAddress);
    }

     function get_royalty() public view returns (uint256) {
        return collectionRoyalty;
    }

    function get_collection_owner() public view returns (address) {
        return collectionOwner;
    }
    
// function publicMint(address to, uint256 tokenId, string memory uri) public 
//     {
//       // require(msg.sender == owner, "only owner");
//         _safeMint(to, tokenId);
//         _setTokenURI(tokenId, uri);
//     }

    function createToken(
        // address to,
        // uint256 tokenId,
        //string memory assetHash,
        string memory tokenURI
    ) external {
        require(msg.sender == owner, "only owner");

        // _safeMint(to, tokenId);
        // _setTokenURI(tokenId, tokenURI);
        uint256 newTokenId = _tokenIds.current();
        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        _tokenIds.increment();

        emit TokenCreated(tokenURI, newTokenId);
        return newTokenId;
    }

     function mintTo(address receiver, string memory _tokenURI) external returns(uint) {
        _nextTokenId.increment();
        uint currentId = _nextTokenId.current();
        _safeMint(receiver, currentId);
        _setTokenURI(currentId, _tokenURI);
        return(currentId);
    }

      function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721URIStorage, ERC721)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    /// @notice function to set the address of our NFT contracts on different chains.
    /// This will help in access control when a cross-chain request is received.
    /// @param chainId chain Id of the destination chain in string.
    /// @param contractAddress address of the NFT contract on the destination chain.
    function setContractOnChain(
        string[] calldata chainIds,
        string[] calldata contractAddresses
    ) external {
        require(msg.sender == owner, "only owner");
        ourContractOnChains[chainId] = contractAddress;

        require(chainIds.length == contractAddresses.length, "chainIds and contractAddresses arrays length mismatch");

         for (uint256 i = 0; i < chainIds.length; i++) {
      ourContractOnChains[chainIds[i]] = contractAddresses[i];
    }
    }

    /// @notice function to set the Router Gateway Contract.
    /// @param gateway address of the Gateway contract.
    function setGateway(address gateway) external {
        require(msg.sender == owner, "only owner");
        gatewayContract = IGateway(gateway);
    }

     function _burn(uint256 tokenId) internal override(ERC721URIStorage, ERC721) {
        super._burn(tokenId);
    }

    /// @notice function to set the fee payer address on Router Chain.
    /// @param feePayerAddress address of the fee payer on Router Chain.
    function setDappMetadata(string memory feePayerAddress) external {
        require(msg.sender == owner, "only owner");
        gatewayContract.setDappMetadata(feePayerAddress);
    }

    /// @notice function to generate a cross-chain NFT transfer request.
    /// @param destChainId chain ID of the destination chain in string.
    /// @param _tokenId nft token ID.
     /// @param _recipient recipient of token ID on destination chain.
    /// @param requestMetadata abi-encoded metadata according to source and destination chains
    function transferCrossChain(
        string calldata destChainId,
        //TransferParams calldata transferParams,
        uint256 _tokenId,
        address _recipient,
        bytes calldata requestMetadata
    ) public payable {
        require(
            keccak256(abi.encodePacked(ourContractOnChains[destChainId])) !=
                keccak256(abi.encodePacked("")),
            "contract on dest not set"
        );

      require(
      _ownerOf(transferParams.nftId) == msg.sender,
      "caller is not the owner"
    );
    TransferParams memory transferParams;
    transferParams.nftId = _tokenId;
    transferParams.recipient = toBytes(_recipient);
    transferParams.uri = super.tokenURI(tokenId);
        // burning the NFTs from the address of the user calling _burnBatch function
        _burn(
            transferParams.nftId
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
        string memory requestSender,
        bytes memory packet,
        string memory srcChainId
    ) external override returns (bytes memory) {
        require(msg.sender == address(gatewayContract), "only gateway");
        require(
      keccak256(bytes(ourContractOnChains[srcChainId])) ==
        keccak256(bytes(requestSender))
    );
        // decoding our payload
        TransferParams memory transferParams = abi.decode(
            packet,
            (TransferParams)
        );
        safeMint(
            toAddress(transferParams.recipient),
            transferParams.nftId,
            transferParams.uri
        );
        
        //return abi.encode(srcChainId);
        
    return "";
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
