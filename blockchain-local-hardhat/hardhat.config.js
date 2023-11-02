/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.19",
  defaultNetwork: "running",
  networks: {
    hardhat: {
      chainId: 1337,
      //deploy configs below
      //url: "http://localhost:8545/",
      //accounts: {
      //  mnemonic: "test test test test test test test test test test test junk"
      //}
    }
  },
  running: {
    url: "http://localhost:8545",
    chainId: 1337
  }
};
