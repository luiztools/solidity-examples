import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers, upgrades } from "hardhat";

describe("Contrato Proxy", function () {

  async function deployFixture() {
    const [owner, otherAccount] = await ethers.getSigners();

    const Contrato = await ethers.getContractFactory("Contrato");
    const contract = await upgrades.deployProxy(Contrato);
    const contractAddress = await contract.getAddress();

    return { contract, contractAddress, owner, otherAccount };
  }

  it("Should set message", async function () {
    const { contract } = await loadFixture(deployFixture);

    await contract.setMessage("Hello LuizTools")

    expect(await contract.getMessage()).to.equal("Hello LuizTools");
  });

  it("Should upgrade and set message", async function () {
    const { contract, contractAddress } = await loadFixture(deployFixture);

    await contract.setMessage("Hello New LuizTools");

    const Contrato = await ethers.getContractFactory("Contrato");
    const newContract = await upgrades.upgradeProxy(contractAddress, Contrato);

    expect(await newContract.getMessage()).to.equal("Hello New LuizTools");
  });
});
