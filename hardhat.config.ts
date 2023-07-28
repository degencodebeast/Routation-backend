// // // import { HardhatUserConfig, task } from "hardhat/config";
// // // import "@nomicfoundation/hardhat-toolbox";

// // // task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
// // //   const accounts = await hre.ethers.getSigners();

// // //   for (const account of accounts) {
// // //     console.log(account.address);
// // //     console.log((await account.getBalance()).toString());
// // //   }
// // // });


// // // const config: HardhatUserConfig = {
// // //   paths: { tests: "tests" },
// // //   solidity: "0.8.17",
// // // };

// // // export default config;

// // /* eslint-disable prettier/prettier */
// // /* eslint-disable node/no-missing-import */
// // import * as dotenv from "dotenv";

// // import { HardhatUserConfig, task } from "hardhat/config";
// // import "@nomiclabs/hardhat-etherscan";
// // import "@nomiclabs/hardhat-waffle";
// // import "@nomiclabs/hardhat-ethers";
// // import "@typechain/hardhat";
// // import "hardhat-gas-reporter";
// // import "solidity-coverage";
// // import "./tasks/index";

// // dotenv.config();

// // // This is a sample Hardhat task. To learn how to create your own go to
// // // https://hardhat.org/guides/create-task.html
// // task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
// //   const accounts = await hre.ethers.getSigners();

// //   for (const account of accounts) {
// //     console.log(account.address);
// //   }
// // });

// // // You need to export an object to set up your config
// // // Go to https://hardhat.org/config/ to learn more

// // const mnemonic = process.env.MNEMONIC || "";

// // const config: HardhatUserConfig = {
// //   solidity: {
// //     compilers: [
// //       {
// //         version: "0.8.0",
// //       },
// //       {
// //         version: "0.8.4",
// //       },
// //     ],
// //     settings: {
// //       evmVersion: "berlin",
// //       metadata: {
// //         // Not including the metadata hash
// //         // https://github.com/paulrberg/solidity-template/issues/31
// //         bytecodeHash: "none",
// //       },
// //       // You should disable the optimizer when debugging
// //       // https://hardhat.org/hardhat-network/#solidity-optimizer-support
// //       optimizer: {
// //         enabled: true,
// //         runs: 200,
// //       },
// //     },
// //   },
// //   //  defaultNetwork: "kovan",
// //   networks: {
// //     polygon: {
// //       url: process.env.MATIC_RPC || "",
// //       accounts: [mnemonic],
// //     },
// //     bsc: {
// //       url: process.env.BSC_RPC || "",
// //       accounts: [mnemonic],
// //     },
// //     ftm: {
// //       url: process.env.FTM_RPC || "",
// //       accounts: [mnemonic],
// //     },
// //   },
// //   gasReporter: {
// //     enabled: process.env.REPORT_GAS !== undefined,
// //     currency: "USD",
// //   },
// //   // etherscan: {
// //   //   apiKey: {
// //   //     polygon: process.env.POLYGON_ETHERSCAN_KEY,
// //   //     polygonMumbai: process.env.POLYGON_KEY,
// //   //     bsc: process.env.BSC_KEY,
// //   //     opera: process.env.FTMSCAN_KEY,
// //   //   },
// //   // },
// // };

// // export default config;

// import { HardhatUserConfig } from "hardhat/config";
// // import "@nomiclabs/hardhat-waffle";
// // import "@typechain/hardhat";
// // import "@openzeppelin/hardhat-upgrades";
// import "@nomicfoundation/hardhat-toolbox";
// import 'hardhat-gas-reporter';
// import "solidity-coverage";
// import { resolve } from "path";
// import { config as dotenvConfig } from "dotenv";
// import { NetworkUserConfig } from "hardhat/types";
// import "@nomiclabs/hardhat-etherscan";
// import "./tasks";

// dotenvConfig({ path: resolve(__dirname, "./.env") });

// const chainIds = {
//   ganache: 5777,
//   goerli: 5,
//   hardhat: 7545,
//   kovan: 42,
//   mainnet: 1,
//   rinkeby: 4,
//   bscTestnet: 97,
//   bsc: 56,
//   ropsten: 3,
//   mumbai: 80001,
//   avalanche: 43114,
//   polygon: 137,
//   fuji: 43113,
//   arbitrum: 42161,
//   arbitrum_rinkeby: 421611,
//   fantom_testnet: 4002,
//   optimism: 10,
//   optimism_kovan: 69,
//   fantom: 250,
//   harmony: 1666600000,
//   cronos: 25,
//   aurora: 1313161554,
//   kava: 2222,
//   stardust: 588,
//   moonbeam: 1284,
// };

