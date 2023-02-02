// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./../TokenAbstraction.sol";  
import "hardhat/console.sol";

contract TokenETH is TokenAbstraction
{
    function standard() public pure virtual override returns(bytes32){ return "ETH"; }

    function _isStandard(address contractAddress) internal view override virtual returns(bool){
        return contractAddress == address(0);
    }

    function _isOwner(Token memory token, address account) internal view override virtual returns (bool){
        if(token.Contract != address(0)){
            return false;
        }
        return account.balance >= token.Amount;
    }
    function _balanceOf(Token memory /*token*/, address account) internal view override virtual returns (uint256){
        return account.balance;
    }
    function _isApproved(Token memory /*token*/, address account, address operator) internal view override virtual returns (bool) {
        return account == operator;
    }
    function _transfer(Token memory token, address from, address to) internal override virtual returns (bool){
        require(msg.value == token.Amount, "TokenETH: value is not token amount");
        require(from == msg.sender, "TokenETH: not from sender");
        (bool success, ) = to.call{value:token.Amount}("");
        return success;
    }
}