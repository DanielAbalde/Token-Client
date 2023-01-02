// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./../TokenClient.sol";

/*
    Simple buy/sell mechanism but potentially supports any standard

    This is how to suport ERC20, ERC721 and ERC1155:

    const tokenClient = await deploy("TokenClient");

    const tokenERC20 = await deploy("TokenERC20");
    const tokenERC721 = await deploy("TokenERC721");
    const tokenERC1155 = await deploy("TokenERC1155");
    
    await tokenClient.support(tokenERC20.address);
    await tokenClient.support(tokenERC721.address);
    await tokenClient.support(tokenERC1155.address); 
*/
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