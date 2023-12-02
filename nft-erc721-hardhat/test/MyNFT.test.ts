import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("MyNFT", () => {
  async function deployFixture() {
    const [owner, otherAccount, oneMoreAccount] = await ethers.getSigners();
    const MyNFT = await ethers.getContractFactory("MyNFT");
    const myNFT = await MyNFT.deploy();
    return { myNFT, owner, otherAccount, oneMoreAccount };
  }

  it("Should has the correct name", async () => {
    const { myNFT } = await loadFixture(deployFixture);
    const name = await myNFT.name() as string;
    expect(name).to.equal("MyNFT", "The name is wrong");
  });

  it("Should has the correct symbol", async () => {
    const { myNFT } = await loadFixture(deployFixture);
    const symbol = await myNFT.symbol() as string;
    expect(symbol).to.equal("MYN", "The symbol is wrong");
  });

  it("Should mint a new NFT", async () => {
    const { myNFT, owner } = await loadFixture(deployFixture);

    await myNFT.mint();

    const balance = await myNFT.balanceOf(owner.address);
    const token = await myNFT.tokenByIndex(0);
    const ownerToken = await myNFT.tokenOfOwnerByIndex(owner.address, 0);
    const ownerOf = await myNFT.ownerOf(token);
    const totalSupply = await myNFT.totalSupply();

    expect(totalSupply).to.equal(1, "Can't mint");
    expect(balance).to.equal(1, "Can't mint");
    expect(token).to.equal(ownerToken, "Can't mint");
    expect(ownerOf).to.equal(owner.address, "Can't mint");
  });

  it("Should burn", async () => {
    const { myNFT, owner } = await loadFixture(deployFixture);

    await myNFT.mint();
    const token = await myNFT.tokenOfOwnerByIndex(owner.address, 0);

    await myNFT.burn(token);

    const totalSupply = await myNFT.totalSupply();
    const balance = await myNFT.balanceOf(owner.address);

    expect(balance).to.equal(0, "Can't burn");
    expect(totalSupply).to.equal(0, "Can't burn");
  });

  it("Should burn (approved)", async () => {
    const { myNFT, owner, otherAccount } = await loadFixture(deployFixture);

    await myNFT.mint();

    const token = await myNFT.tokenOfOwnerByIndex(owner.address, 0);
    await myNFT.approve(otherAccount.address, token);

    const instance = myNFT.connect(otherAccount);
    await instance.burn(token);

    const totalSupply = await myNFT.totalSupply();
    const balanceFrom = await myNFT.balanceOf(owner.address);
    const balanceTo = await myNFT.balanceOf(owner.address);

    expect(balanceFrom).to.equal(0, "Can't burn");
    expect(balanceTo).to.equal(0, "Can't burn");
    expect(totalSupply).to.equal(0, "Can't burn");
  });

  it("Should burn (approved all)", async () => {
    const { myNFT, owner, otherAccount } = await loadFixture(deployFixture);

    await myNFT.mint();

    const token = await myNFT.tokenOfOwnerByIndex(owner.address, 0);
    await myNFT.setApprovalForAll(otherAccount.address, true);

    const instance = myNFT.connect(otherAccount);
    await instance.burn(token);

    const totalSupply = await myNFT.totalSupply();
    const balanceFrom = await myNFT.balanceOf(owner.address);
    const balanceTo = await myNFT.balanceOf(owner.address);

    expect(balanceFrom).to.equal(0, "Can't burn");
    expect(balanceTo).to.equal(0, "Can't burn");
    expect(totalSupply).to.equal(0, "Can't burn");
  });

  it("Should NOT burn (exists)", async () => {
    const { myNFT, owner, otherAccount } = await loadFixture(deployFixture);

    await expect(myNFT.burn(1))
      .to.be.revertedWithCustomError(myNFT, "ERC721NonexistentToken");
  });

  it("Should NOT burn (permission)", async () => {
    const { myNFT, owner, otherAccount } = await loadFixture(deployFixture);

    await myNFT.mint();

    const instance = myNFT.connect(otherAccount);
    const token = await instance.tokenByIndex(0);

    await expect(instance.burn(token))
      .to.be.revertedWithCustomError(myNFT, "ERC721InsufficientApproval");
  });

  it("Should has URI metadata", async () => {
    const { myNFT } = await loadFixture(deployFixture);

    await myNFT.mint();

    const token = await myNFT.tokenByIndex(0);

    const uri = await myNFT.tokenURI(token);
    expect(uri).to.equal("https://www.luiztools.com.br/nft/1.json", "Wrong token URI");
  });

  it("Should NOT has URI metadata", async () => {
    const { myNFT, owner, otherAccount } = await loadFixture(deployFixture);

    await expect(myNFT.tokenURI(1))
      .to.be.revertedWithCustomError(myNFT, "ERC721NonexistentToken");
  });

  it("Should transfer from", async () => {
    const { myNFT, owner, otherAccount } = await loadFixture(deployFixture);

    await myNFT.mint();
    const token = await myNFT.tokenByIndex(0);

    await myNFT.transferFrom(owner.address, otherAccount.address, token);

    const balanceFrom = await myNFT.balanceOf(owner.address);
    const balanceTo = await myNFT.balanceOf(otherAccount.address);
    const totalSupply = await myNFT.totalSupply();
    const ownerOf = await myNFT.ownerOf(token);
    const ownerToken = await myNFT.tokenOfOwnerByIndex(otherAccount.address, 0);

    expect(balanceFrom).to.equal(0, "The admin balance is wrong");
    expect(balanceTo).to.equal(1, "The to balance is wrong");
    expect(totalSupply).to.equal(1, "The total supply is wrong");
    expect(token).to.equal(ownerToken, "Can't transfer");
    expect(ownerOf).to.equal(otherAccount.address, "Can't transfer");
  });

  it("Should emit transfer event", async () => {
    const { myNFT, owner, otherAccount } = await loadFixture(deployFixture);

    await myNFT.mint();
    const token = await myNFT.tokenByIndex(0);

    await expect(myNFT.transferFrom(owner.address, otherAccount.address, token))
      .to.emit(myNFT, 'Transfer')
      .withArgs(owner.address, otherAccount.address, token);
  });


  it("Should transfer from (approved)", async () => {
    const { myNFT, owner, otherAccount } = await loadFixture(deployFixture);

    await myNFT.mint();

    const token = await myNFT.tokenByIndex(0);
    await myNFT.approve(otherAccount.address, token);
    const approved = await myNFT.getApproved(token);

    const instance = myNFT.connect(otherAccount);
    await instance.transferFrom(owner.address, otherAccount.address, token);

    const ownerOf = await instance.ownerOf(token);

    expect(ownerOf).to.equal(otherAccount.address, "Can't transfer (approved)");
    expect(approved).to.equal(otherAccount.address, "Can't approve");
  });

  it("Should emit approve event", async () => {
    const { myNFT, owner, otherAccount } = await loadFixture(deployFixture);

    await myNFT.mint();

    const token = await myNFT.tokenByIndex(0);

    await expect(myNFT.approve(otherAccount.address, token))
      .to.emit(myNFT, 'Approval')
      .withArgs(owner.address, otherAccount.address, token);
  });

  it("Should clear approvals", async () => {
    const { myNFT, owner, otherAccount, oneMoreAccount } = await loadFixture(deployFixture);

    await myNFT.mint();

    const token = await myNFT.tokenByIndex(0);
    await myNFT.approve(otherAccount.address, token);

    await myNFT.transferFrom(owner.address, oneMoreAccount.address, token);

    const ownerOf = await myNFT.ownerOf(token);
    const approved = await myNFT.getApproved(token);

    expect(ownerOf).to.equal(oneMoreAccount.address, "Can't transfer (approved)");
    expect(approved).to.equal(ethers.ZeroAddress, "Can't approve");
  });

  it("Should transfer from (approve all)", async () => {
    const { myNFT, owner, otherAccount } = await loadFixture(deployFixture);

    await myNFT.mint();

    const token = await myNFT.tokenByIndex(0);
    await myNFT.setApprovalForAll(otherAccount.address, true);

    const instance = myNFT.connect(otherAccount);
    await instance.transferFrom(owner.address, otherAccount.address, token);

    const ownerOf = await myNFT.ownerOf(token);
    const isApproved = await instance.isApprovedForAll(owner.address, otherAccount.address);

    expect(ownerOf).to.equal(otherAccount.address, "Can't transfer (approved all)");
    expect(isApproved).to.equal(true, "Can't approve for all");
  });

  it("Should emit ApprovalForAll event", async () => {
    const { myNFT, owner, otherAccount } = await loadFixture(deployFixture);

    await myNFT.mint();

    const token = await myNFT.tokenByIndex(0);

    await expect(myNFT.setApprovalForAll(otherAccount.address, true))
      .to.emit(myNFT, 'ApprovalForAll')
      .withArgs(owner.address, otherAccount.address, true);
  });

  it("Should NOT transfer from", async () => {
    const { myNFT, owner, otherAccount } = await loadFixture(deployFixture);

    await myNFT.mint();

    const instance = myNFT.connect(otherAccount);
    const token = await instance.tokenByIndex(0);

    await expect(instance.transferFrom(owner.address, otherAccount.address, token))
      .to.be.revertedWithCustomError(myNFT, "ERC721InsufficientApproval");
  });

  it("Should NOT transfer from (exists)", async () => {
    const { myNFT, owner, otherAccount } = await loadFixture(deployFixture);

    await expect(myNFT.transferFrom(owner.address, otherAccount.address, 1))
      .to.be.revertedWithCustomError(myNFT, "ERC721NonexistentToken");
  });

  it("Should NOT transfer from (approve)", async () => {
    const { myNFT, owner, otherAccount, oneMoreAccount } = await loadFixture(deployFixture);

    await myNFT.mint();
    const token = await myNFT.tokenByIndex(0);
    await myNFT.approve(oneMoreAccount.address, token);

    const instance = myNFT.connect(otherAccount);
    await expect(instance.transferFrom(owner.address, otherAccount.address, token))
      .to.be.revertedWithCustomError(myNFT, "ERC721InsufficientApproval");
  });

  it("Should NOT transfer from (approve all)", async () => {
    const { myNFT, owner, otherAccount, oneMoreAccount } = await loadFixture(deployFixture);

    await myNFT.mint();
    const token = await myNFT.tokenByIndex(0);
    await myNFT.setApprovalForAll(oneMoreAccount.address, true);

    const instance = myNFT.connect(otherAccount);
    await expect(instance.transferFrom(owner.address, otherAccount.address, token))
      .to.be.revertedWithCustomError(myNFT, "ERC721InsufficientApproval");
  });

  it("Should support interface", async () => {
    const { myNFT } = await loadFixture(deployFixture);

    const supports = await myNFT.supportsInterface("0x80ac58cd");
    expect(supports).to.equal(true, "Doesn't support interface");
  });
});