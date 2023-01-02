// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
 
struct TokenSet
{
    bytes32 Standard;
    address Contract;
    bytes32[] Ids;
    uint256[] Amounts;  
}