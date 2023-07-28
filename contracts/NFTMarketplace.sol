// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/Counters.sol";
//import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
//import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
//import "hardhat/console.sol";
//import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
//import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "./NFTCollection.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "@routerprotocol/evm-gateway-contracts@1.1.11/contracts/IDapp.sol";
import "@routerprotocol/evm-gateway-contracts@1.1.11/contracts/IGateway.sol";
import "./ICollection.sol";

contract NFTMarketplace is IDapp {
    using Counters for Counters.Counter;
    Counters.Counter private _nftId;
    Counters.Counter private _itemsSold;
    address payable owner;

    uint256 public listPrice = 0.1 ether;

    // address of the gateway contract
    IGateway public gatewayContract;

    // chain type + chain id => address of our contract in string format
    //chain id to nft contract
    mapping(string => string) public ourContractOnChains;

    // name of the chain
    string public chainId;

    // gas limit required to handle cross-chain request on the destination chain
    uint64 public _destGasLimit;

       bytes4 immutable CROSS_CHAIN_LIST_SELECTOR =
        bytes4(keccak256("listToken(uint256, uint256, address)"));
    bytes4 immutable CROSS_CHAIN_DELIST_SELECTOR =
        bytes4(keccak256("cancelListing(address, uint256)")); e
    bytes4 immutable CROSS_CHAIN_PURCHASE_SELECTOR =
        bytes4(
            keccak256(
                "executeSale(uint256, address)"
            )
        ); 
    bytes4 immutable CROSS_CHAIN_MINT_SELECTOR =
        bytes4(keccak256("_mintOnRemote(address, string, address)"));

    struct ListedToken {
        uint256 nftId;
        uint256 tokenId;
        address payable owner;
        address payable seller;
        uint256 price;
        bool currentlyListed;
    }

    event TokenListedSuccess(
        uint256 nftId,
        uint256 tokenId,
        address payable owner,
        address payable seller,
        uint256 price,
        bool currentlyListed
    );

    mapping(NFTCollection => mapping(uint256 => ListedToken)) public nft_record;
    mapping(uint256 => ListedToken) public id_listed_token;

    constructor(
        address getewayAddress,
        string memory feePayerAddress,
        string memory _chainId,
    ) {
        chainId = _chainId;
        gatewayContract = IGateway(getewayAddress);
        owner = payable(msg.sender);

        // setting metadata for dapp
        gatewayContract.setDappMetadata(feePayerAddress);
    }

    function ListToken(
        uint256 tokenId,
        uint256 price,
        NFTCollection collection
    ) public payable {
        require(msg.value == listPrice, "Please send the listing fees");
        require(price > 0, "Make sure the price isn't negative");
        uint256 nftId = _nftId.current();

        nft_record[collection][tokenId] = ListedToken(
            nftId,
            tokenId,
            payable(address(this)),
            payable(msg.sender),
            price,
            true
        );

        id_listed_token[nftId] = nft_record[collection][tokenId];

        collection.transferFrom(msg.sender, address(this), tokenId);

        emit TokenListedSuccess(
            nftId,
            tokenId,
            payable(address(this)),
            payable(msg.sender),
            price,
            true
        );
        _nftId.increment();
    }

    function cancelListing(NFTCollection collection, uint256 tokenId) public {
        require(
            nft_record[collection][tokenId].currentlyListed,
            "This NFT is not listed"
        );
        require(
            nft_record[collection][tokenId].seller == msg.sender,
            "You are not the owner of this nft"
        );

        nft_record[collection][tokenId].owner = payable(msg.sender);
        nft_record[collection][tokenId].seller = payable(address(0));
        nft_record[collection][tokenId].price = 0;
        nft_record[collection][tokenId].currentlyListed = false;

        collection.transferFrom(address(this), msg.sender, tokenId);
        payable(msg.sender).transfer(listPrice);
    }

    function executeSale(
        uint256 tokenId,
        NFTCollection collection
    ) public payable {
        ListedToken storage nft = nft_record[collection][tokenId];
        uint256 price = nft.price;
        address seller = nft.seller;
        require(
            msg.value == price,
            "Please submit the asking price in order to complete the purchase"
        );

        //update the details of the token
        nft.currentlyListed = false;
        nft.seller = payable(msg.sender);
        _itemsSold.increment();

        //Actually transfer the token to the new owner
        collection.transferFrom(address(this), msg.sender, tokenId);
        uint256 royalty = collection.get_royalty() / 1000;
        uint256 calc_royalty = (price * royalty) / 100;

        address col_owner = collection.get_collection_owner();
        payable(col_owner).transfer(calc_royalty);

        //Transfer the listing fee to the marketplace creator
        payable(owner).transfer(listPrice);
        uint256 remaining_bal = price - calc_royalty;
        payable(seller).transfer(remaining_bal);
    }

    function execute_sale_existing_col(
        uint256 tokenId,
        NFTCollection collection,
        uint256 _royalty,
        uint256 _price,
        address collection_owner,
        address nft_holder
    ) public {
        //Actually transfer the token to the new owner
        collection.transferFrom(address(this), msg.sender, tokenId);
        uint256 royalty = _royalty / 1000;
        uint256 calc_royalty = (_price * royalty) / 100;

        payable(collection_owner).transfer(calc_royalty);

        //Transfer the listing fee to the marketplace creator
        payable(owner).transfer(listPrice);
        uint256 remaining_bal = _price - calc_royalty;
        payable(nft_holder).transfer(remaining_bal);
    }

    function change_listing_fee(uint256 new_listing_fee) public {
        require(
            msg.sender == owner,
            "Only platform owner can call this function"
        );
        listPrice = new_listing_fee;
    }

    function getAllNFTs() public view returns (ListedToken[] memory) {
        uint256 nftCount = _nftId.current();
        ListedToken[] memory nfts = new ListedToken[](nftCount);
        uint256 currentIndex = 0;
        for (uint256 i = 0; i < nftCount; i++) {
            if (id_listed_token[i].owner != address(0)) {
                ListedToken memory currentToken = id_listed_token[i];
                nfts[currentIndex] = currentToken;
                currentIndex++;
            }
        }
        return nfts;
    }

    function getMyNFTs() public view returns (ListedToken[] memory) {
        uint256 totalItemCount = _nftId.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (
                id_listed_token[i].owner == msg.sender ||
                id_listed_token[i].seller == msg.sender
            ) {
                itemCount += 1;
            }
        }

        ListedToken[] memory items = new ListedToken[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (
                id_listed_token[i].owner == msg.sender ||
                id_listed_token[i].seller == msg.sender
            ) {
                uint256 currentId = i;
                ListedToken storage currentItem = id_listed_token[currentId];
                items[currentIndex] = currentItem;
                currentIndex++;
            }
        }
        return items;
    }

    function changeListingFee(uint256 new_listing_fee) public {
        require(
            msg.sender == owner,
            "You are not the owner of this marketplace"
        );
        listPrice = new_listing_fee;
    }

    function getListPrice() public view returns (uint256) {
        return listPrice;
    }

    function _mintOnRemote(address _recipient, string memory _tokenURI, address _nftAddress) internal returns (uint) {
        ICollection(_nftAddress).mintTo(_recipient, _nftAddress);
    }

    function getLatestIdToListedToken()
        public
        view
        returns (ListedToken memory)
    {
        uint256 currentTokenId = _nftId.current();
        return id_listed_token[currentTokenId];
    }

    function getListedTokenById(
        uint256 tokenId,
        NFTCollection collection
    ) public view returns (ListedToken memory) {
        return nft_record[collection][tokenId];
    }

    function getCurrentToken() public view returns (uint256) {
        return _nftId.current();
    }

    function crossChainList(
        string calldata destChainId,
        uint256 tokenId,
        uint256 price,
        address collectionAddr,
        bytes calldata requestMetaData
    ) public payable {
         require(
            keccak256(abi.encodePacked(ourContractOnChains[destChainId])) !=
                keccak256(abi.encodePacked("")),
            "contract on dest not set"
        );

          require(
      ICollection(collectionAddr).ownerOf(tokenId) == msg.sender,
      "caller is not the owner"
    );

    bytes memory packet = abi.encode(tokenId, price, collectionAddr);
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

    function crossChainDelist() public payable {
    
    }

    function crossChainPurchase() public payable {

    }

    function crossChainPurchaseFromCollection() public payable {

    }

    function crosschainMint(
        string calldata destChainId,
        string calldata recipient,
        string memory _tokenURI
        bytes calldata requestMetaData
    ) public payable {
        require(
            keccak256(abi.encodePacked(ourContractOnChains[destChainId])) !=
                keccak256(abi.encodePacked("")),
            "contract on dest not set"
        ); 
    bytes memory packet = abi.encode(recipient, _tokenURI);
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

    function crossChainTransferNft(string calldata destChainId,
        uint256 tokenId,
        NFTCollection collectionAddr,
        string calldata recipient,
        bytes calldata requestMetaData) public payable {
         require(
            keccak256(abi.encodePacked(ourContractOnChains[destChainId])) !=
                keccak256(abi.encodePacked("")),
            "contract on dest not set"
        );

          require(
      collectionAddr.ownerOf(tokenId) == msg.sender,
      "caller is not the owner"
    ); 
      collectionAddr.transferCrossChain(destChainId, tokenId, recipient, requestMetaData);
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

    function toBytes(address a) public pure returns (bytes memory b) {
        assembly {
            let m := mload(0x40)
            a := and(a, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
            mstore(
                add(m, 20),
                xor(0x140000000000000000000000000000000000000000, a)
            )
            mstore(0x40, add(m, 52))
            b := m
        }
    }

    receive() external payable {}
}
