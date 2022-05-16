const { ethers } = require("hardhat");
require("dotenv").config({ path: ".env"});
const { WHITELIST_CONTRACT_ADDRESS, METADATA_URL } = require("../constants");

async function main() {
    const whitelistContract = WHITELIST_CONTRACT_ADDRESS;
    const metadataURL = METADATA_URL;

    const cryptoDevContract = await ethers.getContractFactory("CryptoDev");
    const args = [metadataURL, whitelistContract];
    const CryptoDevContractDeployed = await cryptoDevContract.deploy(args[0], args[1]);
    console.log("Deploying...")
    await CryptoDevContractDeployed.deployed();
    console.log(`Contract deployed to ${CryptoDevContractDeployed.address}`);
    console.log(`Verify with \n npx hardhat verify --network goerli ${CryptoDevContractDeployed.address} ${args.toString().replace(/,/g, " ")}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

