import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';
import {parseEther,parseUnits, formatUnits } from 'ethers/lib/utils';

  
  
  const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const {deployments, getNamedAccounts, network} = hre;
    const {deploy, log, execute, get } = deployments;
    const {
      deployer,
      feeAccount,
      busd,
      // usdt
    } = await getNamedAccounts();

  
    log(`Deploying contracts with the account: ${deployer}`);
  
  
    const balance = await hre.ethers.provider.getBalance(deployer);
    log(`Account balance: ${formatUnits(balance, 'ether')} BNB`);
  
  
    log(`Network Name: ${network.name}`);
    log("----------------------------------------------------")


    let busdToken : string;
    // let usdtToken : string;


    if(network.name == 'hardhat'){
        busdToken = (await get('BUSDTestToken')).address;
        // usdtToken = (await get('USDTTestToken')).address;
    } else {
        busdToken = busd;
        // usdtToken = usdt;

    }

    const ArtworkNFTResult = await deploy('ArtworkNFT', {
      contract: 'ArtworkNFT', 
      from: deployer,
      args: [],
      log: true,
  });



  if (ArtworkNFTResult.newlyDeployed) {
    log(`ArtworkNFT contract address (ArtworkNFT): ${ArtworkNFTResult.address} at key artwork `);
    await execute(
      'ArtworkNFT',
      {from: deployer, log: true},
      "initialize",
      "Artwork NFT",
      "ART",
      // parseUnits('1','wei'),
      feeAccount,   
      parseUnits('0.0015','ether'),
      busdToken,
      parseUnits('1','ether'),
      );
  }


    log("------------------ii---------ii---------------------")
    log("----------------------------------------------------")
    log("------------------ii---------ii---------------------")
    log("We may update these following addresses at hardhatconfig.ts ")
    log("----------------------------------------------------")

    if (ArtworkNFTResult.newlyDeployed) {
      log(`artwork contract address (artwork): ${ArtworkNFTResult.address} at key artwork `);
    }

    log("----------------------------------------------------")
  
  
  };
  export default func;
  func.tags = ["2-1", 'artwork'];
  func.dependencies = ['testtokens']