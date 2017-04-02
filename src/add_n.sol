pragma solidity ^0.4.0;
contract addN { 
    uint32 n ; 
    
    function addN(uint32 _n) 
    { 
    	n = _n ; 
    } 
    function add(uint32 operand) external returns(uint32) { 
    	return operand + n ; 
    } 
}