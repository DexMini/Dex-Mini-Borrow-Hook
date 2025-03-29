// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ILiquidationEngine {
    function liquidate(address borrower, address liquidator) external;
    function calculateHealthFactor(
        address borrower
    ) external view returns (uint256);
    function getFairPrice() external view returns (uint256);
}

interface ILPVault {
    function stakeToSafetyModule(uint256 amount) external;
    function withdrawFromSafetyModule(uint256 amount) external;
    function claimRewards(int24 tickLower, int24 tickUpper) external;
    function getLpPosition(
        address lp,
        int24 tickLower,
        int24 tickUpper
    )
        external
        view
        returns (uint256 liquidity, uint256 rewards, uint256 utilization);
    function distributeFees(
        uint256 fee,
        int24 tickLower,
        int24 tickUpper
    ) external;
    function setTotalReservedLiquidity(
        int24 tickLower,
        int24 tickUpper,
        uint256 amount
    ) external;
    function totalReservedLiquidity(
        int24 tickLower,
        int24 tickUpper
    ) external view returns (uint256);
}
