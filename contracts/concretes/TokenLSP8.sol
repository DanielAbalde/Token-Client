// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./../TokenAbstraction.sol"; 
import "@lukso/lsp-smart-contracts/contracts/LSP8IdentifiableDigitalAsset/ILSP8IdentifiableDigitalAsset.sol";

contract TokenLSP8 is TokenAbstraction
{
    function standard() public pure virtual override returns(bytes32){ return "LSP8IdentifiableDigitalAsset"; }

    function _isStandard(address contractAddress) internal view override virtual returns(bool){
        try IERC165(contractAddress).supportsInterface(type(ILSP8IdentifiableDigitalAsset).interfaceId) returns (bool result){
            return result;
        }catch{
            return false;
        }
    }
    function _isOwner(Token memory token, address account) internal view override virtual returns (bool){
        try ILSP8IdentifiableDigitalAsset(token.Contract).tokenOwnerOf(token.Id) returns (address owner){
            return owner == account;
        }catch{
            return false;
        } 
    } 
    function _isApproved(Token memory token, address /*account*/, address operator) internal view override virtual returns (bool) {
        return ILSP8IdentifiableDigitalAsset(token.Contract).isOperatorFor(operator, token.Id);
    }
    function _transfer(Token memory token, address from, address to) internal override virtual returns (bool){    
        ILSP8IdentifiableDigitalAsset(token.Contract).transfer(from, to, token.Id, true, "");
        return true;
    }
}