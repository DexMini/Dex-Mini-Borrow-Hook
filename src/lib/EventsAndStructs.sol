// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library EventsAndStructs {
    // Packed position data for gas efficiency
    struct Position {
        uint128 collateral; // WAD scaled
        uint128 borrowedPrincipal; // WAD scaled
        uint64 lastUpdate; // Timestamp
        uint32 penaltyRate; // WAD scaled per second
        uint32 liquidationThreshold; // WAD scaled
        uint32 maintenanceMargin; // MMR in BPS (e.g., 3000 = 30%)
        uint32 liquidationMargin; // Liquidation threshold in BPS
        uint64 cumulativePenaltyTime;
        uint128 accruedPenalties;
        uint128 slippageTolerance; // BPS (e.g., 500 = 0.5%)
        bool isActive;
    }

    struct LPPosition {
        uint128 liquidity;
        uint64 entryTime;
        uint64 lastClaim;
    }

    // Events
    event PositionUpdated(address indexed borrower, uint256 newCollateral);
    event PartialLiquidation(
        address indexed borrower,
        uint256 liquidatedAmount
    );
    event FullLiquidation(address indexed borrower, uint256 liquidatedAmount);
    event AutoDeleveraged(address indexed borrower, uint256 reductionAmount);
    event StakedToSafetyModule(address indexed staker, uint256 amount);
    event WithdrewFromSafetyModule(address indexed staker, uint256 amount);
}