// // Ensure that we have all the environment variables we need.
// const mnemonic = process.env.PRIVATE_KEY;

// if (!mnemonic) {
//   throw new Error("Please set your MNEMONIC in a .env file");
// }

// const infuraApiKey = process.env.INFURA_API_KEY;
// if (!infuraApiKey) {
//   throw new Error("Please set your INFURA_API_KEY in a .env file");
// }

// function getChainConfig(network: keyof typeof chainIds): NetworkUserConfig {
//   let url = "";
//   url = "https://" + network + ".infura.io/v3/" + infuraApiKey;
//   if (network == "polygon") {
//     url =
//       "https://polygon-mainnet.g.alchemy.com/v2/hCz4x1BLpLDP3NoomXivfaqND37qCSgS";
//   } else if (network == "mumbai") {
//     url = "https://matic-mumbai.chainstacklabs.com";
//   } else if (network == "bsc") {
//     url = "https://bsc-dataseed.binance.org/";
//   } else if (network == "avalanche") {
//     url = "https://api.avax.network/ext/bc/C/rpc";
//   } else if (network == "arbitrum") {
//     //42161
//     url =
//       "https://arbitrum-mainnet.infura.io/v3/fd9c5dbc69de41048405e7072cda9bf9";
//   } else if (network == "optimism") {
//     //10
//     url = "https://mainnet.optimism.io";
//   } else if (network == "fantom") {
//     //250
//     url = "https://rpc.ankr.com/fantom";
//   } else if (network == "mainnet") {
//     //1
//     url = "https://mainnet.infura.io/v3/0d73cc5bbe184146957a9d00764db99f";
//     // console.log(url, process.env.PRIVATE_KEY)
//   } else if (network == "harmony") {
//     //1
//     url = "https://api.harmony.one";
//     // console.log(url, process.env.PRIVATE_KEY)
//   } else if (network == "aurora") {
//     //1
//     url = "https://mainnet.aurora.dev";
//     // console.log(url, process.env.PRIVATE_KEY)
//   } else if (network == "cronos") {
//     //1
//     url = "https://rpc.artemisone.org/cronos";
//     //https://rpc.artemisone.org/cronos
//     // console.log(url, process.env.PRIVATE_KEY)
//   } else if (network == "kava") {
//     //1
//     url = "https://evm.kava.io";
//     // console.log(url, process.env.PRIVATE_KEY)
//   } else if (network == "stardust") {
//     //1
//     url = "https://stardust.metis.io/?owner=588";
//     // console.log(url, process.env.PRIVATE_KEY)
//   } else if (network == "moonbeam") {
//     //1
//     url = "https://moonbeam.api.onfinality.io/public";
//     // console.log(url, process.env.PRIVATE_KEY)
//   } else if (network == "fuji") {
//     //1
//     url = "https://api.avax-test.network/ext/bc/C/rpc";
//     // console.log(url, process.env.PRIVATE_KEY)
//   } else if (network == "goerli") {
//     //1
//     // url = "https://goerli.infura.io/v3/d19691ef05dc486a820545f387b66efc";
//     url = "https://goerli.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161";
//     // console.log(url, process.env.PRIVATE_KEY)
//   } else if (network == "bscTestnet") {
//     url = "https://bsc-testnet.public.blastapi.io";
//   }
//   return {
//     // accounts: {
//     //   count: 10,
//     //   mnemonic,
//     //   path: "m/44'/60'/0'/0",
//     //   initialIndex:2,
//     // },
//     accounts: [`${process.env.PRIVATE_KEY}`],
//     chainId: chainIds[network],
//     url,
//     // gas: 10000000,
//     // // gasPrice: network == "bsc" ? 20000000000 : 200000000000,
//     // gasPrice: 4500000000,
//   };
// }

