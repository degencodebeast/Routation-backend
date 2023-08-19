import { utils, constants, BigNumber, getDefaultProvider, Wallet, ContractFactory, Contract } from 'ethers';
import { ethers, network, run} from "hardhat";
//import { ethers } from "ethers";
require("dotenv").config();
import { wallet } from "../config/constants";
//import { verifyTask } from "@nomiclabs/hardhat-etherscan";

import { CollectionFactory__factory, NFTMarketplace__factory } from '../typechain-types';
//const wallet = process.env.PRIVATE_KEY;
const avalancheMarketplaceAddr = "0x7F703a941f157211D4B4e0fb28155bCB2E791d16"
const goerliMarketplaceAddr = "0x9E1eF5A92C9Bf97460Cd00C0105979153EA45b27"
const mumbaiMarketplaceAddr = "0xEdbA69884E6d18f75F352dE739B1ab57Cc61b500"

const feePayerAddress = "0x5e869af2Af006B538f9c6D231C31DE7cDB4153be";
const constructorArgs = []


const chainNames = ["Goerli"];
const chainsInfo: any = [];
const chains = [
    {
        name: "Avalanche",
        rpc: "https://rpc.ankr.com/avalanche_fuji",
        gateway: "0x94caA85bC578C05B22BDb00E6Ae1A34878f047F7",
        chainId: 43113,
        contractAddr: "0x7F703a941f157211D4B4e0fb28155bCB2E791d16",
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
        contractAddr: "0xEdbA69884E6d18f75F352dE739B1ab57Cc61b500",
        hreName: "polygonMumbai"
    },
    {
        name: "Goerli",
        rpc: "https://goerli.infura.io/v3/a4812158fbab4a2aaa849e6f4a6dc605",
        gateway: "0x94caA85bC578C05B22BDb00E6Ae1A34878f047F7",
        chainId: 5,
        contractAddr: "0x9E1eF5A92C9Bf97460Cd00C0105979153EA45b27",
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

        //await deployMarketplace(chainInfo, wallet, 6000000);
        const chainID = network.config.chainId;
        if (chainID != 31337) {
            await verifyContract(chainInfo)
        }
        
        // cnIndex += 1;
    }
}

async function deployMarketplace(chain: any, wallet: any, _gasLimit: any) {
    console.log(`Deploying NFT Marketplace for ${chain.name}.`);
    const provider = getDefaultProvider(chain.rpc);
    const connectedWallet = wallet.connect(provider);
    const nftMarketplaceFactory = new NFTMarketplace__factory(connectedWallet);
    const contract = await nftMarketplaceFactory.deploy(chain.gateway, feePayerAddress, chain.chainId, {gasLimit: _gasLimit});
    await contract.deployed();
    console.log(`The NFT Marketplace for ${chain.name} has been deployed at ${contract.address}`);
    
}


async function verifyContract(chain: any) {
    
    console.log(`Verifying NFT Marketplace contract for ${chain.name}...`);  

    try {
        await run("verify:verify", {
            address: chain.contractAddr,
            constructorArguments: [chain.gateway, feePayerAddress, chain.chainId],
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