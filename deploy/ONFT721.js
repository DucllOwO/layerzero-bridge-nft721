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

    const _campaignPaymentAddress = "0x29E754233F6A50ee5AE3ee6A0217aD907dc3386B"
    const _baseMetadataUri = "baseURI.com/uri"
    const erc20 = "0x0000000000000000000000000000000000001010"

    await deploy("CampaignTypesNFT721", {
        from: deployer,
        args: [name, symbol, _campaignPaymentAddress, _baseMetadataUri, minGasToStore, lzEndpointAddress],
        log: true,
        waitConfirmations: 1,
    })
}

module.exports.tags = ["CampaignTypesNFT721"]
