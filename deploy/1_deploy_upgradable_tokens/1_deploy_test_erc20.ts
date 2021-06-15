import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';
import {formatUnits, parseUnits} from 'ethers/lib/utils';

  
  
  const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const {deployments, getNamedAccounts, network} = hre;
    const {deploy , log, execute } = deployments;
    const {deployer} = await getNamedAccounts();
  
    log(`Deploying contracts with the account: ${deployer}`);
  
  
    const balance = await hre.ethers.provider.getBalance(deployer);
    log(`Account balance: ${formatUnits(balance, 'ether')} BNB`);
  
  
    log(`Network Name: ${network.name}`);
    log("----------------------------------------------------");


    if(network.name == 'hardhat' || network.name == 'bscTestnet'){
      const BUSDTestResult = await deploy('BUSDTestToken', {
        contract: 'BasicToken', 
        from: deployer,
        args: [],
        log: true,
      });

      const USDTTestResult = await deploy('USDTTestToken', {
        contract: 'BasicToken', 
        from: deployer,
        args: [],
        log: true,
      });

      if (BUSDTestResult.newlyDeployed) {
        log(`BasicToken contract address (BUSDTestToken): ${BUSDTestResult.address} at key busd `);
        await execute(
          'BUSDTestToken',
          {from: deployer, log: true},
          "initialize",
          "BUSD Token",
          "BUSD",
          parseUnits('1000000','ether')
          );
      }
  
      if (USDTTestResult.newlyDeployed) {
        log(`BasicToken contract address (USDTTestToken): ${USDTTestResult.address} at key usdt `);
        await execute(
          'USDTTestToken',
          {from: deployer, log: true},
          "initialize",
          "USDT Token",
          "USDT",
          parseUnits('1000000','ether')
        );
    }

    log("------------------ii---------ii---------------------")
    log("----------------------------------------------------")
    log("------------------ii---------ii---------------------")
    log("We may update these following addresses at hardhatconfig.ts ")
    log(`busd address: ${BUSDTestResult.address} at key busd`);
    log(`usdt address: ${USDTTestResult.address} at key usdt`);

    log("----------------------------------------------------")
  } else {
    log("------------------ii---------ii---------------------")
    log("----------------------------------------------------")
    log("------------------ii---------ii---------------------")
    log("Do nothing as it is mainnet ")
  }





    

  

  
  
  };
  export default func;
  func.tags = [ 'testtokens'];