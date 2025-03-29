// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {EventsAndStructs} from "../lib/EventsAndStructs.sol";
import {Constants} from "../lib/Constants.sol";
import {ILPVault} from "../lib/Interfaces.sol";

contract LPVault is ILPVault {
    using SafeERC20 for IERC20;

    address public immutable token0;
    address public protocolTreasury;

    mapping(address => mapping(int24 => mapping(int24 => EventsAndStructs.LPPosition)))
        public lpPositions;
    mapping(int24 => mapping(int24 => uint256)) public totalReservedLiquidity;
    mapping(address => mapping(int24 => mapping(int24 => uint256)))
        public lpRewards;
    mapping(address => uint256) public safetyModuleBalances;

    event StructDebug(
        address indexed user,
        int24 tickLower,
        int24 tickUpper,
        uint128 liquidity,
        uint128 reservedLiquidity,
        uint64 lastUpdated
    );

    constructor(address _token0, address _protocolTreasury) {
        token0 = _token0;
        protocolTreasury = _protocolTreasury;
    }

    function stakeToSafetyModule(uint256 amount) external {
        IERC20(token0).safeTransferFrom(msg.sender, address(this), amount);
        safetyModuleBalances[msg.sender] += amount;
        emit EventsAndStructs.StakedToSafetyModule(msg.sender, amount);
    }

    function withdrawFromSafetyModule(uint256 amount) external {
        require(safetyModuleBalances[msg.sender] >= amount, "Overdrawn");
        safetyModuleBalances[msg.sender] -= amount;
        IERC20(token0).safeTransfer(msg.sender, amount);
        emit EventsAndStructs.WithdrewFromSafetyModule(msg.sender, amount);
    }

    function claimRewards(int24 tickLower, int24 tickUpper) external {
        EventsAndStructs.LPPosition memory pos = lpPositions[msg.sender][
            tickLower
        ][tickUpper];
        require(pos.liquidity > 0, "No position");

        uint256 rewards = lpRewards[msg.sender][tickLower][tickUpper];
        require(rewards > 0, "No rewards");

        lpRewards[msg.sender][tickLower][tickUpper] = 0;
        IERC20(token0).safeTransfer(msg.sender, rewards);
    }

    function getLpPosition(
        address lp,
        int24 tickLower,
        int24 tickUpper
    )
        external
        view
        returns (uint256 liquidity, uint256 rewards, uint256 utilization)
    {
        EventsAndStructs.LPPosition memory pos = lpPositions[lp][tickLower][
            tickUpper
        ];
        liquidity = pos.liquidity;
        rewards = lpRewards[lp][tickLower][tickUpper];
        uint256 reserved = totalReservedLiquidity[tickLower][tickUpper];
        utilization = pos.liquidity > 0 ? (reserved * 1e18) / pos.liquidity : 0;
    }

    function _distributeFees(
        uint256 fee,
        int24 tickLower,
        int24 tickUpper
    ) internal {
        uint256 eigenShare = (fee * Constants.EIGEN_SHARE) / 100;
        uint256 protocolShare = (fee * Constants.PROTOCOL_SHARE) / 100;
        uint256 lpShare = fee - eigenShare - protocolShare;

        IERC20(token0).safeTransfer(protocolTreasury, eigenShare);
        IERC20(token0).safeTransfer(protocolTreasury, protocolShare);
        lpRewards[msg.sender][tickLower][tickUpper] += lpShare;
    }

    function distributeFees(
        uint256 fee,
        int24 tickLower,
        int24 tickUpper
    ) external {
        _distributeFees(fee, tickLower, tickUpper);
    }

    function setTotalReservedLiquidity(
        int24 tickLower,
        int24 tickUpper,
        uint256 amount
    ) external {
        totalReservedLiquidity[tickLower][tickUpper] = amount;
    }

    function getTotalReservedLiquidity(
        int24 tickLower,
        int24 tickUpper
    ) public view returns (uint256) {
        return totalReservedLiquidity[tickLower][tickUpper];
    }
}