// const config = {
//   defaultNetwork: "hardhat",
//   gasReporter: {
//     currency: "USD",
//     enabled: process.env.REPORT_GAS ? true : false,
//     excludeContracts: [],
//     src: "./contracts",
//   },
//   networks: {
//     hardhat: {
//       accounts: [
//         {
//           privateKey:
//             "c1367107a89e263a950c3dad299c93f413da3c594f7c92a0295b93836832e765",
//           balance: "1000000000000000000000000",
//         },
//         {
//           privateKey:
//             "12e497f0b5743c8fae1d46078a8b220057626be62da081835a7de3dc8bdb9d80",
//           balance: "1000000000000000000000000",
//         },
//         {
//           privateKey:
//             "f4b520a953f8dd09c0913a55228b48280acb1cf48920d680893df5529e2defcb",
//           balance: "1000000000000000000000000",
//         },
//         {
//           privateKey:
//             "e4fac76eca7722938f19aa88dfa5ca28a42cf7e54897ddcdc50959948746ca2e",
//           balance: "1000000000000000000000000",
//         },
//         {
//           privateKey:
//             "b57b6c96fb47d10493b5aa0be542a456af15617510512040344d01393a5e8f79",
//           balance: "1000000000000000000000000",
//         },
//         {
//           privateKey:
//             "17981adb72e83b957c81993ef878f6529fec1385e6bbc25c6b602349d13dc04b",
//           balance: "1000000000000000000000000",
//         },
//       ],
//       chainId: chainIds.hardhat,
//       mining: {
//         auto: true,
//         interval: 100,
//       },
//     },
//     ganache1: {
//       chainId: 7545,
//       url: "https://rc-testnet1.routerprotocol.com/",
//       accounts: [mnemonic],
//     },
//     ganache2: {
//       chainId: 6545,
//       url: "https://rc-testnet3.routerprotocol.com/",
//       accounts: [mnemonic],
//     },

//     ropsten: {
//       saveDeployments: true,
//       accounts: {
//         initialIndex: 0,
//         mnemonic,
//         // path: "m/44'/60'/0'/0",
//       },
//       chainId: chainIds["ropsten"],
//       url: "https://ropsten.infura.io/v3/" + infuraApiKey + "",
//     },
//     rinkeby: {
//       saveDeployments: true,
//       accounts: {
//         initialIndex: 0,
//         mnemonic,
//         // path: "m/44'/60'/0'/0",
//       },
//       chainId: chainIds["rinkeby"],
//       url: "https://rinkeby.infura.io/v3/" + infuraApiKey + "",
//     },
//     polygonMumbai: {
//       saveDeployments: true,
//       accounts: [mnemonic],
//       chainId: chainIds["mumbai"],
//       url: "https://matic-mumbai.chainstacklabs.com",
//     },

//     kovan: getChainConfig("kovan"),
//     polygon: getChainConfig("polygon"),
//     bsc: getChainConfig("bsc"),
//     avalanche: getChainConfig("avalanche"),

//     arbitrum: getChainConfig("arbitrum"),
//     fantom: getChainConfig("fantom"),
//     optimism: getChainConfig("optimism"),
//     mainnet: getChainConfig("mainnet"),
//     harmony: getChainConfig("harmony"),
//     aurora: getChainConfig("aurora"),
//     cronos: getChainConfig("cronos"),
//     kava: getChainConfig("kava"),
//     stardust: getChainConfig("stardust"),
//     moonbeam: getChainConfig("moonbeam"),
//     fuji: getChainConfig("fuji"),
//     goerli: getChainConfig("goerli"),
//     mumbai: getChainConfig("mumbai"),
//     bsctestnet: getChainConfig("bscTestnet"),
//   },
//   paths: {
//     artifacts: "./artifacts",
//     cache: "./cache",
//     sources: "./contracts",
//     // deploy: "./deploy",
//     deployments: "./deployments",
//     // imports: "./imports",
//   },
//   solidity: {
//     version: "0.8.7",
//     settings: {
//       evmVersion: "berlin",
//       metadata: {
//         // Not including the metadata hash
//         // https://github.com/paulrberg/solidity-template/issues/31
//         bytecodeHash: "none",
//       },
//       // You should disable the optimizer when debugging
//       // https://hardhat.org/hardhat-network/#solidity-optimizer-support
//       optimizer: {
//         enabled: true,
//         runs: 50000,
//       },
//     },
//   },

