pragma solidity ^0.4.0;

contract Token {
    int64 total_tokens ;
    address owner ;
    mapping (address => int64) holdings ;
    
    function Token(int64 total_circulation) {
        total_tokens = total_circulation ;
        owner = msg.sender ;
    }
    
    function allocate(address newHolder, int64 value) external {
        if (msg.sender != owner) return ;
        if (value < 0) return ;
        
        if (value <= total_tokens) {
            holdings[newHolder] += value ;
            total_tokens -= value ;
        }
    }
    
    function move(address destination, int64 value) external {
        address source = msg.sender ;
        if (value <= 0) return ;
        if (holdings[source] >= value) {
            holdings[destination] += value ;
            holdings[source] -= value ;
        }
    }
    
    function myBalance() external returns(int64) {
        return holdings[msg.sender] ;
    }
    
    function holderBalance(address holder) external returns(int64) {
        if (msg.sender != owner) return ;
        return holdings[holder] ;
    }
    
    function outstandingValue() external returns(int64) {
        if (msg.sender != owner) return ;
        return total_tokens ;
    }
    
}

