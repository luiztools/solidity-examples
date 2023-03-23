import { ethers } from "hardhat";

async function main() {
  const MyTokens = await ethers.getContractFactory("MyTokens");
  const myTokens = await MyTokens.deploy();

  await myTokens.deployed();

  console.log(
    `Contract deployed to ${myTokens.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
