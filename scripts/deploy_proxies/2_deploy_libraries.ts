// scripts/upgrade.js
// const { ethers } = require("hardhat");
import {
    ethers,
    upgrades,
    getNamedAccounts,
} from "hardhat";

import {parseEther,parseUnits, formatUnits } from 'ethers/lib/utils';





async function main(): Promise<void> {

  //Fill artworkProxy, askhelper and  tradehelper params in hardhat.config.ts


    const AskHelper = await ethers.getContractFactory("AskHelper");
    const AskHelperResult = await AskHelper.deploy();

    await AskHelperResult.deployed();

    const TradeHelper = await ethers.getContractFactory("TradeHelper");
    const TradeHelperResult = await TradeHelper.deploy();

    await TradeHelperResult.deployed();


    console.log("------------------ii---------ii---------------------")
    console.log("----------------------------------------------------")
    console.log("------------------ii---------ii---------------------")
    console.log("We may update these following addresses at hardhatconfig.ts ")
    console.log("----------------------------------------------------")



    console.log("AskHelper(askhelper) deployed to:", AskHelperResult.address);
    console.log("TradeHelper(tradehelper) deployed to:", TradeHelperResult.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });