// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Token.sol";
import "./TokenSet.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol"; 
 
/*
struct Token
{
    bytes32 Standard;
    address Operator;
    address Contract;
    bool IsFungible; 
    bytes32[] Ids;
    uint256[] Amounts;
}

    ERC20 = new Token(type(IERC20).interfaceId, msg.sender, contractAddress, false, [], [amount]);
    ERC721 = new Token(type(IERC721).interfaceId, msg.sender, contractAddress, true, [id], [1]);
    ERC1155 = new Token(type(IERC1155).interfaceId, msg.sender, contractAddress, true, [id], [amount]);
*/

abstract contract TokenAbstraction is ERC165
{
    modifier onlyStandard(Token calldata token){
        require(token.Standard == standard(), "TokenAbstraction: not this standard");
        _;
    }
    modifier onlyStandardSet(TokenSet calldata tokenSet){
        require(tokenSet.Standard == standard(), "TokenAbstraction: not this standard");
        _;
    }

    function standard() public pure virtual returns(bytes32);

    function isStandard(address contractAddress) external view returns(bool) { return _isStandard(contractAddress); } 

    function isOwner(Token calldata token, address account) onlyStandard(token) external view returns (bool) { return _isOwner(token, account); }
    function balanceOf(Token calldata token, address account) onlyStandard(token) external view returns (uint256){ return _balanceOf(token, account); }
    function isApproved(Token calldata token, address account, address operator) onlyStandard(token) external view returns (bool){ return _isApproved(token, account, operator); } 
    function transfer(Token calldata token, address from, address to) onlyStandard(token) external returns (bool){ return _transfer(token, from, to); }
    
    function isOwnerSet(TokenSet calldata tokenSet, address account) onlyStandardSet(tokenSet) external view returns (bool) { return _isOwnerSet(tokenSet, account); }
    function balanceOfSet(TokenSet calldata tokenSet, address account) onlyStandardSet(tokenSet) external view returns (uint256[] memory){ return _balanceOfSet(tokenSet, account); }
    function isApprovedSet(TokenSet calldata tokenSet, address account, address operator) onlyStandardSet(tokenSet) external view returns (bool){ return _isApprovedSet(tokenSet, account, operator); }
    function transferSet(TokenSet calldata tokenSet, address from, address to) onlyStandardSet(tokenSet) external returns (bool){ return _transferSet(tokenSet, from, to); }

    function _isStandard(address contractAddress) internal view virtual returns(bool);
    function _isOwner(Token memory token, address account) internal view virtual returns (bool);
    function _balanceOf(Token memory token, address account) internal view virtual returns (uint256);
    function _isApproved(Token memory token, address account, address operator) internal view virtual returns (bool);
    function _transfer(Token memory token, address from, address to) internal virtual returns (bool); 

    function _isOwnerSet(TokenSet memory tokenSet, address account) internal view virtual returns (bool){
        for(uint256 i=0; i<tokenSet.Ids.length; i++){
            if(!_isOwner(_getToken(tokenSet, i), account))
            {
                return false;
            }
        }
        return true;
    }
    function _balanceOfSet(TokenSet memory tokenSet, address account) internal view virtual returns (uint256[] memory balances){
        balances = new uint256[](tokenSet.Ids.length);
        for(uint256 i=0; i<tokenSet.Ids.length; i++){
            balances[i] = _balanceOf(_getToken(tokenSet, i), account);
        }
    }
    function _isApprovedSet(TokenSet memory tokenSet, address account, address operator) internal view virtual returns (bool){
        for(uint256 i=0; i<tokenSet.Ids.length; i++){
            if(!_isApproved(_getToken(tokenSet, i), account, operator))
            {
                return false;
            }
        }
        return true;
    } 
    function _transferSet(TokenSet memory tokenSet, address from, address to) internal virtual returns (bool){
        for(uint256 i=0; i<tokenSet.Ids.length; i++){
            if(!_transfer(_getToken(tokenSet, i), from, to))
            {
                return false;
            }
        }
        return true;
    }

    function _getToken(TokenSet memory tokenSet, uint256 index) internal pure returns(Token memory){
        return Token(tokenSet.Standard, tokenSet.Contract, tokenSet.Ids[index], tokenSet.Amounts[index]);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(TokenAbstraction).interfaceId || super.supportsInterface(interfaceId);
    }

}