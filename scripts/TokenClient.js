const { ethers } = require("hardhat"); 
const fs = require('fs');

exports.ERC20 = ethers.utils.formatBytes32String("ERC20");
exports.ERC721 = ethers.utils.formatBytes32String("ERC721");
exports.ERC1155 = ethers.utils.formatBytes32String("ERC1155");
exports.ERC777 = ethers.utils.formatBytes32String("ERC777");
exports.LSP7 = ethers.utils.formatBytes32String("LSP7DigitalAsset");
exports.LSP8 = ethers.utils.formatBytes32String("LSP8IdentifiableDigitalAsset");

exports.tokenClientABI = JSON.parse(fs.readFileSync("./artifacts/contracts/TokenClient.sol/TokenClient.json")).abi;   
 
exports.tokenizeERC20 = function(contractAddress, amount){
    return [exports.ERC20, contractAddress, ethers.constants.HashZero, amount];
}
exports.tokenizeERC721 = function(contractAddress, tokenId){
    return [exports.ERC721, contractAddress, ethers.utils.hexZeroPad(ethers.utils.hexlify(tokenId), 32), 1];
}
exports.tokenizeSetERC721 = function(contractAddress, tokenIds){
    return [exports.ERC721, contractAddress, tokenIds.map(tokenId => ethers.utils.hexZeroPad(ethers.utils.hexlify(tokenId), 32)), tokenIds.map(tokenId => ethers.BigNumber.from(1))];
}
exports.tokenizeERC1155 = function(contractAddress, tokenId, amount){
    return [exports.ERC1155, contractAddress, ethers.utils.hexZeroPad(ethers.utils.hexlify(tokenId), 32), amount];
} 
exports.tokenizeSetERC1155 = function(contractAddress, tokenIds, amounts){
    return [exports.ERC1155, contractAddress, tokenIds.map(tokenId => ethers.utils.hexZeroPad(ethers.utils.hexlify(tokenId), 32)), amounts];
} 
exports.tokenizeERC777 = function(contractAddress, amount){
    return [exports.ERC777, contractAddress, ethers.constants.HashZero, amount];
}
exports.tokenizeLSP7 = function(contractAddress, amount){
    return [exports.LSP7, contractAddress, ethers.constants.HashZero, amount];
}
exports.tokenizeLSP8 = function(contractAddress, tokenId){
    return [exports.LSP8, contractAddress, ethers.utils.hexZeroPad(ethers.utils.hexlify(tokenId), 32), 1];
}
exports.tokenizeSetLSP8 = function(contractAddress, tokenIds){
    return [exports.LSP8, contractAddress, tokenIds.map(tokenId => ethers.utils.hexZeroPad(ethers.utils.hexlify(tokenId), 32)), tokenIds.map(tokenId => ethers.BigNumber.from(1))];
}
