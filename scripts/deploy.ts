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




    const Box = await ethers.getContractFactory("Box");
    const boxResult = await upgrades.deployProxy(
        Box,
        [42],
        { initializer: 'initialize' }
        );
    await boxResult.deployed();

    console.log("Box deployed to:", boxResult.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });