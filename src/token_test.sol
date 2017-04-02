pragma solidity ^0.4.0;
import 'dapple/test.sol'; // virtual "dapple" package imported when `dapple test` is run
import 'token.sol';

contract TokenTester is Tester {
    function move(address destination, int64 value) external {
        return Token(_t).move(destination, value) ;
    }
    
    function myBalance() external returns(int64) {
        return Token(_t).myBalance() ;
    }
}

contract TokenTest is Test {
    Token t ;
    TokenTester user1;
    TokenTester user2;

    function setUp() {
        t = new Token(1000);
        user1 = new TokenTester();
        user1._target(t);
        user2 = new TokenTester();
        user2._target(t);
    }

    function testInitialOutstandingValueIsCorrect() {
        assertEq(t.outstandingValue(), 1000) ;
    }

    function testAllocateMovesValue() {
        assertEq(t.outstandingValue(), 1000) ;
        t.allocate(user1, 300) ;
        assertEq(t.outstandingValue(), 700, "wrong outstanding value") ;
        assertEq(t.holderBalance(user1), 300, "wrong holder balance") ;
    }

    function testMoveTransfersValue() {
        assertEq(t.outstandingValue(), 1000) ;
        t.allocate(user1, 300) ;
        user1.move(user2, 250) ;

        assertEq(t.outstandingValue(), 700, "wrong outstanding value") ;
        assertEq(t.holderBalance(user1), 50, "wrong holder balance") ;
        assertEq(t.holderBalance(user2), 250, "wrong recipient balance") ;
    }

    function testMyBalance() {
        t.allocate(user1, 500) ;
        user1.move(user2, 200) ;
        assertEq(user1.myBalance(), 300, "wrong balance for user1") ;
        assertEq(user2.myBalance(), 200, "wrong balance for user2") ;
    }

    function testNegativeAllocateIsNullOperation() {
        t.allocate(user1, 300) ;
        t.allocate(user2, -100) ;

        assertEq(t.outstandingValue(), 700, "unexpected outstanding value") ;
        assertEq(user1.myBalance(), 300, "user1 has unexpected balance") ;
        assertEq(user2.myBalance(), 0, "user2 has unexpected balance") ;
    }

    function testMoveNegativeValueIsNullOperation() {
        t.allocate(user1, 500) ;
        t.allocate(user2, 200) ;
        user1.move(user2, -100) ;

        assertEq(user1.myBalance(), 500, "unexpected balance for user1") ;
        assertEq(user2.myBalance(), 200, "unexpected balance for user2") ;
    }

    function testThatOverAllocateFails() {
        t.allocate(user1, 900) ;
        t.allocate(user2, 200) ;

        assertEq(user1.myBalance(), 900, "unexpected balance for user1") ;
        assertEq(user2.myBalance(), 0, "unexpected balance for user2") ;
        assertEq(t.outstandingValue(), 100, "unexpected outstanding value") ;
    }

    function testThatInvalidMoveFails() {
        t.allocate(user1, 100) ;
        user1.move(user2, 50) ;
        user1.move(user2, 51) ;
        assertEq(user1.myBalance(), 50, "unexpected balance for user1") ;
        assertEq(user2.myBalance(), 50, "unexpected balance for user2") ;
    }

    function testThatAccountCanMoveAllItsTokens() {
        t.allocate(user1, 100) ;
        user1.move(user2, 100) ;
        assertEq(user1.myBalance(), 0, "unexpected balance for user1") ;
        assertEq(user2.myBalance(), 100, "unexpected balance for user2") ;
     }

}
