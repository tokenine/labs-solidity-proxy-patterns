# 4. Running Manual Tasks

All **tasks** are written in `/tasks` folder

1) **Accounts** - list all of accounts currently using in the runtime environment

```
yarn hardhat --network bscTestnet accounts
```
2) **balance** - specify balance in the given account 

**Param: account** : Address from **Accounts** task 

```
yarn hardhat --network bscTestnet  balance --account 0xD1c4373F6acAf2aCd1A874d0748845ed179E97DC
```
3) **block-number** - specify the current block number
```
yarn hardhat --network bscTestnet block-number
```

4) **verify** - verify the inplement contract
```
yarn hardhat verify --network bscTestnet 0x016da3cdc716b4382baa2910bf5534658a7b9584
```

5) **Remove** Hardhat console.log imports and calls from Solidity source code.

Run the Hardhat task manually:
```
yarn run hardhat remove-logs
```
Before removing logs, the plugin will ensure that all contracts can be compiled successfully

6) **upgrade** - upgrade the proxy contract
```
yarn hardhat --network bscTestnet upgrade --name  BidNFTV2
```

**Param: name** : Smart contract `Name` from `/contracts` folder