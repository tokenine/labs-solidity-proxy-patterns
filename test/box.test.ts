import { use, expect } from "chai";

// import * as 
//   hre
//  from 'hardhat';

import { ethers, upgrades } from "hardhat";


describe("Box", function() {
  it('works', async () => {
    const Box = await ethers.getContractFactory("Box");
    const BoxV2 = await ethers.getContractFactory("BoxV2");
  
    const instance = await upgrades.deployProxy(Box, [42]);
    const upgraded = await upgrades.upgradeProxy(instance.address, BoxV2);

    const value = await upgraded.retrieve();
    expect(value.toString()).to.equal('42');

    const version = await upgraded.version();
    expect(version.toString()).to.equal('2.0.0');

  });
});