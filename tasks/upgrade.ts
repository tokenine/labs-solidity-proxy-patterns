import {HardhatRuntimeEnvironment} from 'hardhat/types';
import { task } from "hardhat/config";

export default async () => { 

    task( 'upgrade', 'Upgrade proxy contract')
        .addParam('name', 'The new implementaion name')
        .setAction(async (_taskArgs, hre: HardhatRuntimeEnvironment) => {
            const { boxProxy } = await hre.getNamedAccounts();
            // const newImplName = 'BoxV2';
            const newImplName = _taskArgs.name;
            const NewImpl = await hre.ethers.getContractFactory(newImplName);
            console.log(`Upgrading to ${newImplName}...`);
            await hre.upgrades.upgradeProxy(boxProxy, NewImpl);
            console.log(`Box upgraded to:`, newImplName);

        })
    }