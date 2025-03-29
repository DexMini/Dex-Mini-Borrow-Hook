// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {EventsAndStructs} from "../src/lib/EventsAndStructs.sol";

contract EventsAndStructsTest is Test {
    function setUp() public {}

    function testPositionStruct() public {
        EventsAndStructs.Position memory pos = EventsAndStructs.Position({
            collateral: 1000,
            borrowedPrincipal: 500,
            lastUpdate: uint64(block.timestamp),
            penaltyRate: 100,
            liquidationThreshold: 1500,
            maintenanceMargin: 3000,
            liquidationMargin: 2000,
            cumulativePenaltyTime: 0,
            slippageTolerance: 500,
            accruedPenalties: 0,
            isActive: true
        });

        assertEq(pos.collateral, 1000);
        assertEq(pos.borrowedPrincipal, 500);
        assertEq(pos.penaltyRate, 100);
        assertEq(pos.liquidationThreshold, 1500);
        assertEq(pos.maintenanceMargin, 3000);
        assertEq(pos.liquidationMargin, 2000);
        assertEq(pos.slippageTolerance, 500);
        assertTrue(pos.isActive);
    }

    function testLPPositionStruct() public {
        EventsAndStructs.LPPosition memory lpPos = EventsAndStructs.LPPosition({
            liquidity: 1000,
            entryTime: uint64(block.timestamp),
            lastClaim: uint64(block.timestamp)
        });

        assertEq(lpPos.liquidity, 1000);
        assertEq(lpPos.entryTime, block.timestamp);
        assertEq(lpPos.lastClaim, block.timestamp);
    }
}
