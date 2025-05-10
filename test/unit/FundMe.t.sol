// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    uint8 priceFeedVersion;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 2;

    function getVersion() public view returns (uint8) {
        if (block.chainid == 1) {
            return 6;
        } else if (block.chainid == 11155111) {
            return 4;
        } else {
            return 0;
        }
    }

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        priceFeedVersion = getVersion();
        vm.deal(USER, STARTING_BALANCE);
    }
    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsCorrect() public view {
        assertEq(fundMe.getVersion(), priceFeedVersion);
    }

    function testFundFailsWithoutEnoughtEth() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testAddsFunderToArrayOfFunders() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOwnerCanWithdraw() public funded {
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        assertEq(address(fundMe).balance, 0);
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingContractBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = address(fundMe.getOwner()).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        assertEq(address(fundMe).balance, 0);
        assertEq(
            address(fundMe.getOwner()).balance,
            startingOwnerBalance + startingContractBalance
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(uint160(i)), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = address(fundMe.getOwner()).balance;
        uint256 startingContractBalance = address(fundMe).balance;

        // Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();
        uint256 gasEnd = gasleft();
        console.log("gas used: ", gasStart - gasEnd);
        console.log("gas cost: ", (gasStart - gasEnd) * GAS_PRICE);

        // Assert
        assertEq(address(fundMe).balance, 0);
        assertEq(
            address(fundMe.getOwner()).balance,
            startingOwnerBalance + startingContractBalance
        );
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }
}

// Types of tests
// 1. Unit tests
// 2. Integration tests
// 3. Forking tests
// 4. Staging tests
// 5. Gas tests
