// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/contracts/FundMe.sol";

contract FundMeTest is Test {
    uint256 number = 1;

    FundMe fundMe;

    function setUp() external {
        fundMe = new FundMe(address(0));
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }
}
