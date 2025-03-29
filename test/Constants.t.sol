// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {Constants} from "../src/lib/Constants.sol";

contract ConstantsTest is Test {
    function setUp() public {}

    function testConstants() public {
        assertEq(Constants.WAD, 1e18);
        assertEq(Constants.BPS, 1e4);
        assertEq(
            uint256(Constants.MAX_PENALTY_RATE),
            1e17 / 86400,
            "Penalty rate mismatch"
        );
        assertEq(Constants.EIGEN_SHARE, 30);
        assertEq(Constants.PROTOCOL_SHARE, 20);
        assertEq(Constants.LP_SHARE, 50);
        assertEq(Constants.LIQUIDATOR_REWARD, 80);
        assertEq(Constants.AUTO_DELEVERAGE_THRESHOLD, 110);
        assertEq(Constants.AUTO_DELEVERAGE_REDUCTION, 25);
    }
}
