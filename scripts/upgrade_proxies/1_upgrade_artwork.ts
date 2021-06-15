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


  const { artworkProxy } = await getNamedAccounts();

  const newImplName = 'ArtworkNFTV2';
  const NewImpl = await ethers.getContractFactory(newImplName);
  console.log(`Upgrading to ${newImplName}...`);

  await upgrades.upgradeProxy(artworkProxy, NewImpl);
  console.log(`ArtworkNFT upgraded to:`, newImplName);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });