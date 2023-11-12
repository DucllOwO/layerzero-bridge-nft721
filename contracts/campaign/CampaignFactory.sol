// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";


import "./CampaignTypesNFT721.sol";
import "./libraries/InZNFTTypeDetail.sol";

contract CampaignFactory is AccessControl {

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

    event SetConfiguration(address newConfiguration);

    /**
     *          Storage data declarations
     */
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    // InZCampaigns Address list
    address[] public inZNftCampaignsAddress;

    address public onft721ImplementationAddress;

    constructor(address _implementationAddress) {
        onft721ImplementationAddress = _implementationAddress;

        _setupRole(ADMIN_ROLE, msg.sender);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    } 

    /**
     * Create instance of InZCampaign;
     * @param _campaignPaymentAddress payment address to receive coinToken when nft have sold
     * @param _coinToken currency that KOLs want to sell nft campaign
     * @param _symbol symbol of this campaign
     * @param _name name of this campaign
     */
    function createCampaign(
        address _campaignPaymentAddress,
        string memory _baseMetadataUri,
        IERC20 _coinToken,
        string memory _symbol,
        string memory _name,
        InZNFTTypeDetail.NFTTypeDetail[] memory _nftTypesDetail,
        uint _minGasToStore,
        address _layerZeroEndpoint
    ) external {
        address campaign;
        campaign = Clones.clone(onft721ImplementationAddress);

        CampaignTypesNFT721(campaign).initialize(
            _name,
            _symbol,
            _campaignPaymentAddress,
            _baseMetadataUri,
            address(this),
            msg.sender,
            _minGasToStore,
            _layerZeroEndpoint
        );

        // Config prices, supply for each type
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

    function getCollectionAddress(uint index) external view returns (address) {

        return inZNftCampaignsAddress[index];
    }

    /**
     *              SETTERS
     */
    function setImplementationAddress(address _newImplementationAddress) external onlyRole(ADMIN_ROLE) {
        onft721ImplementationAddress = _newImplementationAddress;
    }

    /**
     *              INHERITANCE FUNCTIONS
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

}
