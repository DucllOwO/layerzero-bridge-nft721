const LZ_ENDPOINTS = require("../constants/layerzeroEndpoints.json")

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

    const campaignFactory = await deploy("CampaignFactory", {
        from: deployer,
        args: [],
        log: true,
        waitConfirmations: 1,
    })
    console.log("🚀 ~ file: CampaignTypesNFT721.js:21 ~ campaignFactory:", campaignFactory)

    const _campaignPaymentAddress = "0x29E754233F6A50ee5AE3ee6A0217aD907dc3386B"
    const _baseMetadataUri = "baseURI.com/uri"
    const erc20 = "0x2f3f0589021d202e9fbb48cb17b23961b9ef75b3"

    const campaignTypesNFT721 = await campaignFactory.createCampaign(
        _campaignPaymentAddress,
        _baseMetadataUri,
        erc20,
        symbol,
        name,
        nftTypeDetails,
        minGasToStore,
        lzEndpointAddress
    )

    console.log("🚀 ~ file: CampaignTypesNFT721.js:31 ~ campaignTypesNFT721:", campaignTypesNFT721)
}

module.exports.tags = ["CampaignTypesNFT721"]
