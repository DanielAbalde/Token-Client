// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./../TokenAbstraction.sol"; 
import "@lukso/lsp-smart-contracts/contracts/LSP7DigitalAsset/ILSP7DigitalAsset.sol";

contract TokenLSP7 is TokenAbstraction
{
    function standard() public pure virtual override returns(bytes32){ return "LSP7DigitalAsset"; }

    function _isStandard(address contractAddress) internal view override virtual returns(bool){
        try IERC165(contractAddress).supportsInterface(type(ILSP7DigitalAsset).interfaceId) returns (bool result){
            return result;
        }catch{
            return false;
        }
    }
    function _isOwner(Token memory token, address account) internal view override virtual returns (bool){
        return ILSP7DigitalAsset(token.Contract).balanceOf(account) >= token.Amount;
    } 

    function _isApproved(Token memory token, address account, address operator) internal view override virtual returns (bool) {
        return ILSP7DigitalAsset(token.Contract).authorizedAmountFor(operator, account) >= token.Amount;
    }
    function _transfer(Token memory token, address from, address to) internal override virtual returns (bool){    
        ILSP7DigitalAsset(token.Contract).transfer(from, to, token.Amount, true, "");
        return true;
    }
}