// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/DevOpsTools.sol";
import {FundMe} from "../src/contracts/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant FUND_VALUE = 0.01 ether;

    function fundFundMe(address mostRecentDeployedFundMe) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployedFundMe)).fund{value: FUND_VALUE}();
        vm.stopBroadcast();

        console.log("Funded FundMe contract with %s", FUND_VALUE);
    }
    function run() external {
        address mostRecentDeployedFundMe = DevOpsTools
            .get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        fundFundMe(mostRecentDeployedFundMe);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentDeployedFundMe) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployedFundMe)).withdraw();
        vm.stopBroadcast();
    }
    function run() external {
        address mostRecentDeployedFundMe = DevOpsTools
            .get_most_recent_deployment("FundMe", block.chainid);

        withdrawFundMe(mostRecentDeployedFundMe);
    }
}
