// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";


import "./CampaignTypesNFT721.sol";
import "./libraries/InZNFTTypeDetail.sol";

contract CampaignFactory {
    using EnumerableSet for EnumerableSet.AddressSet;

    /**
     *          Event Definitions
     */
    event NewNFT(
        address campaignAddress,
        address campaignPaymentAddress,
        IERC20 coinToken,
        string symbol,
        string name,
        address adminAddress
    );

    /**
     *          Storage data declarations
     */
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    // List of NFT collections
    EnumerableSet.AddressSet private nftCollectionsList;

    address public onft721ImplementationAddress;

    constructor(address _implementationAddress) {
        onft721ImplementationAddress = _implementationAddress;
    } 


    // /**
    //  * Create instance of InZCampaign;
    //  * @param _campaignPaymentAddress payment address to receive coinToken when nft have sold
    //  * @param _coinToken currency that KOLs want to sell nft campaign
    //  * @param _symbol symbol of this campaign
    //  * @param _name name of this campaign
    //  */
    // function createCampaign(
    //     address _campaignPaymentAddress,
    //     string memory _baseMetadataUri,
    //     IERC20 _coinToken,
    //     string memory _symbol,
    //     string memory _name,
    //     InZNFTTypeDetail.NFTTypeDetail[] memory _nftTypesDetail,
    //     uint _minGasToStore,
    //     address _layerZeroEndpoint
    // ) external {
    //     address campaign;
    //     campaign = Clones.clone(onft721ImplementationAddress); 
    //     //Clones.clone(onft721ImplementationAddress);

    //     CampaignTypesNFT721(campaign).initialize(
    //         _name,
    //         _symbol,
    //         _campaignPaymentAddress,
    //         _baseMetadataUri,
    //         address(this),
    //         _minGasToStore,
    //         _layerZeroEndpoint
    //     );

    //     nftCollectionsList.add(address(campaign));

    //     // Config prices
    //     // for (uint i = 0; i < _nftTypesDetail.length; i++) {
    //     //     CampaignTypesNFT721(campaign).configNFTType(_nftTypesDetail[i].nftType, _nftTypesDetail[i].price, _nftTypesDetail[i].totalSupply);
    //     // }

    //     emit NewNFT(
    //         address(campaign),
    //         _campaignPaymentAddress,
    //         _coinToken,
    //         _symbol,
    //         _name,
    //         msg.sender
    //     );
    // }

    function getCollectionAddress(
    ) external pure returns (address) {

        return address(0x0);
    }

}
