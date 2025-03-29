// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library Constants {
    uint256 public constant WAD = 1e18;
    uint256 public constant BPS = 1e4;
    uint256 public constant MAX_PENALTY_RATE = 1157407407407407; // 0.1% daily (1e17/86400)

    // Protocol fee ratios
    uint256 public constant EIGEN_SHARE = 30; // 30%
    uint256 public constant PROTOCOL_SHARE = 20; // 20%
    uint256 public constant LP_SHARE = 50; // 50%

    // Liquidation parameters
    uint256 public constant LIQUIDATOR_REWARD = 80; // 80%
    uint256 public constant AUTO_DELEVERAGE_THRESHOLD = 110; // 110% of maintenance margin
    uint256 public constant AUTO_DELEVERAGE_REDUCTION = 25; // 25% reduction
}
