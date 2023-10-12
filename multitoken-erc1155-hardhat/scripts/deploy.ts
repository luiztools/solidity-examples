import { ethers } from "hardhat";

async function main() {
  const MyTokens = await ethers.getContractFactory("MyTokens");
  const myTokens = await MyTokens.deploy();

  await myTokens.waitForDeployment();
  const address = await myTokens.getAddress();

  console.log(
    `Contract deployed to ${address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
