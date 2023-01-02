// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./../TokenAbstraction.sol"; 
import "@openzeppelin/contracts/token/ERC777/IERC777.sol"; 

contract TokenERC777 is TokenAbstraction
{
    function standard() public pure virtual override returns(bytes32){ return "ERC777"; }

    function _isStandard(address contractAddress) internal view override virtual returns(bool){
        try IERC165(contractAddress).supportsInterface(type(IERC777).interfaceId) returns (bool result){
            return result;
        }catch{
            return false;
        }
    }
    function _isOwner(Token memory token, address account) internal view override virtual returns (bool){
        return IERC777(token.Contract).balanceOf(account) >= token.Amount;
    } 

    function _isApproved(Token memory token, address account, address operator) internal view override virtual returns (bool) {
        return IERC777(token.Contract).isOperatorFor(operator, account);
    }
    function _transfer(Token memory token, address from, address to) internal override virtual returns (bool){    
        IERC777(token.Contract).operatorSend(from, to, token.Amount, "", "");
        return true;
    }
}