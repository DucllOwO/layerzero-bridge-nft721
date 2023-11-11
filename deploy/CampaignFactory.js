const { ethers } = require("hardhat")
const LZ_ENDPOINTS = require("../constants/layerzeroEndpoints.json")

// deploy command: npx hardhat deploy CampaignFactory --network mumbai --tags CampaignFactory

module.exports = async function ({ deployments, getNamedAccounts }) {
    const { deploy } = deployments
    const { deployer } = await getNamedAccounts()
    console.log(`>>> your address: ${deployer}`)

    const lzEndpointAddress = LZ_ENDPOINTS[hre.network.name]
    console.log(`[${hre.network.name}] Endpoint Address: ${lzEndpointAddress}`)

    const name = "ONFT721"
    const symbol = "SYM"
    const minGasToStore = 100000
    const nftTypeDetails = [{ nftType: 0, price: 1000, totalSupply: 100000 }]

    // console.log("🚀 ~ file: CampaignFactory.js:25 ~ nft721Implementation:", nft721Implementation.address)

    const campaignFactory = await deploy("CampaignFactory", {
        from: deployer,
        args: [],
        log: true,
        waitConfirmations: 1,
    })

    console.log("🚀 ~ file: CampaignTypesNFT721.js:26 ~ campaignFactory:", campaignFactory.address)

    const _campaignPaymentAddress = "0x29E754233F6A50ee5AE3ee6A0217aD907dc3386B"
    const _baseMetadataUri = "baseURI.com/uri"
    const erc20 = "0x0000000000000000000000000000000000001010"

    let contract = await ethers.getContract("CampaignFactory")

    //const campaignTypesNFT721 = await contract.getCollectionAddress(0)
    const campaignTypesNFT721 = await contract.createCampaign(
        _campaignPaymentAddress,
        _baseMetadataUri,
        erc20,
        symbol,
        name,
        minGasToStore,
        lzEndpointAddress,
        { gasLimit: 1500000 }
    )

    const txCampaign = await campaignTypesNFT721.wait()

    console.log("🚀 ~ file: CampaignFactory.js:49 ~ txCampaign:", txCampaign.events)

    console.log("🚀 ~ file: CampaignFactory.js:49 ~ txCampaign:", JSON.stringify(txCampaign.events))
}

module.exports.tags = ["CampaignFactory"]
