module.exports = async function (taskArgs, hre) {
    let contract = await ethers.getContractAt("CampaignTypesNFT721", "0xBEf54aA60879C5d45fACc4E0f2D3Bd0395CE6566")
    // let tx = await contract.mint(1, 0, "0x29E754233F6A50ee5AE3ee6A0217aD907dc3386B", "124uf8ew9cdj", { gasLimit: 200000 })
    let tx = await contract.getOwner()
    console.log("🚀 ~ file: onftMint.js:7 ~ contract:", await tx.wait())

    // try {
    //     let tx = await (await contract.mint(taskArgs.toAddress, taskArgs.tokenId)).wait()
    //     console.log(`✅ [${hre.network.name}] mint()`)
    //     console.log(` tx: ${tx.transactionHash}`)
    //     let onftTokenId = await ethers.provider.getTransactionReceipt(tx.transactionHash)
    //     console.log(` ONFT nftId: ${parseInt(Number(onftTokenId.logs[0].topics[3]))}`)
    // } catch (e) {
    //     if (e.error?.message.includes("ONFT: Max limit reached")) {
    //         console.log("*ONFT: Max limit reached*")
    //     } else {
    //         console.log(e)
    //     }
    // }
}
