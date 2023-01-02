<h1 align="center">Token Client</h1> 
<p align="center">Generalizes operations with fungible and non-fungible tokens</p>
 
[TokenClient.sol](contracts/TokenClient.sol) is a smart contract that facilitates support for fungible and non-fungible token operations. It contains a set of [TokenAbstraction](contracts/TokenAbstraction.sol) with read and transfer functions, and its implementations such as [TokenERC20](contracts/concretes/TokenERC20.sol), [TokenERC721](contracts/concretes/TokenERC721.sol) or [TokenERC1155](contracts/concretes/TokenERC1155.sol) are responsible for calling the functions of each standard. For the developer, TokenClient allows to generalize the functionality with the template pattern and support new types of tokens with the proxy pattern.
 

<p align="center"><img src="./assets/TokenClientDiagram.PNG" alt="TokenClientDiagram"></p>

The functionality uses the [Token](contracts/Token.sol) and [TokenSet](contracts/TokenSet.sol) structures. Token represents for fungibles a quantity of tokens while for non-fungibles it represents a single element. TokenSet represents for non-fungible tokens a set of unique elements. The token id is of type bytes32 instead of uint256 to support more powerful NFTs.

 ```solidity
struct Token
{
    bytes32 Standard;
    address Contract;
    bytes32 Id;
    uint256 Amount;  
}

struct TokenSet
{
    bytes32 Standard;
    address Contract;
    bytes32[] Ids;
    uint256[] Amounts;  
}
```
Example of use:

 ```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "https://github.com/DanielAbalde/TokenClient/blob/master/contracts/TokenClient.sol";

contract ExampleOfUse
{
    struct Item
    {
        Token Token;
        uint256 Price;
        address Owner;
    }

    TokenClient private _client;
    mapping(uint256=>Item) private _items;
    uint256 private _itemCount;

    constructor(address tokenClient) {
        _client = TokenClient(tokenClient);
    }

    function sell(Token calldata token, uint256 price) external returns(uint256 id) {
        require(_client.isOwner(token, msg.sender), "Not the owner");
        require(_client.isApproved(token, msg.sender, address(_client)), "Not approved");
        require(price > 0, "Price is zero"); 
        id = ++_itemCount;
        _items[id] = Item(token, price, msg.sender);
    }

    function buy(uint256 id) external payable {
        Item memory item = _items[id];
        require(item.Owner != address(0), "id not found");
        require(msg.value >= item.Price, "Not enough value");
        payable(item.Owner).transfer(msg.value);
        _client.transfer(item.Token, item.Owner, msg.sender);
    } 
}
```