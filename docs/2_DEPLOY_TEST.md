# 2. Deployments Scripts for Testing and Development Purpose

## Deployments

All **deployment scripts** are written in `/tasks` folder

We speify **The network** to deploy the smart contract with  **--network** as parameter

In each script, relevant **tags** are specified so we can use **--tags** as parameter

```typescript
func.tags = ['tokens'];
```

After each step, **hardhat.config.ts** needs to be updated regarding to newly deployed accounts. We can searh through terminal command with keyword  `key` or `We may update these following addresses at hardhatconfig.ts`

1) Deploy Mock Synthetic and Utility Tokens

::: tip
 All artifacts are stored in `/Deployments` folder but it stores only latest one. For example, **TestToken.jon** contains address only latest so only one of BUSD, JFIN and GASH is stored)
:::

```
yarn hardhat --network hardhat deploy --tags testtokens
```

```
yarn hardhat --network bscTestnet deploy --tags testtokens
```

(Note: After the script has been sucessfully run, we may either need to or choose to update deployed contract addresses at `helper-hardhat-config.ts` as specified in command line in the desired network)

2) Deploy Artwork contract
```
yarn hardhat --network hardhat deploy --tags 'artwork'
```

```
yarn hardhat --network bscTestnet deploy --tags 'protocol'
```
Or we may run each sub-step using 
```
yarn hardhat --network bscTestnet deploy --tags 2-1
```

::: tip
If we messed up, we may redepoly by simply go to `/Deployments` and delete history data eg. `/bscTestnet` and run the scripts again
:::


##  TDD Scripts

To run the test suites with hardhat network and utilize the maximum benefit of debugging features, use:

```
yarn hardhat test --logs
```
::: tip
we can add the --logs after your test command. So, this could emit Event during TDD environment
:::