import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre, { ethers } from "hardhat";

const compare = (bad: bigint, good: bigint) => {
  console.table({
    Bad: bad.toString(),
    Good: good.toString(),
    Saving: `${bad - good} (${((good * 100n) / bad) - 100n}%)`,
  });

  expect(bad).to.greaterThanOrEqual(good);
};

describe("Gas Optimizations", function () {
  it("Compare External x Public functions", async function () {
    const ExternalXPublic = await ethers.getContractFactory("ExternalXPublic");
    const contract = await ExternalXPublic.deploy();

    const badCost = await contract.testPublic.estimateGas();
    const goodCost = await contract.testExternal.estimateGas();

    compare(badCost, goodCost);
  });

  it("Compare Revert (Custom) x Require (Success)", async function () {
    const RevertXRequire = await ethers.getContractFactory("RevertXRequire");
    const contract = await RevertXRequire.deploy();

    const badCost = await contract.testRequire.estimateGas(0);
    const goodCost = await contract.testRevertCustom.estimateGas(0);

    compare(badCost, goodCost);
  });

  it("Compare Revert x Require (Success)", async function () {
    const RevertXRequire = await ethers.getContractFactory("RevertXRequire");
    const contract = await RevertXRequire.deploy();

    const badCost = await contract.testRequire.estimateGas(0);
    const goodCost = await contract.testRevert.estimateGas(0);

    compare(badCost, goodCost);
  });

  it("Compare Memory x Calldata", async function () {
    const StorageXMemoryXCalldata = await ethers.getContractFactory("StorageXMemoryXCalldata");
    const contract = await StorageXMemoryXCalldata.deploy();

    const badCost = await contract.testMemory.estimateGas("test");
    const goodCost = await contract.testCalldata.estimateGas("test");

    compare(badCost, goodCost);
  });

  it("Compare Array Memory x Array Calldata", async function () {
    const StorageXMemoryXCalldata = await ethers.getContractFactory("StorageXMemoryXCalldata");
    const contract = await StorageXMemoryXCalldata.deploy();

    const badCost = await contract.testArrayMemory.estimateGas([1,2,3]);
    const goodCost = await contract.testArrayCalldata.estimateGas([1,2,3]);

    compare(badCost, goodCost);
  });

  it("Compare Validação x Modifier", async function () {
    const ValidacaoXModifier = await ethers.getContractFactory("ValidacaoXModifier");
    const contract = await ValidacaoXModifier.deploy();

    const badCost = await contract.testModifier.estimateGas();
    const goodCost = await contract.testValidacao.estimateGas();

    compare(badCost, goodCost);
  });

  it("Compare Escritas Storage", async function () {
    const OtimizacoesLogicas = await ethers.getContractFactory("OtimizacoesLogicas");
    const contract = await OtimizacoesLogicas.deploy();

    const badCost = await contract.multiplasEscritas.estimateGas();
    const goodCost = await contract.umaEscrita.estimateGas();

    compare(badCost, goodCost);
  });

  it("Compare Leituras Storage", async function () {
    const OtimizacoesLogicas = await ethers.getContractFactory("OtimizacoesLogicas");
    const contract = await OtimizacoesLogicas.deploy();

    const badCost = await contract.multiplasLeituras.estimateGas();
    const goodCost = await contract.umaLeitura.estimateGas();

    compare(badCost, goodCost);
  });

  it("Compare Uso de Struct", async function () {
    const LidandoComStructs = await ethers.getContractFactory("LidandoComStructs");
    const contract = await LidandoComStructs.deploy();

    const badCost = await contract.testBadStruct.estimateGas();
    const goodCost = await contract.testGoodStruct.estimateGas();

    compare(badCost, goodCost);
  });

  it("Compare Loop Struct", async function () {
    const LidandoComStructs = await ethers.getContractFactory("LidandoComStructs");
    const contract = await LidandoComStructs.deploy();

    const badCost = await contract.testLoopAStruct.estimateGas();
    const goodCost = await contract.testLoopBStruct.estimateGas();

    compare(badCost, goodCost);
  });
});
