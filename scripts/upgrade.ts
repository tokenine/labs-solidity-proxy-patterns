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


  const { boxProxy } = await getNamedAccounts();

  const newImplName = 'BoxV3';
  const NewImpl = await ethers.getContractFactory(newImplName);
  console.log(`Upgrading to ${newImplName}...`);

  await upgrades.upgradeProxy(boxProxy, NewImpl);
  console.log(`Box upgraded to:`, newImplName);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });