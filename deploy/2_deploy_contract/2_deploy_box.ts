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
  

    // const boxResult = await deploy('Box', {
    //   contract: 'BoxV2', 
    //   from: deployer,
    // //   proxy: 'true',
    // //   proxy: 'initialize',
    //   proxy: {
    //     owner: deployer,
    //     methodName: 'initialize',
    //     proxyContract: 'OpenZeppelinTransparentProxy'
    //   },
    //   args: [42],
    //   log: true,
    // });

    const Box = await hre.ethers.getContractFactory("Box");
    const boxResult = await hre.upgrades.deployProxy(
        Box,
        [42],
        { initializer: 'initialize' }
        );
    await boxResult.deployed();

    console.log("Box deployed to:", boxResult.address);



    log("------------------ii---------ii---------------------")
    log("----------------------------------------------------")
    log("------------------ii---------ii---------------------")
    log("We may update these following addresses at hardhatconfig.ts ")
    log("----------------------------------------------------")




    if (boxResult.newlyDeployed) {
      log(`Box contract address (box): ${boxResult.address} at key Box `);
    }


    log("----------------------------------------------------")
  
  
  };
  export default func;
  func.tags = ["2-1", 'box'];
//   func.dependencies = ['tokens']