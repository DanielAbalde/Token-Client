// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
    Data layout for a fungible or non-fungible token.

    Standard is represented as bytes32 instead of bytes4 for a string based mapping between token data and token operator, such as "ERC20" or "ERC721".
    Contract is the address of the token contract.
    Id is the token identification for non-fungible tokens, or empty (bytes32(0)) for fungible tokens. It uses bytes32 instead of uint256 to support more identification types.
    Amount is the quantity of tokens for fungible tokens, or 1 for non-fungible tokens.
*/
struct Token
{
    bytes32 Standard;
    address Contract;
    bytes32 Id;
    uint256 Amount;  
}

/*
    Data layout for multiple fungible and non-fungible tokens of the same contract.

    Standard is represented as bytes32 instead of bytes4 for a string based mapping between token data and token operator, such as "ERC20" or "ERC721".
    Contract is the address of the token contract.
    Ids are the token identifications for non-fungible tokens, or empty (bytes32(0)) for fungible tokens. It uses bytes32 instead of uint256 to support more identification types.
    Amounts are the quantities of tokens for fungible tokens, or 1 for each non-fungible token.
*/
struct TokenSet
{
    bytes32 Standard;
    address Contract;
    bytes32[] Ids;
    uint256[] Amounts;  
}