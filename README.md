<h1 align="center">Token Client</h1> 
<p align="center">Generalizes operations with fungible and non-fungible tokens</p>
 
[TokenClient.sol](contracts/TokenClient.sol) is a smart contract that facilitates support for fungible and non-fungible token operations. It contains a set of [TokenAbstraction](contracts/TokenAbstraction.sol) with read and transfer functions, and its implementations such as [TokenERC20](contracts/concretes/TokenERC20.sol), [TokenERC721](contracts/concretes/TokenERC721.sol) or [TokenERC1155](contracts/concretes/TokenERC1155.sol) are responsible for calling the functions of each standard. For the developer, TokenClient allows to generalize the functionality with the template pattern and support new types of tokens with the proxy pattern.
 

<p align="center"><img src="./assets/TokenClientDiagram.PNG" alt="TokenClientDiagram"></p>

The functionality uses the [Token](contracts/Token.sol) and [TokenSet](contracts/TokenSet.sol) structures. Token represents for fungibles a quantity of tokens while for non-fungibles it represents a single element. TokenSet represents for non-fungible tokens a set of unique elements. The token id is of type bytes32 instead of uint256 to support more powerful NFTs.

 ```cs
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
 
