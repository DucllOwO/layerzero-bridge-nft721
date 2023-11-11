// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

import "./libraries/InZNFTTypeDetail.sol";
import "./ONFT721Core.sol";
import "./interfaces/IONFT721Core.sol";
import "../lzApp/interfaces/ILayerZeroEndpoint.sol";
import "./interfaces/IONFT721.sol";

contract CampaignTypesNFT721 is
    ONFT721Core,
    ERC721
{
    /**
     *          External using
     */
    using Counters for Counters.Counter;

    /**
     *          Event Definitions
     */
    event TokenCreated(address to, uint256 tokenId);

    struct ReturnMintingOrder {
        uint256 nftType;
        uint256 tokenId;
    }

    event Mint(
        address to
    );
    // /**
    //  *          Storage data declarations
    //  */
    bytes32 internal constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 internal constant DESIGN_ROLE = keccak256("DESIGN_ROLE");
    bytes32 internal constant BURNER_ROLE = keccak256("BURNER_ROLE");

    // Base meta data uri
    string public baseMetadataUri;
    // Campaign Payment Address to receive when mint token
    address public campaignPaymentAddress;

    // Mapping token type to nft type detail object
    mapping (uint8 => InZNFTTypeDetail.NFTTypeDetail) nftTypes;
    // TokenID Counter
    Counters.Counter internal tokenIdCounter;
    // Mapping token's holder address to tokenIds list
    mapping (address => uint256[]) public holders;
    // Mapping token id to token type
    mapping (uint256 => uint8) internal tokenIdsByType;
    // mapping tokenURI to type NFT
    mapping(uint8 => string) public uriByType;
    // mapping NFT creted from Factory
    address internal factoryAddress;

    constructor(
        string memory _name,
        string memory _symbol,
        address _campaignPaymentAddress,
        string memory _baseMetadataUri,
        //address _factoryAddress,
        uint _minGasToStore,
        address _layerZeroEndpoint
    ) public ERC721(_name, _symbol) {
        //__ERC721_init(_name, _symbol);
        campaignPaymentAddress = _campaignPaymentAddress;

        //factoryAddress = _factoryAddress;

        baseMetadataUri = _baseMetadataUri;

        ONFT721Core.initialize(_minGasToStore, _layerZeroEndpoint);
    }

    //function initialize

    function configNFTType(uint8 _nftType,
        uint256 _price,
        uint256 _totalSupply) external {
        InZNFTTypeDetail.NFTTypeDetail memory _nftTypeNew;
        _nftTypeNew.nftType = _nftType;
        if (_totalSupply == 0) {
            _nftTypeNew.totalSupply = 2 ** 256 - 1; // max uint256
        } else {
            _nftTypeNew.totalSupply = _totalSupply;
        }
        _nftTypeNew.price = _price;
        nftTypes[_nftType] = _nftTypeNew;
    }

    // /**
    // * @dev              Mint tokens for id defined (first buy on market)
    // * @param _amount    Amount the user wants to mint
    // * @param _tokenType Type of token to mint
    // * @param _to        Address receive NFT
    // */
    function mint(
        address _to
    ) external {
        // InZNFTTypeDetail.NFTTypeDetail memory nftTypeDetail = nftTypes[_tokenType];
        // require(nftTypeDetail.totalSupply > 0, "Token type does not exist");

        // // Check token type supply
        // uint256 nftTypeRemaining = nftTypeDetail.totalSupply;

        // uint256 _remainNftTypeCurrent = nftTypeRemaining - _amount;

        // require(_remainNftTypeCurrent >= 0, "NFT type sold out");

        // // update total supply of token type in mapping
        // nftTypes[_tokenType].totalSupply = _remainNftTypeCurrent;

        // ReturnMintingOrder[] memory _returnOrder = new ReturnMintingOrder[](_amount);

        // for (uint256 i = 0; i < _amount; ++i) {
        //     uint256 _id = tokenIdCounter.current();
        //     tokenIdCounter.increment();
        //     _safeMint(_to, _id);
        //     // Update user bought list
        //     holders[_to].push(_id);
        //     // Update token id by type
        //     tokenIdsByType[_id] = _tokenType;
        //     emit TokenCreated(_to, _id, _tokenType);
        //     _returnOrder[i] = ReturnMintingOrder(_id, _tokenType);
        // }

        uint256 _id = tokenIdCounter.current();
            tokenIdCounter.increment();
            _safeMint(_to, _id);
            // Update user bought list
            holders[_to].push(_id);
            // Update token id by type
            emit TokenCreated(_to, _id);

        emit Mint(_to);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ONFT721Core, ERC721) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _debitFrom(
        address _from,
        uint16,
        bytes memory,
        uint _tokenId
    ) internal virtual override {
        require(_isApprovedOrOwner(_msgSender(), _tokenId), "ONFT721: send caller is not owner nor approved");
        require(ownerOf(_tokenId) == _from, "ONFT721: send from incorrect owner");
        _transfer(_from, address(this), _tokenId);
    }

    function _creditTo(
        uint16,
        address _toAddress,
        uint _tokenId
    ) internal virtual override {
        require(!_exists(_tokenId) || (_exists(_tokenId) && ownerOf(_tokenId) == address(this)));
        if (!_exists(_tokenId)) {
            _safeMint(_toAddress, _tokenId);
        } else {
            _transfer(address(this), _toAddress, _tokenId);
        }
    }

    // Get NFT IDs by owner
    function getNftIdsByOwner(address _owner)
        external
        view
        returns (uint256[] memory)
    {
        uint256[] memory ids = holders[_owner];
        return ids;
    }

    /**
     *      Function that gets latest ID of this NFT contract
     *      @return tokenId of latest NFT
     */
    function lastId() public view returns (uint256) {
        return tokenIdCounter.current();
    }

    /** Burns a list  nft ids. */
    function burn(uint256[] memory ids) external {
        for (uint256 i = 0; i < ids.length; ++i) {
            _burn(ids[i]);
        }
    }

    function setCampaignPaymentAddress(address _campaignPaymentAddress) external {
        campaignPaymentAddress = _campaignPaymentAddress;
    }

    /**
     *  @notice Function get factory address
     */
    function getFactoryAddress() external view returns (address) {
        return factoryAddress;
    }

    function getPaymentAddress() external  view   returns (address){
        return campaignPaymentAddress;
    }
    /**
     * @notice Checks if address is a contract
     * @dev It prevents contract from being targetted
     */
    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}
