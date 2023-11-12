module.exports = async function (taskArgs, hre) {
    // mumbai: 0xdf6B5d926c05A8A118F9B53e192294fa2628986c
    // fuji: 0x9746e4f9B5f26c63541CDEF011FDA5e5a0A81b79
    // let contract = await ethers.getContractAt("CampaignTypesNFT721", "0x9746e4f9B5f26c63541CDEF011FDA5e5a0A81b79")
    // let tx = await contract.mint(1, 0, "0x29E754233F6A50ee5AE3ee6A0217aD907dc3386B", "124uf8ew9cdj", { gasLimit: 200000 })
    let contract = await ethers.getContract(taskArgs.contract)
    let calldata = hre.ethers.hre.ethers.utils.solidityPack(
        ["uint256", "uint256", "address"],
        [taskArgs.amount, taskArgs.tokenType, taskArgs.to]
    )
    try {
        let tx = await (await await contract.mint(taskArgs.amount, taskArgs.tokenType, taskArgs.to, calldata)).wait()
        console.log(`✅ [${hre.network.name}] mint()`)
        console.log(` tx: ${tx.transactionHash}`)
        let onftTokenId = await ethers.provider.getTransactionReceipt(tx.transactionHash)
        console.log(` ONFT nftId: ${parseInt(Number(onftTokenId.logs[0].topics[3]))}`)
    } catch (e) {
        if (e.error?.message.includes("ONFT: Max limit reached")) {
            console.log("*ONFT: Max limit reached*")
        } else {
            console.log(e)
        }
    }
}
