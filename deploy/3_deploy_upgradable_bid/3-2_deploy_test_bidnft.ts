import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';
import {parseEther,parseUnits, formatUnits} from 'ethers/lib/utils';

  
  
  const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const {deployments, getNamedAccounts, network} = hre;
    const {deploy, log, execute, get } = deployments;
    const {
      deployer,
      feeAccount,
      busd,
      usdt,
      artwork,
      askhelper,
      tradehelper
    } = await getNamedAccounts();

  
    log(`Deploying contracts with the account: ${deployer}`);
  
  
    const balance = await hre.ethers.provider.getBalance(deployer);
    log(`Account balance: ${formatUnits(balance, 'ether')} BNB`);
  
  
    log(`Network Name: ${network.name}`);
    log("----------------------------------------------------")


    let busdToken : string;
    let usdtToken : string;
    let artworkNft : string;
    let askhelperLibrary : string;
    let tradehelperLibrary : string;


    if(network.name == 'hardhat'){
        busdToken = (await get('BUSDTestToken')).address;
        usdtToken = (await get('USDTTestToken')).address;
        artworkNft = (await get('ArtworkNFT')).address;
        askhelperLibrary  = (await get('AskHelper')).address;
        tradehelperLibrary = (await get('TradeHelper')).address;
    } else {
        busdToken = busd;
        usdtToken = usdt;
        artworkNft = artwork;
        askhelperLibrary = askhelper;
        tradehelperLibrary = tradehelper;
    }


    // const AskHelperLibrary = await deploy("AskHelper", {
    //   from: deployer,
    //   log: true
    // });

    // const TradeHelperLibrary = await deploy("TradeHelper", {
    //   from: deployer,
    //   log: true
    // });




    const BidNFTResult = await deploy('BidNFT', {
      contract: 'BidNFT', 
      from: deployer,
      args: [],
      log: true,
      libraries: {
        'AskHelper': askhelperLibrary,
        'TradeHelper': tradehelperLibrary
    }
      
  });



  if (BidNFTResult.newlyDeployed) {


    log(`BidNFT contract address (BidNFT): ${BidNFTResult.address} at key artwork `);
    await execute(
      'BidNFT',
      {from: deployer, log: true},
      "initialize",
      artworkNft,
      [busdToken, usdtToken],
      feeAccount,
      // hre.ethers.BigNumber.from("2.0"),
      // hre.ethers.BigNumber.from("3.0"),
      // parseUnits(2),
      // parseUnits(3)
      parseUnits('2',"wei"),
      parseUnits('3',"wei"),
      );


  }


    log("------------------ii---------ii---------------------")
    log("----------------------------------------------------")
    log("------------------ii---------ii---------------------")
    log("We may update these following addresses at hardhatconfig.ts ")
    log("----------------------------------------------------")


    // if (AskHelperLibrary.newlyDeployed) {
    //   log(`AskHelper library address (askhelper): ${AskHelperLibrary.address} at key askhelper `);
    // }

    // if (TradeHelperLibrary.newlyDeployed) {
    //   log(`TradeHelper library address (tradehelper): ${TradeHelperLibrary.address} at key tradehelper `);
    // }

    if (BidNFTResult.newlyDeployed) {
      log(`BidNFT contract address (bidnft): ${BidNFTResult.address} at key bidnft `);
    }

    log("----------------------------------------------------")
  
  
  };
  export default func;
  func.tags = ["3-2", 'bidnft'];
  func.dependencies = ['testtokens', 'artwork', '3-1']