pragma solidity ^0.4.0;

contract Token {
    int64 total_tokens ;
    address owner ;
    mapping (address => int64) holdings ;
    
    function Token(int64 total_circulation) {
        total_tokens = total_circulation ;
        owner = msg.sender ;
    }
    
    event TokenAllocation(address h, int64 v) ;
    event TokenMovement(address from, address to, int64 v) ;
    event InvalidTokenUsage(string reason) ;


    function allocate(address newHolder, int64 value) external {
        if (msg.sender != owner) return ;
        if (value < 0) {
            InvalidTokenUsage('Cannot allocate negative value') ;
            return ;
        }

        if (value <= total_tokens) {
            holdings[newHolder] += value ;
            total_tokens -= value ;
            TokenAllocation(newHolder, value) ;
        }
        InvalidTokenUsage('value to allocate larger than outstanding tokens') ;
    }
    
    function move(address destination, int64 value) external {
        address source = msg.sender ;
        if (value <= 0) {
            InvalidTokenUsage('Must move value greater than zero') ;
            return ;
        }
        if (holdings[source] >= value) {
            holdings[destination] += value ;
            holdings[source] -= value ;
            TokenMovement(source, destination, value) ;
        }
        InvalidTokenUsage('value to move larger than holdings') ;
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

