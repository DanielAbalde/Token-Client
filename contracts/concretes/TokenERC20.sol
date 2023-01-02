// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./../TokenAbstraction.sol"; 
import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; 

contract TokenERC20 is TokenAbstraction
{
    function standard() public pure virtual override returns(bytes32){ return "ERC20"; }

    function _isStandard(address contractAddress) internal view override virtual returns(bool){
        try IERC165(contractAddress).supportsInterface(type(IERC20).interfaceId) returns (bool result){
            return result;
        }catch{}
            bool success;
            bytes memory data;
            (success, data) = contractAddress.staticcall(abi.encodeWithSignature("totalSupply()"));
            if(!success) {
            return false;
        }
        (success, data) = contractAddress.staticcall(abi.encodeWithSignature("balanceOf(address)", msg.sender));
        // keep checking?
        if(!success) {
            return false;
        }
        return true;
    }
    function _isOwner(Token memory token, address account) internal view override virtual returns (bool){
        try IERC20(token.Contract).balanceOf(account) returns (uint256 balance){
            return balance >= token.Amount;
        }catch{
            return false;
        }
    }
    function _isApproved(Token memory token, address account, address operator) internal view override virtual returns (bool) {
        try IERC20(token.Contract).allowance(account, operator) returns (uint256 balance){
            return balance >= token.Amount;
        }catch{
            return false;
        }
    }
    function _transfer(Token memory token, address from, address to) internal override virtual returns (bool){  
        return IERC20(token.Contract).transferFrom(from, to, token.Amount);
    }
}