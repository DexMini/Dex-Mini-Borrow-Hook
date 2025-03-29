// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {console} from "forge-std/console.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {FullMath} from "@uniswap/v4-core/src/libraries/FullMath.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {BaseHook} from "@uniswap/v4-periphery/src/utils/BaseHook.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {EventsAndStructs} from "./lib/EventsAndStructs.sol";
import {Constants} from "./lib/Constants.sol";
import {LiquidationEngine} from "./logic/LiquidationEngine.sol";
import {LPVault} from "./logic/LPVault.sol";

/// @title OraclelessLendingHook
/// @notice A Uniswap v4 hook that implements an oracleless lending protocol using inverse range orders.
/// @dev It provides a flexible and secure lending framework for users to borrow and lend assets.

/*////////////////////////////////////////////////////////////////////////////
//                                                                          //
//     ██████╗ ███████╗██╗  ██╗    ███╗   ███╗██╗███╗   ██╗██╗           //
//     ██╔══██╗██╔════╝╚██╗██╔╝    ████╗ ████║██║████╗  ██║██║           //
//     ██║  ██║█████╗   ╚███╔╝     ██╔████╔██║██║██╔██╗ ██║██║           //
//     ██║  ██║██╔══╝   ██╔██╗     ██║╚██╔╝██║██║██║╚██╗██║██║           //
//     ██████╔╝███████╗██╔╝ ██╗    ██║ ╚═╝ ██║██║██║ ╚████║██║           //
//     ╚═════╝ ╚══════╝╚═╝  ╚═╝    ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═╝           //
//                                                                          //
//     Uniswap V4 Hook - Version 1.0                                       //
//     https://dexmini.com                                                 //
//                                                                          //
////////////////////////////////////////////////////////////////////////////*/

