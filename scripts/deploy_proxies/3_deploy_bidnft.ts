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

  const {
    feeAccount,
    busd,
    usdt,
    artworkProxy,
    askhelper,
    tradehelper
  } = await getNamedAccounts();


    const BidNFT = await ethers.getContractFactory(
      "BidNFT",
      {
        libraries: {
          AskHelper: askhelper,
          TradeHelper: tradehelper
        }
      }
      );
    const BidNFTResult = await upgrades.deployProxy(
          BidNFT,
        [
          artworkProxy,
          [busd, usdt],   
          feeAccount,
          parseUnits('2.5','ether'),
          parseUnits('5','ether')
        ],
        { initializer: 'initialize',
        // unsafeAllowLinkedLibraries: true,
          unsafeAllow: ['external-library-linking']
        }
          // unsafeAllow: [external-library-linking]}
        );
    await BidNFTResult.deployed();

    console.log("------------------ii---------ii---------------------")
    console.log("----------------------------------------------------")
    console.log("------------------ii---------ii---------------------")
    console.log("We may update these following addresses at hardhatconfig.ts ")
    console.log("----------------------------------------------------")

    console.log("BidNFT(bidnft) deployed to:", BidNFTResult.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });