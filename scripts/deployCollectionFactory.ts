import { utils, constants, BigNumber, getDefaultProvider, Wallet, ContractFactory, Contract } from 'ethers';
import { ethers, run, network } from "hardhat";
//import { ethers } from "ethers";
require("dotenv").config();
import { wallet } from "../config/constants";
//import { verifyTask } from "@nomiclabs/hardhat-etherscan";

import { CollectionFactory__factory, NFTMarketplace__factory } from '../typechain-types';
//const wallet = process.env.PRIVATE_KEY;

const avalancheCollectionFactoryAddr = "0xf6F91bebE59C96367E5040144b78342e413DC635"
const goerliCollectionFactoryAddr = "0x3a65168B746766066288B83417329a7F901b5569"
const mumbaiCollectionFactoryAddr = "0x923A3A12280CF6530e367e4B14Ad9a559040667a"

const feePayerAddress = "0x5e869af2Af006B538f9c6D231C31DE7cDB4153be";

const chainNames = ["Mumbai"];
const chainsInfo: any = [];
const chains = [
    {
        name: "Avalanche",
        rpc: "https://rpc.ankr.com/avalanche_fuji",
        gateway: "0x94caA85bC578C05B22BDb00E6Ae1A34878f047F7",
        chainId: 43113,
        contractAddr: "0xf6F91bebE59C96367E5040144b78342e413DC635",
        hreName: "avalancheFujiTestnet"

    },
    {
        name: "Arbitrum",
        rpc: "https://goerli-rollup.arbitrum.io/rpc",
        gateway: "0xcAa6223D0d41FB27d6FC81428779751317FC24cB",
        chainId: 421613,
        contractAddr: "",
        hreName: "arbitrumGoerli"
    },
    {
        name: "Mumbai",
        rpc: "https://polygon-mumbai.g.alchemy.com/v2/Ksd4J1QVWaOJAJJNbr_nzTcJBJU-6uP3",
        gateway: "0x94caA85bC578C05B22BDb00E6Ae1A34878f047F7",
        chainId: 80001,
        contractAddr: "0x923A3A12280CF6530e367e4B14Ad9a559040667a",
        hreName: "polygonMumbai"
    },
    {
        name: "Goerli",
        rpc: "https://goerli.infura.io/v3/a4812158fbab4a2aaa849e6f4a6dc605",
        gateway: "0x94caA85bC578C05B22BDb00E6Ae1A34878f047F7",
        chainId: 5,
        contractAddr: "0x3a65168B746766066288B83417329a7F901b5569",
        hreName: "goerli"
    }
]

export async function main() {

    for (let i = 0; i < chainNames.length; i++) {
        let chainName = chainNames[i];
        //let chainInfo = chainsInfo[i];
        let chainInfo = chains.find((chain: any) => {
            if (chain.name === chainName) {
                chainsInfo.push(chain);
                return chain;
            }
        });

        //console.log(`Deploying [${chainName}]`);
        //promises.push(deploy(chainInfo, wallet));

        // //const estimatedGas: any = await estimateGas(GovernanceToken, chainInfo, wallet);
        // const bufferGas: any = BigInt(Math.floor(estimatedGas * 1.7))

        // const bigNumber = ethers.BigNumber.from(bufferGas);
        // const jsGasLimit = bigNumber.toNumber();
        // console.log(jsGasLimit)

        //await deployCollectionFactory(chainInfo, wallet, 6000000);
        const chainID = network.config.chainId;
        if (chainID != 31337) {
            await verifyContract(chainInfo)
        }
        // cnIndex += 1;
    }
}



async function deployCollectionFactory(chain: any, wallet: any, _gasLimit: any) {
    console.log(`Deploying Collection Factory for ${chain.name}.`);
    const provider = getDefaultProvider(chain.rpc);
    const connectedWallet = wallet.connect(provider);
    const collectonFactoryFactory = new CollectionFactory__factory(connectedWallet);
    const contract = await collectonFactoryFactory.deploy({ gasLimit: _gasLimit });
    await contract.deployed();
    console.log(`The Collection Factory for ${chain.name} has been deployed at ${contract.address}`);

}

async function verifyContract(chain: any) {

    console.log(`Verifying Collection Factory contract for ${chain.name}...`);

    try {
        await run("verify:verify", {
            address: chain.contractAddr,
            constructorArguments: [],
        });
        //console.log(`contract for ${chain.name} verified`);
    } catch (e: any) {
        if (e.message.toLowerCase().includes("already verified")) {
            console.log("Already verified!");
        } else {
            console.log(e);
        }
    }
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});