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


  const { bidnftProxy } = await getNamedAccounts();

  const newImplName = 'BidNFTV2';
  const NewImpl = await ethers.getContractFactory(newImplName);
  console.log(`Upgrading to ${newImplName}...`);

  await upgrades.upgradeProxy(bidnftProxy, NewImpl);
  console.log(`BidNFT upgraded to:`, newImplName);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });