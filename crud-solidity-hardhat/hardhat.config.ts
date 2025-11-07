import type { HardhatUserConfig } from "hardhat/config";

import hardhatToolboxMochaEthersPlugin from "@nomicfoundation/hardhat-toolbox-mocha-ethers";
import "dotenv/config";

const config: HardhatUserConfig = {
  plugins: [hardhatToolboxMochaEthersPlugin],
  solidity: {
    profiles: {
      default: {
        version: "0.8.28",
      },
      production: {
        version: "0.8.28",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    },
  },
  networks: {
    hardhatMainnet: {
      type: "edr-simulated",
      chainType: "l1",
    },
    hardhatOp: {
      type: "edr-simulated",
      chainType: "op",
    },
    bnbtest: {
      type: "http",
      chainType: "l1",
      url: `${process.env.RPC_NODE}`,
      chainId: parseInt(`${process.env.CHAIN_ID}`),
      accounts: [`${process.env.PRIVATE_KEY}`]
    }
  },
  verify: {
    etherscan: {
      apiKey: process.env.API_KEY
    },
  },
  chainDescriptors: {
    80002: {
      name: "amoy",
      blockExplorers: {
        etherscan: {
          name: "amoy",
          url: "https://amoy.polygonscan.com",
          apiUrl: "https://api-amoy.polygonscan.com/",
        },
      },
    },
  },
};

export default config;
