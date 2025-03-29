// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {LiquidationEngine} from "../../src/logic/LiquidationEngine.sol";
import {EventsAndStructs} from "../../src/lib/EventsAndStructs.sol";
import {Constants} from "../../src/lib/Constants.sol";

contract LiquidationEngineHealthFactorTest is Test {
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

    function testCalculateHealthFactor() public {
        // Setup position with 1000 collateral and 500 borrowed
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

        // Mock fair price to 1:1 ratio
        uint256 healthFactor = engine.calculateHealthFactor(borrower);

        // With 1000 collateral and 500 borrowed, health factor should be 200%
        assertEq(healthFactor, 20000); // 200% in BPS
    }

    function testHealthFactorWithPenalties() public {
        EventsAndStructs.Position memory pos = EventsAndStructs.Position({
            collateral: 1000,
            borrowedPrincipal: 500,
            lastUpdate: uint64(block.timestamp - 86400), // 1 day ago
            penaltyRate: 100,
            liquidationThreshold: 1500,
            maintenanceMargin: 3000,
            liquidationMargin: 2000,
            cumulativePenaltyTime: 86400,
            slippageTolerance: 500,
            accruedPenalties: 100,
            isActive: true
        });

        engine.positions(borrower) = pos;

        uint256 healthFactor = engine.calculateHealthFactor(borrower);

        // With 1000 collateral, 500 borrowed, and 100 penalties
        // Health factor should be (1000 * 10000) / (500 + 100) = 16666.67 BPS
        assertEq(healthFactor, 16666);
    }
}
