# 3. Running Stand Alone Scripts including Deployment and Upgrade with Proxy Design Pattern

## Proxies Scripts

1) Deploy **Proxy ArtworkNFT Contract** with a stand alone script
```
yarn hardhat --network bscTestnet run scripts/deploy_proxies/1_deploy_artwork.ts
```

(Note: After the script has been sucessfully run, we may  choose to update deployed **Proxy contract addresses** at `helper-hardhat-config.ts` as specified in `.openzeppelins` (eg **unknown-97.json**) in the desired network)

2) Deploy Required **libraries** 

```
yarn hardhat --network bscTestnet run scripts/deploy_proxies/2_deploy_libraries.ts
```

(Note: After the script has been sucessfully run, we need to update deployed **tradehelper** and **askhelper** addresses at `helper-hardhat-config.ts` as specified in terminal in the desired network)

3) Deploy **Proxy BidNFt Contract** with a stand alone script

```
yarn hardhat --network bscTestnet run scripts/deploy_proxies/3_deploy_bidnft.ts
```

(Note: After the script has been sucessfully run, we again may  update deployed **Proxy contract addresses** at `helper-hardhat-config.ts`)

## Upgrade Scripts

1) Upgrade **Proxy ArtworkNFT Contract** with :

```
yarn hardhat --network bscTestnet run scripts/upgrade_proxies/1_upgrade_artwork.ts
```

(Note: After the script has been sucessfully run, we ,for easier life, should update deployed **Inplementation contract addresses** at `helper-hardhat-config.ts` as specified in `.openzeppelins` (eg **unknown-97.json**) in the desired network)

2) Upgrade **Proxy BidNFt Contract** with :

::: tip
We may re-depoly **tradehelper** and **askhelper** libraries before run the scripts
:::

```
yarn hardhat --network bscTestnet run scripts/upgrade_proxies/2_upgrade_bidnft.ts
```

(Note: After the script has been sucessfully run, we again may update deployed **Proxy contract addresses** at `helper-hardhat-config.ts`)