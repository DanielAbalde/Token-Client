// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./../TokenAbstraction.sol"; 
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol"; 

contract TokenERC1155 is TokenAbstraction
{
    function standard() public pure virtual override returns(bytes32){ return "ERC1155"; }

    function _isStandard(address contractAddress) internal view override virtual returns(bool){ 
        try IERC165(contractAddress).supportsInterface(type(IERC1155).interfaceId) returns (bool result){
            return result;
        }catch{
            return false;
        }
    } 
    function _isOwner(Token memory token, address account) internal view override virtual returns (bool){
        return IERC1155(token.Contract).balanceOf(account, uint256(token.Id)) >= token.Amount;
    } 
    function _isApproved(Token memory token, address account, address operator) internal view override virtual returns (bool) {
        return IERC1155(token.Contract).isApprovedForAll(account, operator);
    }
    function _isApprovedSet(TokenSet memory tokenSet, address account, address operator) internal view override virtual returns (bool){
        return IERC1155(tokenSet.Contract).isApprovedForAll(account, operator);
    }
    function _transfer(Token memory token, address from, address to) internal override virtual returns (bool){    
        IERC1155(token.Contract).safeTransferFrom(from, to, uint256(token.Id), token.Amount, "");  
        return true;
    }
    function _transferSet(TokenSet memory tokenSet, address from, address to) internal override virtual returns (bool){
        uint256[] memory tokenIds = new uint256[](tokenSet.Ids.length);
        for(uint256 i=0; i<tokenSet.Ids.length; i++){
            tokenIds[i] = uint256(tokenSet.Ids[i]);
        }
        IERC1155(tokenSet.Contract).safeBatchTransferFrom(from, to, tokenIds, tokenSet.Amounts, "");  
        return true;
    }
}