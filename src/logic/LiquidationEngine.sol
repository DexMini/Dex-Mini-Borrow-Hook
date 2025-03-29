// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {FullMath} from "@uniswap/v4-core/src/libraries/FullMath.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {EventsAndStructs} from "../lib/EventsAndStructs.sol";
import {Constants} from "../lib/Constants.sol";
import {ILiquidationEngine} from "../lib/Interfaces.sol";

contract LiquidationEngine is ILiquidationEngine {
    using FullMath for uint256;
    using Math for uint256;
    using SafeERC20 for IERC20;

    address public immutable token0;
    address public immutable token1;
    address public protocolTreasury;
    mapping(address => EventsAndStructs.Position) public positions;

    constructor(address _token0, address _token1, address _protocolTreasury) {
        require(_token0 < _token1, "Token0 must be less than token1");
        token0 = _token0;
        token1 = _token1;
        protocolTreasury = _protocolTreasury;
    }

    function _accruePenalties(EventsAndStructs.Position storage pos) internal {
        uint256 timeElapsed = block.timestamp - pos.lastUpdate;
        if (timeElapsed > 0 && pos.penaltyRate > 0) {
            uint256 penalties = FullMath.mulDiv(
                pos.collateral,
                pos.penaltyRate,
                Constants.WAD
            ) * timeElapsed;

            penalties = penalties > pos.collateral ? pos.collateral : penalties;

            pos.accruedPenalties += uint128(penalties);
            pos.collateral -= uint128(penalties);
        }
        pos.lastUpdate = uint64(block.timestamp);
    }

    function _partialLiquidation(
        EventsAndStructs.Position storage pos,
        address borrower,
        address liquidator
    ) internal {
        uint256 collateralToRemove = pos.collateral / 2; // 50% reduction
        pos.collateral -= uint128(collateralToRemove);

        uint256 liquidatorShare = (collateralToRemove *
            Constants.LIQUIDATOR_REWARD) / 100;
        IERC20(token0).safeTransfer(liquidator, liquidatorShare);
        IERC20(token0).safeTransfer(
            protocolTreasury,
            collateralToRemove - liquidatorShare
        );

        emit EventsAndStructs.PartialLiquidation(borrower, collateralToRemove);
    }

    function _fullLiquidation(
        EventsAndStructs.Position storage pos,
        address borrower,
        address liquidator,
        uint160 sqrtPriceX96
    ) internal {
        uint256 collateralBefore = pos.collateral;
        pos.collateral = 0;
        pos.isActive = false;

        // Calculate minimum acceptable price with slippage tolerance
        uint160 minPrice = uint160(
            FullMath.mulDiv(
                sqrtPriceX96,
                Constants.BPS - pos.slippageTolerance,
                Constants.BPS
            )
        );

        // Handle debt repayment with price validation
        uint256 debtOwed = pos.borrowedPrincipal + pos.accruedPenalties;
        uint256 debtPaid = uint256(sqrtPriceX96);
        require(sqrtPriceX96 >= minPrice, "Price below minimum");

        if (debtPaid < debtOwed) {
            uint256 shortfall = debtOwed - debtPaid;
            IERC20(token1).safeTransfer(protocolTreasury, shortfall);
        }

        // Transfer liquidation reward to liquidator
        uint256 liquidatorReward = (collateralBefore *
            Constants.LIQUIDATOR_REWARD) / 100;
        IERC20(token0).safeTransfer(liquidator, liquidatorReward);

        emit EventsAndStructs.FullLiquidation(borrower, collateralBefore);
    }

    function _autoDeleverage(
        EventsAndStructs.Position storage pos,
        address borrower
    ) internal {
        uint256 reduction = pos.borrowedPrincipal / 4; // Reduce by 25%
        pos.borrowedPrincipal -= uint128(reduction);
        emit EventsAndStructs.AutoDeleveraged(borrower, reduction);
    }

    function _calculateHealthFactor(
        EventsAndStructs.Position memory pos,
        uint256 price
    ) internal pure returns (uint256) {
        uint256 collateralValue = pos.collateral * price;
        uint256 debtValue = (pos.borrowedPrincipal + pos.accruedPenalties) *
            Constants.WAD;
        return (collateralValue * Constants.BPS) / debtValue;
    }

    function calculateHealthFactor(
        address borrower
    ) external view returns (uint256) {
        EventsAndStructs.Position memory pos = positions[borrower];
        uint256 currentPrice = getFairPrice();
        return _calculateHealthFactor(pos, currentPrice);
    }

    function getFairPrice() public view returns (uint256) {
        // Implementation would get price from Uniswap pool
        return 0; // Placeholder
    }

    function liquidate(address borrower, address liquidator) external {
        EventsAndStructs.Position storage pos = positions[borrower];
        if (!pos.isActive) return;

        _accruePenalties(pos);
        uint256 healthFactor = _calculateHealthFactor(pos, getFairPrice());

        if (healthFactor < pos.liquidationMargin) {
            _fullLiquidation(pos, borrower, liquidator, 0); // sqrtPriceX96 placeholder
        } else if (healthFactor < pos.maintenanceMargin) {
            _partialLiquidation(pos, borrower, liquidator);
        }

        if (
            healthFactor <
            (pos.maintenanceMargin * Constants.AUTO_DELEVERAGE_THRESHOLD) / 100
        ) {
            _autoDeleverage(pos, borrower);
        }
    }

    function setPosition(address user, bytes calldata positionData) external {
        // Add authorization check if needed
        positions[user] = abi.decode(positionData, (EventsAndStructs.Position));
    }
}

struct Position {
    uint128 collateral;
    uint128 borrowedPrincipal;
    uint64 lastUpdate;
    uint32 penaltyRate;
    uint32 liquidationThreshold;
    uint32 maintenanceMargin;
    uint32 liquidationMargin;
    uint64 cumulativePenaltyTime;
    uint128 slippageTolerance;
    uint128 accruedPenalties;
    bool isActive;
}
