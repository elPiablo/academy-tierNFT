const hre = require('hardhat')

/** Set contract and collection name **/
const CONTRACT_NAME = 'TierNFT'
const COLLECTION_NAME = 'TierNFT'
const COLLECTION_SYMBOL = 'Tier'

/** Main deploy function **/
async function main() {
  const contractFactory = await hre.ethers.getContractFactory(CONTRACT_NAME)
  const contract = await contractFactory.deploy(
    COLLECTION_NAME,
    COLLECTION_SYMBOL,
  )

  await contract.waitForDeployment()
  // Print our newly deployed contract address
  console.log("Contract deployed at", await contract.getAddress())
}

/** Run Main function - Do not change **/
main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
