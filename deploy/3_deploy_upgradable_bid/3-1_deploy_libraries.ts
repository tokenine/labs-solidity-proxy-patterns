import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';
import {parseEther,parseUnits, formatUnits} from 'ethers/lib/utils';

  
  
  const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const {deployments, getNamedAccounts, network} = hre;
    const {deploy, log, execute, get } = deployments;
    const {
      deployer,
    } = await getNamedAccounts();

  
    log(`Deploying contracts with the account: ${deployer}`);
  
  
    const balance = await hre.ethers.provider.getBalance(deployer);
    log(`Account balance: ${formatUnits(balance, 'ether')} BNB`);
  
  
    log(`Network Name: ${network.name}`);
    log("----------------------------------------------------")



    const AskHelperLibrary = await deploy("AskHelper", {
      from: deployer,
      log: true
    });

    const TradeHelperLibrary = await deploy("TradeHelper", {
      from: deployer,
      log: true
    });


    log("------------------ii---------ii---------------------")
    log("----------------------------------------------------")
    log("------------------ii---------ii---------------------")
    log("We may update these following addresses at hardhatconfig.ts ")
    log("----------------------------------------------------")


    if (AskHelperLibrary.newlyDeployed) {
      log(`AskHelper library address (askhelper): ${AskHelperLibrary.address} at key askhelper `);
    }

    if (TradeHelperLibrary.newlyDeployed) {
      log(`TradeHelper library address (tradehelper): ${TradeHelperLibrary.address} at key tradehelper `);
    }


    log("----------------------------------------------------")
  
  
  };
  export default func;
  func.tags = ["3-1", 'libraries'];
  func.dependencies = ['testtokens', 'artwork']