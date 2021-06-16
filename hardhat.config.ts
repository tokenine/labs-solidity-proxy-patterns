// import { config as dotenvConfig } from "dotenv";
import 'dotenv/config';
import {HardhatUserConfig} from 'hardhat/types';
// import { NetworkUserConfig } from "hardhat/types";

//  require('dotenv').config();
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-etherscan";
import 'hardhat-deploy-ethers';
import 'hardhat-deploy';
// require("@nomiclabs/hardhat-ethers");
import '@nomiclabs/hardhat-waffle';
//  require('@nomiclabs/hardhat-waffle');
import "hardhat-typechain";
import '@openzeppelin/hardhat-upgrades';
import 'hardhat-tracer';
import "hardhat-log-remover"
import "@tenderly/hardhat-tenderly";



import tasks from './tasks'
for (const tsk of tasks) { tsk() }

const PRIVATE_KEY = process.env.PKEY;
const MNEMONIC = process.env.MKEY;
const ETHERSCAN_KEY = process.env.ETHERSCANKEY;

const config: HardhatUserConfig = {

  namedAccounts: {
    deployer: 0,
    feeAccount: 1,

    ///-------------------tag---tokens-------------------///
    zero: "0x0000000000000000000000000000000000000000",
    busd: {
      31337: "0xeb3273FcfaBc607FA504Ac5A6d77B78908C9244E", // Mapped from  BasicToken
      56: "0x0000000000000000000000000000000000000000", //TODO
      97: "0xF8a9E034a6F54fD3c73B1e666B85Bd42927901F2",
    },

    usdt: {
      31337: "0xd2b8B2d4cEf783a8fAcbaaeB08Df4d0a9Fa5077D", // Mapped from   BasicToken
      56: "0x0000000000000000000000000000000000000000", //TODO
      97: "0xFf8076a99d956BdA7855273A351ee0993643Dc7D",
    },

    artwork: {
      31337: "0xC9F4AC0f1998223b9a9726e6EbF3F5043433DD33", // Mapped from   ArtworkNFT
      56: "0x0000000000000000000000000000000000000000", //TODO
      97: "0x349AE1211F02c1e5EcdcD1158BbfD61CBE34ad96",
    },

    askhelper: {
      31337: "0x28bB7A7928dCFe5274baB80bbF22838C6B9FDA18", // Mapped from   BidNFT
      56: "0x0000000000000000000000000000000000000000", //TODO
      97: "0xE64763a5e7Bdf31425161032FD07Da343b5A8531",
    },

    tradehelper: {
      31337: "0x2865941758E4530407B09920c51Cce5e0EA9B7bD", // Mapped from   BidNFT
      56: "0x0000000000000000000000000000000000000000", //TODO
      97: "0x836760E215aA7f3a19a6bf0bE50DDC110b502e8D",
    },


    bidnft: {
      31337: "0x63C628733E650d813D2511b7c34695e1eD496361", // Mapped from   BidNFT
      56: "0x0000000000000000000000000000000000000000", //TODO
      97: "0x99A206aB332d8c7c29a3415ea5C8F4F589bb3CAC",
    },

    artworkProxy: {
      31337: "0x0000000000000000000000000000000000000000", // Mapped from  .openzeppelin
      56: "0x0000000000000000000000000000000000000000", //TODO
      97: "0x32A9472d405AE49Ce92B27278F31ba1Bf1e26B2c",
    },

    bidnftProxy: {
      31337: "0x0000000000000000000000000000000000000000", // Mapped from  .openzeppelin
      56: "0x0000000000000000000000000000000000000000", //TODO
      97: "0x7E115F3b2C3b12e049e1f82aA49254D52b9a1F4F",
    },

    artworkV1: {
      31337: "0x0000000000000000000000000000000000000000", // Mapped from  .openzeppelin
      56: "0x0000000000000000000000000000000000000000", //TODO
      97: "0x61a936398ee86fDDB0A64e7E7155cc8006de09C5",
    },


    bidnftV1: {
      31337: "0x0000000000000000000000000000000000000000", // Mapped from  .openzeppelin
      56: "0x0000000000000000000000000000000000000000", //TODO
      97: "0x8340a067d474A4624bd0ECf0C01505b5d6aC73B0",
    },


    artworkV2: {
      31337: "0x0000000000000000000000000000000000000000", // Mapped from  .openzeppelin
      56: "0x0000000000000000000000000000000000000000", //TODO
      97: "0xE79D2540b094D748E1F1ac8Ef7FD3F3bF1b9083B",
    },

    
    bidnftV2: {
      31337: "0x0000000000000000000000000000000000000000", // Mapped from  .openzeppelin
      56: "0x0000000000000000000000000000000000000000", //TODO
      97: "0xD12ECd75637791c71019ed02FD1f5fD93D370fF3",
    },
    
  


  },

  networks: {

    hardhat: {
      chainId: 31337,
      // mining: {
      //   auto: false,
      //   interval: 1000
      // },
      accounts: {
        count: 10,
        initialIndex: 0,
        mnemonic: `${MNEMONIC}`,
        path: "m/44'/60'/0'/0",
      },
        throwOnTransactionFailures: true,
        // if true,  throw stack traces on transaction failures.
        // If false, return  failing transaction hash.
        throwOnCallFailures: true,
        // If is true, will throw  stack traces when a call fails.
        // If false, will return the call's return data, which can contain a revert reason
        live: false,
        saveDeployments: false,
        tags: ["test", "local"]
    },

    local: {
			url: 'http://127.0.0.1:8545',
      chainId: 31337,
      // accounts: "remote",
      accounts: {
        count: 10,
        initialIndex: 0,
        mnemonic: `${MNEMONIC}`,
        path: "m/44'/60'/0'/0",
      },
      live: false,
      throwOnTransactionFailures: false,
      // if true,  throw stack traces on transaction failures.
      // If false, return  failing transaction hash.
      throwOnCallFailures: false,
      // If is true, will throw  stack traces when a call fails.
      // If false, will return the call's return data, which can contain a revert reason
      saveDeployments: true,
	  },

    // rinkeby: {
    //   url: INFURA_URL,
    //   accounts: [`0x${PRIVATE_KEY}`]
    // },

    bscTestnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
      chainId: 97,
      gasPrice: 20000000000,
      // accounts: [`0x${PRIVATE_KEY}`]
      accounts: {
        count: 10,
        initialIndex: 0,
        mnemonic: `${MNEMONIC}`,
        path: "m/44'/60'/0'/0",
      }

    },

    // bscMainnet: {
    //   url: "https://bsc-dataseed.binance.org/",
    //   chainId: 56,
    //   gasPrice: 20000000000,
    //   accounts: [`0x${PRIVATE_KEY}`]
    // }

  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: ETHERSCAN_KEY  //bsctestnet
  },

  solidity: {

    compilers: [
      // {
      //   version: "0.5.17",
      //   settings: {
      //     optimizer: {
      //       enabled: true,
      //       runs: 100
      //     }
      //   }
      // },
      {
        version: "0.6.6",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      },

      {
        version: "0.8.0",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      }
    ],


  },

  paths: {
    sources: './contracts',
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
    deploy: './deploy',
    deployments: './deployments',
    imports: './imports'
  },

  typechain: {
    outDir: 'typechain',
    target: 'ethers-v5',
  },

  mocha: {
    timeout: 70000
  },
  
  
  
};

export default config;