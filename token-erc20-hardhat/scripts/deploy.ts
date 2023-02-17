import { ethers } from "hardhat";

async function main() {
  const LuizCoin = await ethers.getContractFactory("LuizCoin");
  const luizCoin = await LuizCoin.deploy();

  await luizCoin.deployed();

  console.log(`LuizCoin deployed successfully!`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
