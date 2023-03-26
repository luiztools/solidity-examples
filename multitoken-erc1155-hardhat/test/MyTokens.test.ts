import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("MyTokens", () => {
  async function deployFixture() {
    const [owner, otherAccount, oneMoreAccount] = await ethers.getSigners();
    const MyTokens = await ethers.getContractFactory("MyTokens");
    const contract = await MyTokens.deploy();
    return { contract, owner, otherAccount, oneMoreAccount };
  }

  it("Should mint a new token", async () => {
    const { contract, owner } = await loadFixture(deployFixture);

    await contract.mint(0, { value: ethers.utils.parseEther("0.01") });

    const balance = await contract.balanceOf(owner.address, 0);
    const supply = await contract.currentSupply(0);

    expect(balance).to.equal(1, "Can't mint");
    expect(supply).to.equal(49, "Can't mint");
  });

  it("Should NOT mint a new token (exists)", async () => {
    const { contract, owner } = await loadFixture(deployFixture);

    await expect(contract.mint(3, { value: ethers.utils.parseEther("0.01") }))
      .to.be.revertedWith("This token does not exists");
  });

  it("Should NOT mint a new token (payment)", async () => {
    const { contract, owner } = await loadFixture(deployFixture);

    await expect(contract.mint(0, { value: ethers.utils.parseEther("0.001") }))
      .to.be.revertedWith("Insufficient payment");
  });

  it("Should NOT mint a new token (supply)", async () => {
    const { contract, owner } = await loadFixture(deployFixture);

    for(let i=0 ; i < 50; i++){
      await contract.mint(0, { value: ethers.utils.parseEther("0.01") });
    }

    await expect(contract.mint(0, { value: ethers.utils.parseEther("0.01") }))
      .to.be.revertedWith("Max supply reached");
  });

  it("Should burn", async () => {
    const { contract, owner } = await loadFixture(deployFixture);

    await contract.mint(0, { value: ethers.utils.parseEther("0.01") });

    await contract.burn(owner.address, 0, 1);

    const supply = await contract.currentSupply(0);
    const balance = await contract.balanceOf(owner.address, 0);

    expect(balance).to.equal(0, "Can't burn");
    expect(supply).to.equal(49, "Can't burn");
  });

  it("Should burn (approved)", async () => {
    const { contract, owner, otherAccount } = await loadFixture(deployFixture);

    await contract.mint(0, { value: ethers.utils.parseEther("0.01") });

    await contract.setApprovalForAll(otherAccount.address, true);
    const approved = await contract.isApprovedForAll(owner.address, otherAccount.address);

    const instance = contract.connect(otherAccount);
    await instance.burn(owner.address, 0, 1);

    const supply = await contract.currentSupply(0);
    const balanceFrom = await contract.balanceOf(owner.address, 0);

    expect(approved).to.equal(true, "Can't burn");
    expect(balanceFrom).to.equal(0, "Can't burn");
    expect(supply).to.equal(49, "Can't burn");
  });

  it("Should NOT burn (balance)", async () => {
    const { contract, owner, otherAccount } = await loadFixture(deployFixture);

    await expect(contract.burn(owner.address, 3, 1))
      .to.be.revertedWith("ERC1155: burn amount exceeds balance");
  });

  it("Should NOT burn (permission)", async () => {
    const { contract, owner, otherAccount } = await loadFixture(deployFixture);

    await contract.mint(0, { value: ethers.utils.parseEther("0.01") });

    const instance = contract.connect(otherAccount);

    await expect(instance.burn(owner.address, 0, 1))
      .to.be.revertedWith("ERC1155: caller is not token owner or approved");
  });

  it("Should transfer from", async () => {
    const { contract, owner, otherAccount } = await loadFixture(deployFixture);

    await contract.mint(0, { value: ethers.utils.parseEther("0.01") });

    await contract.safeTransferFrom(owner.address, otherAccount.address, 0, 1, "0x00000000");

    const balances = await contract.balanceOfBatch([owner.address,otherAccount.address] , [0,0]);
    const supply = await contract.currentSupply(0);

    expect(balances[0]).to.equal(0, "The admin balance is wrong");
    expect(balances[1]).to.equal(1, "The to balance is wrong");
    expect(supply).to.equal(49, "The total supply is wrong");
  });

  it("Should emit transfer event", async () => {
    const { contract, owner, otherAccount } = await loadFixture(deployFixture);

    await contract.mint(0, { value: ethers.utils.parseEther("0.01") });

    await expect(contract.safeTransferFrom(owner.address, otherAccount.address, 0, 1, "0x00000000"))
      .to.emit(contract, 'TransferSingle')
      .withArgs(owner.address, owner.address, otherAccount.address, 0, 1);
  });

  it("Should transfer batch from", async () => {
    const { contract, owner, otherAccount } = await loadFixture(deployFixture);

    await contract.mint(0, { value: ethers.utils.parseEther("0.01") });

    await contract.mint(1, { value: ethers.utils.parseEther("0.01") });

    await contract.safeBatchTransferFrom(owner.address, otherAccount.address, [0,1], [1,1], "0x00000000");

    const balances = await contract.balanceOfBatch([owner.address,owner.address,otherAccount.address,otherAccount.address] , [0,1,0,1]);
    const supplyZero = await contract.currentSupply(0);
    const supplyOne = await contract.currentSupply(1);

    expect(balances[0]).to.equal(0, "The admin balance is wrong");
    expect(balances[1]).to.equal(0, "The to balance is wrong");
    expect(balances[2]).to.equal(1, "The to balance is wrong");
    expect(balances[3]).to.equal(1, "The to balance is wrong");
    expect(supplyZero).to.equal(49, "The total supply is wrong");
    expect(supplyOne).to.equal(49, "The total supply is wrong");
  });

  it("Should emit transfer batch event", async () => {
    const { contract, owner, otherAccount } = await loadFixture(deployFixture);

    await contract.mint(0, { value: ethers.utils.parseEther("0.01") });
    await contract.mint(1, { value: ethers.utils.parseEther("0.01") });

    await expect(contract.safeBatchTransferFrom(owner.address, otherAccount.address, [0,1], [1,1], "0x00000000"))
      .to.emit(contract, 'TransferBatch')
      .withArgs(owner.address, owner.address, otherAccount.address, [0,1], [1,1]);
  });


  it("Should transfer from (approved)", async () => {
    const { contract, owner, otherAccount } = await loadFixture(deployFixture);

    await contract.mint(0, { value: ethers.utils.parseEther("0.01") });

    await contract.setApprovalForAll(otherAccount.address, true);
    const approved = await contract.isApprovedForAll(owner.address, otherAccount.address);

    const instance = contract.connect(otherAccount);
    await instance.safeTransferFrom(owner.address, otherAccount.address, 0, 1, "0x00000000");

    const balances = await contract.balanceOfBatch([owner.address, otherAccount.address], [0,0]);

    expect(balances[0]).to.equal(0, "Can't transfer (approved)");
    expect(balances[1]).to.equal(1, "Can't transfer (approved)");
    expect(approved).to.equal(true, "Can't approve");
  });

  it("Should emit approve event", async () => {
    const { contract, owner, otherAccount } = await loadFixture(deployFixture);

    await expect(contract.setApprovalForAll(otherAccount.address, true))
      .to.emit(contract, 'ApprovalForAll')
      .withArgs(owner.address, otherAccount.address, true);
  });

  it("Should NOT transfer from (balance)", async () => {
    const { contract, owner, otherAccount } = await loadFixture(deployFixture);

    await expect(contract.safeTransferFrom(owner.address, otherAccount.address, 0, 1, "0x00000000"))
      .to.be.revertedWith("ERC1155: insufficient balance for transfer");
  });

  it("Should NOT transfer from (permission)", async () => {
    const { contract, owner, otherAccount } = await loadFixture(deployFixture);

    await contract.mint(0, { value: ethers.utils.parseEther("0.01") });

    const instance = contract.connect(otherAccount);

    await expect(instance.safeTransferFrom(owner.address, otherAccount.address, 0, 1, "0x00000000"))
      .to.be.revertedWith("ERC1155: caller is not token owner or approved");
  });

  it("Should NOT transfer from (exists)", async () => {
    const { contract, owner, otherAccount } = await loadFixture(deployFixture);

    await expect(contract.safeTransferFrom(owner.address, otherAccount.address, 3, 1, "0x00000000"))
      .to.be.revertedWith("ERC1155: insufficient balance for transfer");
  });

  it("Should NOT transfer from (approve)", async () => {
    const { contract, owner, otherAccount, oneMoreAccount } = await loadFixture(deployFixture);

    await contract.mint(0, { value: ethers.utils.parseEther("0.01") });
    await contract.setApprovalForAll(oneMoreAccount.address, true);

    const instance = contract.connect(otherAccount);
    await expect(instance.safeTransferFrom(owner.address, otherAccount.address, 0, 1, "0x00000000"))
      .to.be.revertedWith("ERC1155: caller is not token owner or approved");
  });

  it("Should NOT transfer batch (arrays mismatch)", async () => {
    const { contract, owner, otherAccount } = await loadFixture(deployFixture);

    await contract.mint(0, { value: ethers.utils.parseEther("0.01") });
    await contract.mint(1, { value: ethers.utils.parseEther("0.01") });

    await expect(contract.safeBatchTransferFrom(owner.address, otherAccount.address,[0,1], [1], "0x00000000"))
      .to.be.revertedWith("ERC1155: ids and amounts length mismatch");
  });

  it("Should NOT transfer batch (permission)", async () => {
    const { contract, owner, otherAccount } = await loadFixture(deployFixture);

    await contract.mint(0, { value: ethers.utils.parseEther("0.01") });
    await contract.mint(1, { value: ethers.utils.parseEther("0.01") });

    const instance = contract.connect(otherAccount);

    await expect(instance.safeBatchTransferFrom(owner.address, otherAccount.address,[0,1], [1,1], "0x00000000"))
      .to.be.revertedWith("ERC1155: caller is not token owner or approved");
  });

  it("Should support interface", async () => {
    const { contract } = await loadFixture(deployFixture);

    const supports = await contract.supportsInterface("0xd9b67a26");
    expect(supports).to.equal(true, "Doesn't support interface");
  });

  it("Should withdraw", async () => {
    const { contract, owner, otherAccount } = await loadFixture(deployFixture);

    const instance = contract.connect(otherAccount);
    await instance.mint(0, { value: ethers.utils.parseEther("0.01") });

    const contractBalanceBefore = await contract.provider.getBalance(contract.address);
    const ownerBalanceBefore = await contract.provider.getBalance(owner.address);

    await contract.withdraw();
    
    const contractBalanceAfter = await contract.provider.getBalance(contract.address);
    const ownerBalanceAfter = await contract.provider.getBalance(owner.address);

    expect(contractBalanceBefore).to.equal(ethers.utils.parseEther("0.01"), "Cannot withdraw");
    expect(contractBalanceAfter).to.equal(0, "Cannot withdraw");
    expect(ownerBalanceAfter).to.greaterThan(ownerBalanceBefore, "Cannot withdraw");
  });

  it("Should NOT withdraw (permission)", async () => {
    const { contract, owner, otherAccount } = await loadFixture(deployFixture);

    const instance = contract.connect(otherAccount);
    await instance.mint(0, { value: ethers.utils.parseEther("0.01") });

    await expect(instance.withdraw()).to.be.revertedWith("You do not have permission");
  });

  it("Should has URI metadata", async () => {
    const { contract } = await loadFixture(deployFixture);

    await contract.mint(0, { value: ethers.utils.parseEther("0.01") });

    const uri = await contract.uri(0);
    expect(uri).to.equal("https://www.luiztools.com.br/tokens/0.json", "Wrong token URI");
  });

  it("Should NOT has URI metadata", async () => {
    const { contract, owner, otherAccount } = await loadFixture(deployFixture);

    await expect(contract.uri(3))
      .to.be.revertedWith("This token does not exists");
  });
});