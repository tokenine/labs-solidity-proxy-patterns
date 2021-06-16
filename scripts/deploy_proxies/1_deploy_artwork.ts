// scripts/upgrade.js
// const { ethers } = require("hardhat");
import {
    ethers,
    upgrades,
    getNamedAccounts,
} from "hardhat";

import {parseEther,parseUnits, formatUnits } from 'ethers/lib/utils';





async function main(): Promise<void> {

  //Fill feeAccount and  busd params in hardhat.config.ts
  const {
    feeAccount,
    busd,
    
  } = await getNamedAccounts();

    const ArtworkNFT = await ethers.getContractFactory("ArtworkNFT");
    const ArtworkResult = await upgrades.deployProxy(
        ArtworkNFT,
        [
          "Artwork NFT",
          "ART",
          // parseUnits('1','wei'),
          feeAccount,   
          parseUnits('0.0015','ether'),
          busd,
          parseUnits('1','ether')
        ],
      //   {
      //     initializer: 'initialize',
      //     unsafeAllowCustomTypes: true
      //  }
       {
        initializer: 'initialize',
     }
        );
    await ArtworkResult.deployed();


    console.log("------------------ii---------ii---------------------")
    console.log("----------------------------------------------------")
    console.log("------------------ii---------ii---------------------")
    console.log("We may update these following addresses at hardhatconfig.ts ")
    console.log("----------------------------------------------------")


    console.log("ArtworkNFT(artworkProxy) deployed to:", ArtworkResult.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });