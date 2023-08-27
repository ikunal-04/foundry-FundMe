// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import "../../script/Interactions.s.sol";

contract FundMeInteractionTest is Test {
    FundMe fundme;
    address User = makeAddr("user");
    uint256 constant SendValue = 0.1 ether;
    uint256 constant Starting_Balance = 10 ether;
    uint256 constant GasPrice = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundme = deployFundMe.run();
        vm.deal(User, Starting_Balance);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundfundMe = new FundFundMe();
        fundfundMe.fundFundMe(address(fundme));

        WithDrawFundMe withdrawfundme = new WithDrawFundMe();
        withdrawfundme.withdrawFundMe(address(fundme));

        assert(address(fundme).balance == 0);
    }
}
