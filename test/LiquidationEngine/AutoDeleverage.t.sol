// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {LiquidationEngine} from "../../src/logic/LiquidationEngine.sol";
import {EventsAndStructs} from "../../src/lib/EventsAndStructs.sol";
import {Constants} from "../../src/lib/Constants.sol";

contract LiquidationEngineAutoDeleverageTest is Test {
    LiquidationEngine public engine;
    address public token0;
    address public token1;
    address public treasury;
    address public borrower;

    function setUp() public {
        token0 = address(0x1);
        token1 = address(0x2);
        treasury = address(0x3);
        borrower = address(0x4);

        engine = new LiquidationEngine(token0, token1, treasury);
    }

    function testAutoDeleverage() public {
        // Setup position with health factor below auto-deleverage threshold
        EventsAndStructs.Position memory pos = EventsAndStructs.Position({
            collateral: 1000,
            borrowedPrincipal: 800,
            lastUpdate: uint64(block.timestamp),
            penaltyRate: 100,
            liquidationThreshold: 1500,
            maintenanceMargin: 3000, // 30%
            liquidationMargin: 2000, // 20%
            cumulativePenaltyTime: 0,
            slippageTolerance: 500,
            accruedPenalties: 0,
            isActive: true
        });

        engine.positions(borrower) = pos;

        uint256 borrowedBefore = pos.borrowedPrincipal;
        engine.liquidate(borrower, address(0));

        // Verify 25% reduction in borrowed amount
        assertEq(
            engine.positions(borrower).borrowedPrincipal,
            (borrowedBefore * 75) / 100
        );
    }

    function testNoAutoDeleverage() public {
        // Setup position with health factor above auto-deleverage threshold
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

        engine.positions(borrower) = pos;

        uint256 borrowedBefore = pos.borrowedPrincipal;
        engine.liquidate(borrower, address(0));

        // Verify no reduction in borrowed amount
        assertEq(engine.positions(borrower).borrowedPrincipal, borrowedBefore);
    }
}
