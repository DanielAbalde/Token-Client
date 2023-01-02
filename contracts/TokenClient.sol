// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
 
import "./TokenAbstraction.sol"; 
import "@openzeppelin/contracts/access/Ownable.sol";

/*
    @title Token Client
    @author Daniel Gonzalez Abalde aka DaniGA
    @notice 
*/
contract TokenClient is Ownable
{
    bytes32[] internal _standards;
    mapping(bytes32=>address) internal _abstractions;
    address[] internal _allowedCallers;
    mapping(address=>bool) internal _callerAllowed;
   
    event StandardSupported(bytes32 indexed standard);
    event StandardReplaced(bytes32 indexed standard, address indexed previous);
    event StandardUnsupported(bytes32 indexed standard);
    event TokenTransfered(Token indexed token, address indexed from, address indexed to);
    event TokenSetTransfered(TokenSet indexed tokenSet, address indexed from, address indexed to);

    // ################################## MODIFIERS ##################################

    modifier standardSupported(bytes32 standard){
        require(_supportsStandard(standard), "TokenClient: standard not supported");
        _;
    }
    modifier onlyAllowed(){ 
        if(!_isAllowedCaller(msg.sender)){
            revert("TokenClient: caller not allowed");
        } 
        _;
    }
    modifier validToken(Token calldata token){
        require(token.Standard != bytes32(0), "TokenClient: token with empty standard");
        require(token.Contract != address(0), "TokenClient: token with empty address");
        require(token.Amount > 0, "TokenClient: token with zero amount");
        _;
    }

    // ################################## EXTERNAL ##################################
    
    
    function getAbstraction(bytes32 standard) onlyAllowed() external view returns(address){ return _abstractions[standard]; }
    /*

        @return 
    */
    function supportedStandards() onlyAllowed() external view returns(bytes32[] memory){ return _standards; }
    
    function supportsStandard(bytes32 standard) onlyAllowed() external view returns(bool){ return _supportsStandard(standard); }
    
    function isStandard(bytes32 standard, address contractAddress) onlyAllowed() standardSupported(standard) external view returns(bool) { 
        return TokenAbstraction(_abstractions[standard]).isStandard(contractAddress);
    } 
    function isOwner(Token calldata token, address account) onlyAllowed() standardSupported(token.Standard) external view returns (bool) { 
        return TokenAbstraction(_abstractions[token.Standard]).isOwner(token, account);
    }
    function isOwnerSet(TokenSet calldata tokenSet, address account) onlyAllowed() standardSupported(tokenSet.Standard) external view returns (bool) { 
        return TokenAbstraction(_abstractions[tokenSet.Standard]).isOwnerSet(tokenSet, account);
    }
    function isApproved(Token calldata token, address account, address operator) onlyAllowed() standardSupported(token.Standard) external view virtual returns (bool){
        return TokenAbstraction(_abstractions[token.Standard]).isApproved(token, account, operator);
    }
    function isApprovedSet(TokenSet calldata tokenSet, address account, address operator) onlyAllowed() standardSupported(tokenSet.Standard) external view virtual returns (bool){
        return TokenAbstraction(_abstractions[tokenSet.Standard]).isApprovedSet(tokenSet, account, operator);
    }
    function transfer(Token calldata token, address from, address to) onlyAllowed() standardSupported(token.Standard) external virtual returns (bool success){  
        bytes memory resultData = _delegatecall(token.Standard, abi.encodeWithSelector(bytes4(0x8c5b2f8e), token, from, to)); 
        success = abi.decode(resultData, (bool));
        if(success){
            emit TokenTransfered(token, from, to);
        } 
    } 
    function transferSet(TokenSet calldata tokenSet, address from, address to) onlyAllowed() standardSupported(tokenSet.Standard) external virtual returns (bool success){  
        bytes memory resultData = _delegatecall(tokenSet.Standard, abi.encodeWithSelector(bytes4(0xd4144fc8), tokenSet, from, to)); 
        success = abi.decode(resultData, (bool));
        if(success){
            emit TokenSetTransfered(tokenSet, from, to);
        }
    }

    // ################################## ONLY OWNER ##################################
    
    function support(address tokenAbstraction) onlyOwner() external {
        require(tokenAbstraction != address(0), "TokenClient: zero address");
        TokenAbstraction ta = TokenAbstraction(tokenAbstraction);
        bytes32 standard = ta.standard();
        require(standard != bytes32(0), "TokenClient: empty standard"); 
        if(_supportsStandard(standard)){
            address previous = address(_abstractions[standard]);
            require(previous != tokenAbstraction, "TokenClient: tokenAbstraction already supported");
            _abstractions[standard] = tokenAbstraction;
            emit StandardReplaced(standard, previous);
        }else{
            _standards.push(standard);
            _abstractions[standard] = tokenAbstraction;
            emit StandardSupported(standard);
        } 
    }
    function unsupport(bytes32 standard) standardSupported(standard) external { 
        for(uint256 i=0; i<_standards.length; i++){
            if(_standards[i] == standard){
            if(_standards.length > 1){
                _standards[i] = _standards[_standards.length-1];
            } 
            _standards.pop(); 
            break;
            }
        }
        delete _abstractions[standard];
        emit StandardUnsupported(standard);
    }

    function allowCaller(address to, bool approve) onlyOwner() external {
        if(approve){
            if(!_callerAllowed[to]){
                _callerAllowed[to] = true;
                _allowedCallers.push(to);
            }
        }else{
            if(_callerAllowed[to]){ 
                for(uint256 i=0; i<_allowedCallers.length; i++){
                    if(_allowedCallers[i] == to){
                        if(_allowedCallers.length > 1){
                            _allowedCallers[i] = _allowedCallers[_allowedCallers.length-1];
                        } 
                        _allowedCallers.pop();
                        break;
                    }
                }
                delete _callerAllowed[to];
            }
        }
    }

    function getAllowedCallers() onlyOwner() external view returns(address[] memory){ return _allowedCallers; }

    // ################################## INTERNAL ##################################
    
    function _isAllowedCaller(address account) internal view virtual returns(bool){
        if(account == owner()){
            return true;
        }else if(_allowedCallers.length > 0){
            return _callerAllowed[account];
        }else{
            return true;
        }
    }
    function _supportsStandard(bytes32 standard) internal view virtual returns(bool){
        return _abstractions[standard] != address(0);
    }
    
    function _delegatecall(bytes32 standard, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = _abstractions[standard].delegatecall(data);
        if (!success) {
            if (returndata.length == 0) revert();
            assembly {
                revert(add(32, returndata), mload(returndata))
            }
        }
        return returndata;
    }
}