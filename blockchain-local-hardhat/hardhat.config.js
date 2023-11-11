/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.19",
  networks: {
    local: {
      chainId: 31337,
      url: "http://localhost:8545/",
      accounts: {
        mnemonic: "test test test test test test test test test test test junk"
      }
    }
  }
};