contract OraclelessLendingHook is BaseHook, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using FullMath for uint256;

    address public immutable token0;
    address public immutable token1;
    PoolKey public poolKey;
    address public protocolTreasury;
    uint256 public debtCeiling;

    LiquidationEngine public immutable liquidationEngine;
    LPVault public immutable lpVault;

    struct Position {
        uint128 collateral;
        uint128 debt;
        // ... other fields matching liquidationEngine's expectations ...
    }

    constructor(
        IPoolManager _poolManager,
        address _token0,
        address _token1,
        uint24 _fee,
        address _protocolTreasury
    ) BaseHook(_poolManager) {
        require(_token0 < _token1, "Token0 must be less than token1");
        token0 = _token0;
        token1 = _token1;
        protocolTreasury = _protocolTreasury;

        poolKey = PoolKey({
            currency0: Currency.wrap(_token0),
            currency1: Currency.wrap(_token1),
            fee: _fee,
            tickSpacing: 60,
            hooks: IHooks(address(this))
        });

        liquidationEngine = new LiquidationEngine(
            _token0,
            _token1,
            _protocolTreasury
        );
        lpVault = new LPVault(_token0, _protocolTreasury);
    }

    function getHookPermissions()
        public
        pure
        override
        returns (Hooks.Permissions memory)
    {
        return
            Hooks.Permissions({
                beforeInitialize: false,
                afterInitialize: false,
                beforeAddLiquidity: false,
                afterAddLiquidity: false,
                beforeRemoveLiquidity: false,
                afterRemoveLiquidity: false,
                beforeSwap: true,
                afterSwap: true,
                beforeDonate: false,
                afterDonate: false,
                beforeSwapReturnDelta: false,
                afterSwapReturnDelta: false,
                afterAddLiquidityReturnDelta: false,
                afterRemoveLiquidityReturnDelta: false
            });
    }

    function setPosition(
        uint128 collateral,
        uint128 borrowedAmount,
        uint32 liquidationThreshold,
        uint32 penaltyRate,
        uint128 _slippageTolerance,
        int24 tickLower,
        int24 tickUpper,
        uint32 maintenanceMargin,
        uint32 liquidationMargin
    ) external nonReentrant {
        require(tickLower < tickUpper, "Invalid tick range");
        require(collateral > 0, "Collateral required");
        require(penaltyRate <= Constants.MAX_PENALTY_RATE, "Penalty too high");
        require(_slippageTolerance <= Constants.BPS, "Slippage overflow");
        require(maintenanceMargin > liquidationMargin, "Invalid margins");

        uint256 currentDebt = _totalBorrowed();
        require(
            currentDebt + borrowedAmount <= debtCeiling,
            "Debt ceiling exceeded"
        );

        uint256 loanFee = FullMath.mulDiv(collateral, 100, Constants.BPS);
        uint256 totalDeposit = collateral + loanFee;

        IERC20(token0).safeTransferFrom(
            msg.sender,
            address(this),
            totalDeposit
        );

        lpVault.distributeFees(loanFee, tickLower, tickUpper);

        EventsAndStructs.Position memory newPosition = EventsAndStructs
            .Position({
                collateral: collateral,
                borrowedPrincipal: borrowedAmount,
                lastUpdate: uint64(block.timestamp),
                penaltyRate: penaltyRate,
                liquidationThreshold: liquidationThreshold,
                maintenanceMargin: maintenanceMargin,
                liquidationMargin: liquidationMargin,
                cumulativePenaltyTime: 0,
                slippageTolerance: _slippageTolerance,
                accruedPenalties: 0,
                isActive: true
            });

        liquidationEngine.setPosition(
            msg.sender,
            abi.encode(
                newPosition.collateral,
                newPosition.borrowedPrincipal,
                newPosition.lastUpdate,
                newPosition.penaltyRate,
                newPosition.liquidationThreshold,
                newPosition.maintenanceMargin,
                newPosition.liquidationMargin,
                newPosition.cumulativePenaltyTime,
                newPosition.slippageTolerance,
                newPosition.accruedPenalties,
                newPosition.isActive
            )
        );
        _updateDebtCeiling();
        emit EventsAndStructs.PositionUpdated(msg.sender, collateral);
    }

    function afterSwap(
        address, // sender (unused)
        PoolKey calldata, // key (unused)
        IPoolManager.SwapParams calldata, // params (unused)
        BalanceDelta, // delta (unused)
        bytes calldata data
    ) external override nonReentrant returns (bytes4, int128) {
        (address borrower, address liquidator) = abi.decode(
            data,
            (address, address)
        );
        liquidationEngine.liquidate(borrower, liquidator);
        return (BaseHook.afterSwap.selector, 0);
    }

    function afterModifyPosition(
        address sender,
        PoolKey calldata, // key (unused)
        IPoolManager.ModifyLiquidityParams calldata params,
        BalanceDelta, // delta (unused)
        BalanceDelta, // feesAccrued (unused)
        bytes calldata data
    ) external returns (bytes4, BalanceDelta) {
        require(msg.sender == address(poolManager), "Unauthorized");

        (, , uint128 reserved) = abi.decode(data, (int24, int24, uint128));

        console.log("Accessing LP positions for:");
        console.log("Sender:", sender);
        console.log("TickLower:", params.tickLower);
        console.log("TickUpper:", params.tickUpper);
        console.log("Reserved:", reserved);

        EventsAndStructs.LPPosition memory lpPos = lpVault.lpPositions(
            sender,
            params.tickLower,
            params.tickUpper
        );

        if (params.liquidityDelta > 0) {
            lpPos.liquidity += reserved;
            uint256 currentReserved = lpVault.totalReservedLiquidity(
                params.tickLower,
                params.tickUpper
            );
            lpVault.setTotalReservedLiquidity(
                params.tickLower,
                params.tickUpper,
                currentReserved + reserved
            );
        } else {
            lpPos.liquidity -= reserved;
            uint256 currentReserved = lpVault.totalReservedLiquidity(
                params.tickLower,
                params.tickUpper
            );
            lpVault.setTotalReservedLiquidity(
                params.tickLower,
                params.tickUpper,
                currentReserved - reserved
            );
        }

        return (this.afterModifyPosition.selector, BalanceDelta.wrap(0));
    }

    function _updateDebtCeiling() internal {
        uint256 utilization = (_totalBorrowed() * Constants.WAD) /
            IERC20(token0).balanceOf(address(this));
        debtCeiling = FullMath.mulDiv(
            utilization,
            IERC20(token0).balanceOf(address(this)),
            Constants.WAD
        );
    }

    function _totalBorrowed() internal view returns (uint256) {
        // Implementation would track total borrowed across all positions
        return 0; // Placeholder
    }

    function _validateTickRange(
        int24 tickLower,
        int24 tickUpper
    ) internal view {
        int24 minTick = TickMath.MIN_TICK;
        int24 maxTick = TickMath.MAX_TICK;
        require(tickLower >= minTick, "Invalid lower tick");
        require(tickUpper <= maxTick, "Invalid upper tick");
        require(tickLower < tickUpper, "Tick order reversed");
    }
}
