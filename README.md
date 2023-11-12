### Install & Run tests

```shell
yarn install
yarn test
```

# Omnichain Non Fungible Token 721 (CampaignTypesNFT721)

This ONFT contract allows minting of `nftId`s on separate chains. To ensure two chains can not mint the same `nftId` each contract on each chain is only allowed to mint`nftIds` in certain ranges.

## CampaignTypesNFT721.sol

:warning: **You must perform the `setTrustedRemote()` (step 2).**

1. Deploy two factory contracts:

This will deploy the implementation nft721, campaign factory and clone a campaign nft721

```shell
npx hardhat --network bsc-testnet deploy --tags CampaignFactory
npx hardhat --network fuji deploy --tags CampaignFactory
```

You must get the clone contract address and replace the address in the deployment folder (this folder will appear when you successfully deploy)
For example: go to deployment/fuji/CampaignTypesNFT721 and change the address in that file.

2. Set the "trusted remotes", so each contract can send & receive messages from one another, and **only** one another.

```shell
npx hardhat --network bsc-testnet setTrustedRemote --target-network fuji --contract CampaignTypesNFT721
npx hardhat --network fuji setTrustedRemote --target-network bsc-testnet --contract CampaignTypesNFT721
```

3. Set the min gas required on the destination

```shell
npx hardhat --network bsc-testnet setMinDstGas --target-network fuji --contract CampaignTypesNFT721 --packet-type 1 --min-gas 100000
npx hardhat --network fuji setMinDstGas --target-network bsc-testnet --contract CampaignTypesNFT721 --packet-type 1 --min-gas 100000
```

4. Mint an NFT on each chain!

```shell
npx hardhat --network bsc-testnet onftMint --contract CampaignTypesNFT721 --to-address <address> --token-id 1
npx hardhat --network fuji onftMint --contract CampaignTypesNFT721 --to-address <address> --token-id 11
```

5. [Optional] Show the token owner(s)

```shell
npx hardhat --network bsc-testnet ownerOf --token-id 1 --contract CampaignTypesNFT721
npx hardhat --network fuji ownerOf --token-id 11 --contract CampaignTypesNFT721
```

6. Send ONFT across chains

```shell
npx hardhat --network bsc-testnet onftSend --target-network fuji --token-id 1 --contract CampaignTypesNFT721
npx hardhat --network fuji onftSend --target-network bsc-testnet --token-id 11 --contract CampaignTypesNFT721
```

7. Verify your token no longer exists in your wallet on the source chain & wait for it to reach the destination side.

```shell
npx hardhat --network bsc-testnet ownerOf --token-id 1 --contract CampaignTypesNFT721
npx hardhat --network fuji ownerOf --token-id 1 --contract CampaignTypesNFT721
```

# Check your setTrustedRemote's are wired up correctly

Just use our [checkWireUpAll](./tasks/checkWireUpAll.js) task to check if your contracts are wired up correctly. You can use it on the example contracts deployed above.

```shell
npx hardhat checkWireUpAll --e testnet --contract CampaignTypesNFT721
```
