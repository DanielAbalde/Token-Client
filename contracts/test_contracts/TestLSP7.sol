// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
 
import "@lukso/lsp-smart-contracts/contracts/LSP7DigitalAsset/LSP7DigitalAsset.sol";

contract TestLSP7 is LSP7DigitalAsset
{ 
  constructor() LSP7DigitalAsset("Test", "TEST", msg.sender, true){ }
 
 function mint(address to, uint256 amount) public {  
    _mint(to, amount, true, "");
  }
}