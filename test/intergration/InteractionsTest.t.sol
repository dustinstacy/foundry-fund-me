// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;
    HelperConfig public helperConfig;

    address user = makeAddr("user");
    uint256 constant VALID_FUNDING_AMOUNT = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 0.0000001 ether;

    function setUp() external {
        DeployFundMe deployment = new DeployFundMe();
        (fundMe, helperConfig) = deployment.deployFundMe();
        vm.deal(user, STARTING_BALANCE);
    }

    function testUserCanFundAndOwnerCanWithdraw() public {
        uint256 previousUserBalance = address(user).balance;
        uint256 previousOwnerBalance = address(fundMe.getOwner()).balance;

        vm.prank(user);
        fundMe.fund{value: VALID_FUNDING_AMOUNT}();

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        uint256 endingUserBalance = address(user).balance;
        uint256 endingOwnerBalance = address(fundMe.getOwner()).balance;

        assert(address(fundMe).balance == 0);
        assertEq(endingUserBalance + VALID_FUNDING_AMOUNT, previousUserBalance);
        assertEq(
            previousOwnerBalance + VALID_FUNDING_AMOUNT,
            endingOwnerBalance
        );
    }
}
