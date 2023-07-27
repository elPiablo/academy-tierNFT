require("ethers");
// const hre = require('hardhat')


/** Set contract and collection name **/
const CONTRACT_NAME = 'TierNFT'
const COLLECTION_NAME = 'TierNFT'
const COLLECTION_SYMBOL = 'Tier'

/** Main deploy function **/
async function main() {
  const contractFactory = await ethers.getContractFactory(CONTRACT_NAME)
  const contract = await contractFactory.deploy(
    COLLECTION_NAME,
    COLLECTION_SYMBOL,
  )
  await contract.waitForDeployment()
  // original ethers v5:
  //   console.log(`Contract deployed to ${contract.address}`)

  // Print our newly deployed contract address (ethers v6)
  const address = await contract.getAddress();
    console.log(`Contract Address: ${address}`);
}

/** Run Main function - Do not change **/
main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})