//   typechain: {
//     outDir: "typechain",
//     target: "ethers-v5",
//   },
//   namedAccounts: {
//     deployer: 0,
//   },
//   etherscan: {
//     apiKey: {
//       // kovan: process.env.MAINNET_ETHERSCAN_KEY,
//       polygonMumbai: process.env.POLYGONSCAN_API_KEY,
//       // polygon: process.env.POLYGONSCAN_API_KEY,
//       // bsc: process.env.BSC_ETHERSCAN_KEY,
//       // avalanche: "QAE2JD7XIBCYB6Z6GSKNJIHKZ8XGVYM8AI",
//       // opera: process.env.FTMSCAN_KEY,
//       // arbitrumOne: process.env.ARBITRUM_KEY,
//       // optimisticEthereum: process.env.OPTIMISM_KEY,
//       // mainnet: process.env.ETH_ETHERSCAN_KEY,
//       // aurora: process.env.AURORA_KEY,
//       // harmony: process.env.HARMONY_KEY,
//       // moonbeam: process.env.MOONBEAM_ETHERSCAN_KEY,
//       // kava: process.env.MOONBEAM_ETHERSCAN_KEY,
//       // goerli: process.env.ETHERSCAN_API_KEY,
//       avalancheFujiTestnet: process.env.AVALANCHE_API_KEY,
//       // bscTestnet: process.env.BSCSCAN_API_KEY
//     },

//     customChains: [
//       {
//         network: "cronos",
//         chainId: 25,
//         urls: {
//           apiURL: "https://api.cronoscan.com/api",
//           browserURL: "https://cronoscan.com/",
//         },
//       },
//       {
//         network: "kava",
//         chainId: 2222,
//         urls: {
//           apiURL: "https://explorer.kava.io/api",
//           browserURL: "https://explorer.kava.io/",
//         },
//       },
//       {
//         network: "moonbeam",
//         chainId: 1284,
//         urls: {
//           apiURL: "https://api-moonbeam.moonscan.io/api/",
//           browserURL: "https://moonscan.io/",
//         },
//       },
//     ],
//   },
// };

// export default config;

import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@openzeppelin/hardhat-upgrades";
import "@nomiclabs/hardhat-etherscan";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.18",
    settings: {
      evmVersion: process.env.EVM_VERSION || 'london',
      optimizer: {
        enabled: true,
        runs: 200,
        details: {
          peephole: true,
          inliner: true,
          jumpdestRemover: true,
          orderLiterals: true,
          deduplicate: true,
          cse: true,
          constantOptimizer: true,
          yul: true,
          yulDetails: {
            stackAllocation: true,
          },
        },
      },

    }
  },
  networks: {
    sepolia: {
      url: "https://eth-sepolia.g.alchemy.com/v2/s-hdjLqITCIC-0yx948QMzzi7v-43Sss",
      accounts: [
        "5acc566e889da617b7f8032ed5f745af8ad695ec2f5421b42b09be517067c051" ??
          "",
      ],
    },
    mumbai: {
      url: "https://polygon-mumbai.infura.io/v3/7367c86527024f0daa1d03b7b64faa7d",
      accounts: [
        "5acc566e889da617b7f8032ed5f745af8ad695ec2f5421b42b09be517067c051" ??
          "",
      ],
    },
    bscTestnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
      accounts: [
        "5acc566e889da617b7f8032ed5f745af8ad695ec2f5421b42b09be517067c051" ??
          "",
      ],
    },
    chiado: {
      url: "https://rpc.chiadochain.net	",
      accounts: [
        "5acc566e889da617b7f8032ed5f745af8ad695ec2f5421b42b09be517067c051" ??
          "",
      ],
      gasPrice: 11000000000,
    },
    avalancheFujiTestnet: {
      url: "https://avalanche-fuji-c-chain.publicnode.com	",
      accounts: [
        "5acc566e889da617b7f8032ed5f745af8ad695ec2f5421b42b09be517067c051" ??
          "",
      ],
    },
  },
  etherscan: {
    apiKey: {
      polygon: "7RQGFQS84Q5FNNF84YQ61T3MQDJ5Y1EB1B" ?? "",
      polygonMumbai: "7RQGFQS84Q5FNNF84YQ61T3MQDJ5Y1EB1B" ?? "",
      goerli: "1T7UC6DGWNA36AVHC4IGIRRE1MTGCSKE74" ?? "",
      sepolia: "1T7UC6DGWNA36AVHC4IGIRRE1MTGCSKE74" ?? "",
      bscTestnet: "GWKE3MR5JXP1KVY4635YHC8AKI7FI55WK3" ?? "",
      mainnet: "1T7UC6DGWNA36AVHC4IGIRRE1MTGCSKE74" ?? "",
      chiado: "64ffadd2-2ca7-47d5-8f5d-8a91d5e25d27" ?? "",
      avalancheFujiTestnet: "PC8ZV53MFPKCJDDTQSTUVAJ3EYKPUFHDWV" ?? "",
    },
  },
};

export default config;