// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const tokenClient = await deploy("TokenClient");
  const tokenERC20 = await deploy("TokenERC20");
  const tokenERC721 = await deploy("TokenERC721");
  const tokenERC1155 = await deploy("TokenERC1155");
  const tokenLSP7 = await deploy("TokenLSP7");
  const tokenLSP8 = await deploy("TokenLSP8");

  console.log("TokenClient:", tokenClient.address);
  console.log("TokenERC20:", tokenERC20.address);
  console.log("TokenERC721:", tokenERC721.address);
  console.log("TokenERC1155:", tokenERC1155.address);  
  console.log("TokenLSP7:", tokenLSP7.address);
  console.log("TokenLSP8:", tokenLSP8.address); 
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
  
async function deploy(contractName, ...params){
  const factory = await hre.ethers.getContractFactory(contractName);
  const contract = await factory.deploy(...params); 
  await contract.deployed(); 
  return contract;
}
