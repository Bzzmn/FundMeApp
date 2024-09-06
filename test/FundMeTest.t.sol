// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/contracts/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant FUND_AMOUNT = 0.1 ether;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    // What can we do to work with addresses outside of our system?
    // 1. Unit
    //  - Testing a specific part of our code.
    // 2. Integration
    //  - Testing how our contract interacts with other contracts.
    // 3. Forked
    //  - Testing how our contract interacts on a simulated network.
    // 4. Staging
    //  - Testing how our contract interacts on a real network not production.

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsNoEnoughEth() public {
        vm.expectRevert(); // hey, the next line should revert
        fundMe.fund{value: 1e15}();
    }

    function testFundSuccess() public funded {
        assertEq(fundMe.getAddressToAmountFunded(USER), FUND_AMOUNT);
    }

    function testFundUpdatesFundedDataStructure() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, FUND_AMOUNT);
    }

    function testAddsFunderToArray() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testWithdrawFailsNotOwner() public funded {
        vm.prank(USER);
        vm.expectRevert(); // hey, the next line should revert
        fundMe.withdraw();
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: FUND_AMOUNT}();
        _;
    }
}
