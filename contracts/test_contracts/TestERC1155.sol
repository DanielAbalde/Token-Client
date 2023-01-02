// SPDX-License-Identifier: GNU-3
pragma solidity ^0.8.17;
 
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol"; 

contract TestERC1155 is ERC1155
{
  uint256 private _tokenCount;

  constructor() ERC1155("ipfs://bafybeigpqbtx6fr46bzzmb2cgdjkzmwqrkemrl5a7pyfuwha5ozekqxkbq/"){ }
 
 function mint(address to, uint256 amount) external returns (uint256 tokenId) { 
    tokenId = ++_tokenCount; 
    _mint(to, tokenId, amount, "");
  }
}