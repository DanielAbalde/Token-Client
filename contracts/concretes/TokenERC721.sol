// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./../TokenAbstraction.sol"; 
import "@openzeppelin/contracts/token/ERC721/IERC721.sol"; 

contract TokenERC721 is TokenAbstraction
{
    function standard() public pure virtual override returns(bytes32){ return "ERC721"; }


    function owner(Token calldata token) external view virtual returns (address){ return _owner(token); }
    function _owner(Token memory token) internal view virtual returns (address){
        try IERC721(token.Contract).ownerOf(uint256(token.Id)) returns (address owner_){
            return owner_;
        }catch{
            return address(0);
        }
    } 

    function _isStandard(address contractAddress) internal view override virtual returns(bool){
        try IERC165(contractAddress).supportsInterface(type(IERC721).interfaceId) returns (bool result){
            return result;
        }catch{
            return false;
        }
    }
    function _isOwner(Token memory token, address account) internal view override virtual returns (bool){
        return _owner(token) == account;
    } 
    function _isApproved(Token memory token, address /*account*/, address operator) internal view override virtual returns (bool) {
        return IERC721(token.Contract).getApproved(uint256(token.Id)) == operator;
    }
    function _transfer(Token memory token, address from, address to) internal override virtual returns (bool){    
        IERC721(token.Contract).safeTransferFrom(from, to, uint256(token.Id));
        return true;
    }
}