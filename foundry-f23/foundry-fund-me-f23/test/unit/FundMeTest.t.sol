// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundme;
    address User = makeAddr("user");
    uint256 constant SendValue = 0.1 ether;
    uint256 constant Starting_Balance = 10 ether;
    uint256 constant GasPrice = 1;

    function setUp() external {
        // here ownership us-> Fundmetest -> Fundme
        DeployFundMe deployFundMe = new DeployFundMe();
        fundme = deployFundMe.run();
        vm.deal(User, Starting_Balance);
    }

    function testminimumdollarisfive() public {
        assertEq(fundme.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundme.getOwner(), msg.sender);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); //this meant the next line, should revert
        //assert(this txn fails/revert)
        fundme.fund(); //sends 0 value but we have sent the min ETH  as 5 dollars so this should fails hence the test is also passing.
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(User); //The next txn will be sent by User
        fundme.fund{value: SendValue}();

        uint256 amountFunded = fundme.getAddresstoAmountFunded(User);
        assertEq(amountFunded, SendValue);
    }

    function testAddFundersToArrayOfFunders() public funded {
        address funders = fundme.getFunders(0);
        assertEq(funders, User);
    }

    modifier funded() {
        vm.prank(User);
        fundme.fund{value: SendValue}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(User);
        vm.expectRevert();
        fundme.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        //Arrange
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;

        //Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GasPrice); //in anvil gas price is default to 0 i.e we have set it using forge command
        vm.prank(fundme.getOwner());
        fundme.withdraw();

        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; //tx.gasprice tells current gasprice
        console.log(gasUsed);

        //Assert
        uint256 endingOwnerBalance = fundme.getOwner().balance;
        uint256 endingFundMeBalance = address(fundme).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        uint160 noOfFunders = 10;
        uint160 startingIndex = 1;

        for (uint160 i = startingIndex; i < noOfFunders; i++) {
            //vm.prank makes new address
            //vm.deals assign some eth to new address
            hoax(address(i), SendValue); //done both work together also for address uint160
            fundme.fund{value: SendValue}();
        }

        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;

        //Act
        vm.startPrank(fundme.getOwner());
        fundme.withdraw();
        vm.stopPrank();

        //assert
        assert(address(fundme).balance == 0);
        assert(
            startingOwnerBalance + startingFundMeBalance ==
                fundme.getOwner().balance
        );
    }
}
