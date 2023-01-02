// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
 
import "@openzeppelin/contracts/token/ERC721/ERC721.sol"; 

contract TestERC721 is ERC721
{
  uint256 private _tokenCount;

  constructor() ERC721("Test", "TEST"){ }
 
  function mint(address to) external returns (uint256 tokenId) { 
    tokenId = ++_tokenCount; 
    _safeMint(to, tokenId, "");
  }

  function _baseURI() internal pure override returns (string memory) {
      return "ipfs://bafybeigpqbtx6fr46bzzmb2cgdjkzmwqrkemrl5a7pyfuwha5ozekqxkbq/";
  }
}