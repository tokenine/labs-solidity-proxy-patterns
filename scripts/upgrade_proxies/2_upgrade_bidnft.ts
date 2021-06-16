// scripts/upgrade.js
// const { ethers } = require("hardhat");
import {
    ethers,
    upgrades,
    getNamedAccounts,
} from "hardhat";

// import * as 
//   hre
//  from 'hardhat';


async function main(): Promise<void> {

  const {
    bidnftProxy,
    askhelper,
    tradehelper
  } = await getNamedAccounts();


  const newImplName = 'BidNFTV2';
  const NewImpl = await ethers.getContractFactory(
    newImplName,
    {
      libraries: {
        AskHelper: askhelper,
        TradeHelper: tradehelper
      }
    }
    );
  console.log(`Upgrading to ${newImplName}...`);

  await upgrades.upgradeProxy(
    bidnftProxy,
    NewImpl,
    { 
      unsafeAllow: ['external-library-linking']
    }
    );
  console.log(`BidNFT (bidnftProxy) upgraded to:`, newImplName);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });