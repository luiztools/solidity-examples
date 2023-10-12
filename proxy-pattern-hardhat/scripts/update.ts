import { ethers, upgrades } from "hardhat";

async function main() {
  const Contrato = await ethers.getContractFactory("Contrato");
  const contract = await upgrades.upgradeProxy("0x6AbD403AA0DBBbDdE8e994745B7ca29e206aFe3e", Contrato);
  await contract.waitForDeployment();
  const address = await contract.getAddress();

  console.log(`Contract updated at ${address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
