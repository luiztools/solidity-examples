import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("LuizCoin", () => {

  const DECIMALS = 18n;

  async function deployFixture() {
    const [owner, otherAccount] = await ethers.getSigners();
    const LuizCoin = await ethers.getContractFactory("LuizCoin");
    const luizCoin = await LuizCoin.deploy();
    return { luizCoin, owner, otherAccount };
  }

  it("Should put total supply LuizCoin in the admin account", async () => {
    const { luizCoin, owner } = await loadFixture(deployFixture);
    const balance = await luizCoin.balanceOf(owner.address);
    const totalSupply = 1000n * 10n ** DECIMALS;
    expect(balance).to.equal(totalSupply, "Total supply wasn't in the first account");
  });

  it("Should has the correct name", async () => {
    const { luizCoin } = await loadFixture(deployFixture);
    const name = await luizCoin.name() as string;
    expect(name).to.equal("LuizCoin", "The name is wrong");
  });

  it("Should has the correct symbol", async () => {
    const { luizCoin } = await loadFixture(deployFixture);
    const symbol = await luizCoin.symbol() as string;
    expect(symbol).to.equal("LUC", "The symbol is wrong");
  });

  it("Should has the correct decimals", async () => {
    const { luizCoin } = await loadFixture(deployFixture);
    const decimals = await luizCoin.decimals();
    expect(decimals).to.equal(DECIMALS, "The decimals are wrong");
  });

  it("Should transfer", async () => {
    const qty = 1n * 10n ** DECIMALS;

    const { luizCoin, owner, otherAccount } = await loadFixture(deployFixture);
    const balanceAdminBefore = await luizCoin.balanceOf(owner.address);
    const balanceToBefore = await luizCoin.balanceOf(otherAccount.address);

    await luizCoin.transfer(otherAccount.address, qty);

    const balanceAdminNow = await luizCoin.balanceOf(owner.address);
    const balanceToNow = await luizCoin.balanceOf(otherAccount.address);

    expect(balanceAdminNow).to.equal(balanceAdminBefore - qty, "The admin balance is wrong");
    expect(balanceToNow).to.equal(balanceToBefore + qty, "The to balance is wrong");
  });

  it("Should NOT transfer", async () => {
    const aboveSupply = 1001n * 10n ** DECIMALS;
    const { luizCoin, owner, otherAccount } = await loadFixture(deployFixture);

    await expect(luizCoin.transfer(otherAccount.address, aboveSupply))
      .to.be.revertedWithCustomError(luizCoin, "ERC20InsufficientBalance");
  });

  it("Should approve", async () => {
    const qty = 1n * 10n ** DECIMALS;

    const { luizCoin, owner, otherAccount } = await loadFixture(deployFixture);
    await luizCoin.approve(otherAccount.address, qty);
    const allowedAmount = await luizCoin.allowance(owner.address, otherAccount.address);

    expect(qty).to.equal(allowedAmount, "The allowed amount is wrong"); ``
  });

  it("Should transfer from", async () => {
    const qty = 1n * 10n ** DECIMALS;

    const { luizCoin, owner, otherAccount } = await loadFixture(deployFixture);
    const allowanceBefore = await luizCoin.allowance(owner.address, otherAccount.address);
    const balanceAdminBefore = await luizCoin.balanceOf(owner.address);
    const balanceToBefore = await luizCoin.balanceOf(otherAccount.address);

    await luizCoin.approve(otherAccount.address, qty);

    const instance = luizCoin.connect(otherAccount);
    await instance.transferFrom(owner.address, otherAccount.address, qty);

    const allowanceNow = await luizCoin.allowance(owner.address, otherAccount.address);
    const balanceAdminNow = await luizCoin.balanceOf(owner.address);
    const balanceToNow = await luizCoin.balanceOf(otherAccount.address);

    expect(allowanceBefore).to.equal(allowanceNow, "The allowance is wrong");
    expect(balanceAdminNow).to.equal(balanceAdminBefore - qty, "The admin balance is wrong");
    expect(balanceToNow).to.equal(balanceToBefore + qty, "The to balance is wrong");
  });

  it("Should NOT transfer from", async () => {
    const qty = 1n * 10n ** DECIMALS;
    const { luizCoin, owner, otherAccount } = await loadFixture(deployFixture);

    await expect(luizCoin.transferFrom(owner.address, otherAccount.address, qty))
      .to.be.revertedWithCustomError(luizCoin, "ERC20InsufficientAllowance");
  });
});