// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/contracts/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address FUNDER = makeAddr("funder");
    address OWNER;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant FUND_AMOUNT = 0.1 ether;
    // uint256 constant gasPrice = 1e9;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(FUNDER, STARTING_BALANCE);
        OWNER = fundMe.getOwner();
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(OWNER, msg.sender);
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
        assertEq(fundMe.getAddressToAmountFunded(FUNDER), FUND_AMOUNT);
    }

    function testFundUpdatesFundedDataStructure() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(FUNDER);
        assertEq(amountFunded, FUND_AMOUNT);
    }

    function testAddsFunderToArray() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, FUNDER);
    }

    function testWithdrawFailsNotOwner() public funded {
        vm.prank(FUNDER);
        vm.expectRevert(); // hey, the next line should revert
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange
        uint256 ownerBalanceBefore = OWNER.balance;
        uint256 fundMeBalanceBefore = address(fundMe).balance;

        // Act
        vm.prank(OWNER);
        fundMe.withdraw();

        // Assert
        uint256 ownerBalanceAfter = OWNER.balance;
        uint256 fundMeBalanceAfter = address(fundMe).balance;
        assertEq(fundMeBalanceAfter, 0);
        assertEq(ownerBalanceAfter, ownerBalanceBefore + fundMeBalanceBefore);
    }

    function testWithdrawWithMultipleFunders() public {
        // Arrange
        uint160 numberOfFunders = 10;
        for (uint160 i = 0; i < numberOfFunders; i++) {
            // vm.prank
            // vm.deal
            hoax(address(i), FUND_AMOUNT); // <-- this is a forge method.

            // fundMe.fund;
            fundMe.fund{value: FUND_AMOUNT}();
        }

        uint256 ownerBalanceBefore = OWNER.balance;
        uint256 fundMeBalanceBefore = address(fundMe).balance;

        // Act
        vm.startPrank(OWNER);
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        uint256 ownerBalanceAfter = OWNER.balance;
        uint256 fundMeBalanceAfter = address(fundMe).balance;

        assertEq(fundMeBalanceAfter, 0);
        assertEq(ownerBalanceAfter, ownerBalanceBefore + fundMeBalanceBefore);
    }

    modifier funded() {
        vm.prank(FUNDER);
        fundMe.fund{value: FUND_AMOUNT}();
        _;
    }
}
