import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.connect();

describe("HelloWorld", () => {
  it("Should Hello the world", async () => {
    const helloWorld = await ethers.deployContract("HelloWorld");
    expect(await helloWorld.helloWorld()).equal("Hello World!");
  });
});
