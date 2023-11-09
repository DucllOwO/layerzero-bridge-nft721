// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721RoyaltyUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "./libraries/InZNFTTypeDetail.sol";
import "./interfaces/IInZNFTMarket.sol";
import "./libraries/InterfaceFunction.sol";
import "./interfaces/IFactory.sol";


contract CampaignTypesNFT721 is
    ERC721Upgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    ERC721RoyaltyUpgradeable,
    OwnableUpgradeable

{
    /**
     *          External using
     */
    using Counters for Counters.Counter;

    /**
     *          Event Definitions
     */
    event TokenCreated(address to, uint256 tokenId, uint256 tokenType);

    struct ReturnMintingOrder {
        uint256 nftType;
        uint256 tokenId;
    }

    event Mint(
        string callbackData,
        address to,
        ReturnMintingOrder[] returnMintingOrder
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

    /**
     * @notice Checks if the msg.sender is a contract or a proxy
     */
    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    /**
     *          Contract Initialization
     */
    function initialize(
        address _campaignPaymentAddress,
        string memory _symbol,
        string memory _name,
        string memory _baseMetadataUri,
        address _adminAddress,
        address _factoryAddress
    ) external initializer {
        __ERC721_init(_name, _symbol);
        __AccessControl_init();
        __UUPSUpgradeable_init();
        _transferOwnership(_adminAddress);

        campaignPaymentAddress = _campaignPaymentAddress;

        factoryAddress = _factoryAddress;

        baseMetadataUri = _baseMetadataUri;

        _setupRole(ADMIN_ROLE, _adminAddress);
        _setupRole(DEFAULT_ADMIN_ROLE, _adminAddress);

        _setupRole(DESIGN_ROLE, _adminAddress);
        _setupRole(BURNER_ROLE, _adminAddress);
    }

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

    /**
    * @dev              Mint tokens for id defined (first buy on market)
    * @param _amount    Amount the user wants to mint
    * @param _tokenType Type of token to mint
    * @param _to        Address receive NFT
    */
    function mint(
        uint256 _amount,
        uint8 _tokenType,
        address _to,
        string calldata _callbackData
    ) external {
        InZNFTTypeDetail.NFTTypeDetail memory nftTypeDetail = nftTypes[_tokenType];
        require(nftTypeDetail.totalSupply > 0, "Token type does not exist");

        // Check token type supply
        uint256 nftTypeRemaining = nftTypeDetail.totalSupply;

        uint256 _remainNftTypeCurrent = nftTypeRemaining - _amount;

        require(_remainNftTypeCurrent >= 0, "NFT type sold out");

        // update total supply of token type in mapping
        nftTypes[_tokenType].totalSupply = _remainNftTypeCurrent;

        ReturnMintingOrder[] memory _returnOrder = new ReturnMintingOrder[](_amount);

        for (uint256 i = 0; i < _amount; ++i) {
            uint256 _id = tokenIdCounter.current();
            tokenIdCounter.increment();
            _safeMint(_to, _id);
            // Update user bought list
            holders[_to].push(_id);
            // Update token id by type
            tokenIdsByType[_id] = _tokenType;
            emit TokenCreated(_to, _id, _tokenType);
            _returnOrder[i] = ReturnMintingOrder(_id, _tokenType);
        }

        emit Mint(_callbackData, _to, _returnOrder);
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
     *          INTERNAL FUNCTION
     */
    function _authorizeUpgrade(address newImplementation)
    internal
    override
    onlyRole(ADMIN_ROLE)
    {}

    /**
     *      Function that gets latest ID of this NFT contract
     *      @return tokenId of latest NFT
     */
    function lastId() public view returns (uint256) {
        return tokenIdCounter.current();
    }

    /**
     *  @notice     This function is only used for estimation purpose, therefore the call will always revert and encode the result in the revert data.
     *  @dev        This function's used for estimate gas for a execution call
     *  @param to           The address of caller
     *  @param value        The value of msg.value
     *  @param data         The data sent with tx
     *  @param operation    the operation of tx
     */
    function requiredTxGas(
        address to,
        uint256 value,
        bytes calldata data,
        InterfaceFunction.Operation operation
    )
        external
        onlyRole(ADMIN_ROLE)
        // returns (uint256)
    {
        InterfaceFunction.requiredTxGas(to, value, data, operation);
    }

    /**
     * This function allow ADMIN can execute a function witj specificed logic and params flexibily
     * @param to The caller of tx
     * @param value The msg.value of tx
     * @param txGas The estimated gas using for the tx
     * @param data The data comming with the tx
     * @param operation The operation of tx
     */
    function execTx(
        address to,
        uint256 value,
        uint256 txGas,
        bytes calldata data,
        InterfaceFunction.Operation operation
    )
        external
        onlyRole(ADMIN_ROLE)
    {
        InterfaceFunction.execTx(to, value, txGas, data, operation);
    }

    /** Burns a list  nft ids. */
    function burn(uint256[] memory ids) external onlyRole(BURNER_ROLE) {
        for (uint256 i = 0; i < ids.length; ++i) {
            _burn(ids[i]);
        }
    }

    function setCampaignPaymentAddress(address _campaignPaymentAddress) external onlyRole(DESIGN_ROLE) {
        campaignPaymentAddress = _campaignPaymentAddress;
    }

    /**
     *      INHERITANCE FUNCTIONS
     */
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(
            ERC721Upgradeable,
            AccessControlUpgradeable,
            ERC721RoyaltyUpgradeable
        )
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _burn(
        uint256 tokenId
    ) internal override(ERC721Upgradeable, ERC721RoyaltyUpgradeable) {
        super._burn(tokenId);
        _resetTokenRoyalty(tokenId);
    }

    /**
     *  @notice Function get factory address
     */
    function getFactoryAddress() external view onlyRole(ADMIN_ROLE) returns (address) {
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
