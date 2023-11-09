// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./CampaignTypesNFT721.sol";
import "./libraries/InZNFTTypeDetail.sol";

contract CampaignFactory is AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    /**
     *          Event Definitions
     */
    event NewNFT(
        address campaignAddress,
        address campaignPaymentAddress,
        InZNFTTypeDetail.NFTTypeDetail[] nftTypesDetail,
        IERC20 coinToken,
        string symbol,
        string name,
        address adminAddress
    );

    /**
     *          Storage data declarations
     */
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    // InZCampaigns Address list
    address[] public inZNftCampaignsAddress;

    // implementAddress for NFT
    address public nftImplementationAddressERC721;


    // List of NFT collections
    EnumerableSet.AddressSet private nftCollectionsList;

    /**
     *          Contructor of the contract
     */
    constructor(address _nftImplementationAddressERC721) {
        nftImplementationAddressERC721 = _nftImplementationAddressERC721;

        _setupRole(ADMIN_ROLE, msg.sender);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * Create instance of InZCampaign;
     * @param _campaignPaymentAddress payment address to receive coinToken when nft have sold
     * @param _coinToken currency that KOLs want to sell nft campaign
     * @param _symbol symbol of this campaign
     * @param _name name of this campaign
     * @param _nftTypesDetail nft type detail
     */
    function createCampaign(
        address _campaignPaymentAddress,
        string memory _baseMetadataUri,
        IERC20 _coinToken,
        string memory _symbol,
        string memory _name,
        InZNFTTypeDetail.NFTTypeDetail[] memory _nftTypesDetail
    ) external {

        address campaign;
        campaign = Clones.clone(nftImplementationAddressERC721);

        CampaignTypesNFT721(campaign).initialize(
            _campaignPaymentAddress,
            _symbol,
            _name,
            _baseMetadataUri,
            msg.sender,
            address(this)
        );

        nftCollectionsList.add(campaign);

        // Config prices
        for (uint i = 0; i < _nftTypesDetail.length; i++) {
            CampaignTypesNFT721(campaign).configNFTType(_nftTypesDetail[i].nftType, _nftTypesDetail[i].price, _nftTypesDetail[i].totalSupply);
        }

        inZNftCampaignsAddress.push(address(campaign));

        emit NewNFT(
            address(campaign),
            _campaignPaymentAddress,
            _nftTypesDetail,
            _coinToken,
            _symbol,
            _name,
            msg.sender
        );
    }

    // function grantRoles(address _contract, )

    /**
     *              INHERITANCE FUNCTIONS
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     *              GETTERS
     */
    function getAllNFTCampaign()
        external
        view
        onlyRole(ADMIN_ROLE)
        returns (address[] memory)
    {
        return inZNftCampaignsAddress;
    }

    function getCollectionAddress(
        uint256 index
    ) external view returns (address) {
        return nftCollectionsList.at(index);
    }

    function isValidNftCollection(
        address _nftCollection
    ) external view returns (bool) {
        return nftCollectionsList.contains(_nftCollection);
    }

    /**
     * SETTERS
     */

    function setImplementationAddressNFT721(address _implementationNFT721) external onlyRole(ADMIN_ROLE) {
        nftImplementationAddressERC721 = _implementationNFT721;
    }
}
