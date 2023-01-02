// SPDX-License-Identifier: GNU-3
pragma solidity ^0.8.17;
 
import "@lukso/lsp-smart-contracts/contracts/LSP8IdentifiableDigitalAsset/LSP8IdentifiableDigitalAsset.sol";

contract TestLSP8 is LSP8IdentifiableDigitalAsset
{
  uint256 private _tokenCount;

  constructor() LSP8IdentifiableDigitalAsset("Test", "TEST", msg.sender){ }
 
 function mint(address to) public returns (uint256 tokenId) { 
    tokenId = ++_tokenCount; 
    _mint(to, bytes32(tokenId), true, "");
  }
}