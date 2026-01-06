import { expect } from "chai";
import { network } from "hardhat";

const { ethers, networkHelpers } = await network.connect();
const [owner, otherAccount] = await ethers.getSigners();

describe("LuizCoin", function () {
  it("Should have correct name", async function () {
    const contract = await ethers.deployContract("LuizCoin");
    const name = await contract.name();
    expect(name).to.equal("LuizCoin");
  });

  it("Should have correct symbol", async function () {
    const contract = await ethers.deployContract("LuizCoin");
    const symbol = await contract.symbol();
    expect(symbol).to.equal("LUC");
  });

  it("Should have correct decimals", async function () {
    const contract = await ethers.deployContract("LuizCoin");
    const decimals = await contract.decimals();
    expect(decimals).to.equal(18);
  });

  it("Should have correct totalSupply", async function () {
    const contract = await ethers.deployContract("LuizCoin");
    const totalSupply = await contract.totalSupply();
    expect(totalSupply).to.equal(1000n * 10n ** 18n);
  });

  it("Should get balance", async function () {
    const contract = await ethers.deployContract("LuizCoin");
    const balance = await contract.balanceOf(owner.address);
    expect(balance).to.equal(1000n * 10n ** 18n);
  });

  it("Should transfer", async function () {
    const contract = await ethers.deployContract("LuizCoin");
    const balanceOwnerBefore = await contract.balanceOf(owner.address);
    const balanceOtherBefore = await contract.balanceOf(otherAccount.address);

    await contract.transfer(otherAccount.address, 1n);

    const balanceOwnerAfter = await contract.balanceOf(owner.address);
    const balanceOtherAfter = await contract.balanceOf(otherAccount.address);

    expect(balanceOwnerBefore).to.equal(1000n * 10n ** 18n);
    expect(balanceOwnerAfter).to.equal((1000n * 10n ** 18n) - 1n);
    expect(balanceOtherBefore).to.equal(0n);
    expect(balanceOtherAfter).to.equal(1n);
  });

  it("Should NOT transfer", async function () {
    const contract = await ethers.deployContract("LuizCoin");

    const instance = contract.connect(otherAccount);
    await expect(instance.transfer(owner.address, 1n))
      .to.be.revertedWithCustomError(contract, "ERC20InsufficientBalance");
  });

  it("Should approve", async function () {
    const contract = await ethers.deployContract("LuizCoin");
    await contract.approve(otherAccount.address, 1n);
    const value = await contract.allowance(owner.address, otherAccount.address);
    expect(value).to.equal(1n);
  });

  it("Should transfer from", async function () {
    const contract = await ethers.deployContract("LuizCoin");
    const balanceOwnerBefore = await contract.balanceOf(owner.address);
    const balanceOtherBefore = await contract.balanceOf(otherAccount.address);

    await contract.approve(otherAccount.address, 10n);

    const instance = contract.connect(otherAccount);

    await instance.transferFrom(owner.address, otherAccount.address, 5n);

    const balanceOwnerAfter = await contract.balanceOf(owner.address);
    const balanceOtherAfter = await contract.balanceOf(otherAccount.address);
    const allowance = await contract.allowance(owner.address, otherAccount.address);

    expect(balanceOwnerBefore).to.equal(1000n * 10n ** 18n);
    expect(balanceOwnerAfter).to.equal((1000n * 10n ** 18n) - 5n);
    expect(balanceOtherBefore).to.equal(0n);
    expect(balanceOtherAfter).to.equal(5n);
    expect(allowance).to.equal(5n);
  });

  it("Should NOT transfer from (balance)", async function () {
    const contract = await ethers.deployContract("LuizCoin");

    const instance = contract.connect(otherAccount);
    await instance.approve(otherAccount.address, 1n);
    await expect(instance.transferFrom(otherAccount.address, otherAccount.address, 1n))
      .to.be.revertedWithCustomError(contract, "ERC20InsufficientBalance");
  });

  it("Should NOT transfer from (allowance)", async function () {
    const contract = await ethers.deployContract("LuizCoin");

    const instance = contract.connect(otherAccount);
    await expect(instance.transferFrom(owner.address, otherAccount.address, 1n))
      .to.be.revertedWithCustomError(contract, "ERC20InsufficientAllowance");
  });
});
