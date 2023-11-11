const CHAIN_ID = require("../constants/chainIds.json")
const { getDeploymentAddresses } = require("../utils/readStatic")

module.exports = async function (taskArgs, hre) {
    let localContract, remoteContract

    if (taskArgs.contract) {
        localContract = taskArgs.contract
        remoteContract = taskArgs.contract
    } else {
        localContract = taskArgs.localContract
        remoteContract = taskArgs.remoteContract
    }

    if (!localContract || !remoteContract) {
        console.log("Must pass in contract name OR pass in both localContract name and remoteContract name")
        return
    }

    // get local contract
    const localContractInstance = await ethers.getContract(localContract)

    // get deployed remote contract address
    const remoteAddress = getDeploymentAddresses(taskArgs.targetNetwork)[remoteContract]
    console.log("🚀 ~ file: setTrustedRemote.js:25 ~ remoteContract:", remoteContract)
    console.log("🚀 ~ file: setTrustedRemote.js:25 ~ taskArgs.targetNetwork:", taskArgs.targetNetwork)
    console.log("🚀 ~ file: setTrustedRemote.js:25 ~ remoteAddress:", remoteAddress)

    // get remote chain id
    const remoteChainId = CHAIN_ID[taskArgs.targetNetwork]

    console.log("🚀 ~ file: setTrustedRemote.js:30 ~ localContractInstance.address:", localContractInstance.address)
    // concat remote and local address
    let remoteAndLocal = hre.ethers.utils.solidityPack(["address", "address"], [remoteAddress, localContractInstance.address])

    // check if pathway is already set
    const isTrustedRemoteSet = await localContractInstance.isTrustedRemote(remoteChainId, remoteAndLocal)

    if (!isTrustedRemoteSet) {
        try {
            let tx = await (await localContractInstance.setTrustedRemote(remoteChainId, remoteAndLocal, { gasLimit: 150000 })).wait()
            console.log(`✅ [${hre.network.name}] setTrustedRemote(${remoteChainId}, ${remoteAndLocal})`)
            console.log(` tx: ${tx.transactionHash}`)
        } catch (e) {
            if (e.error?.message.includes("The chainId + address is already trusted")) {
                console.log("*source already set*")
            } else {
                console.log("🚀 ~ file: setTrustedRemote.js:46 ~ e.error?.message:", e.error?.message)
                console.log(`❌ [${hre.network.name}] setTrustedRemote(${remoteChainId}, ${remoteAndLocal})`)
            }
        }
    } else {
        console.log("*source already set*")
    }
}
