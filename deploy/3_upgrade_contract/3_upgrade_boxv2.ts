import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';
import {parseEther, formatUnits } from 'ethers/lib/utils';

  
  
  const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const {deployments, getNamedAccounts, network} = hre;
    const {deploy, log, execute } = deployments;
    const {deployer} = await getNamedAccounts();

  
    log(`Deploying contracts with the account: ${deployer}`);
  
  
    const balance = await hre.ethers.provider.getBalance(deployer);
    log(`Account balance: ${formatUnits(balance, 'ether')} BNB`);
  
  
    log(`Network Name: ${network.name}`);
    log("----------------------------------------------------")
  


    const { boxProxy } = await getNamedAccounts();

    const newImplName = 'BoxV2';
    const NewImpl = await hre.ethers.getContractFactory(newImplName);
    console.log(`Upgrading to ${newImplName}...`);
  
    await hre.upgrades.upgradeProxy(boxProxy, NewImpl);
    console.log(`Box upgraded to:`, newImplName);



    log("------------------ii---------ii---------------------")
    log("----------------------------------------------------")
    log("------------------ii---------ii---------------------")
    log("We may update these following addresses at hardhatconfig.ts ")
    log("----------------------------------------------------")




    log("----------------------------------------------------")
  
  
  };
  export default func;
  func.tags = ["3-1", 'boxv2'];
  func.dependencies = ['box']