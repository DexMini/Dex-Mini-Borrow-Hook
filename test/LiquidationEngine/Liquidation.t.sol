// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {LiquidationEngine} from "../../src/logic/LiquidationEngine.sol";
import {EventsAndStructs} from "../../src/lib/EventsAndStructs.sol";
import {Constants} from "../../src/lib/Constants.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LiquidationEngineLiquidationTest is Test {
    LiquidationEngine public engine;
    address public token0;
    address public token1;
    address public treasury;
    address public borrower;
    address public liquidator;
    MockERC20 public mockToken0;
    MockERC20 public mockToken1;

    function setUp() public {
        token0 = address(0x1);
        token1 = address(0x2);
        treasury = address(0x3);
        borrower = address(0x4);
        liquidator = address(0x5);

        mockToken0 = new MockERC20("Token0", "T0");
        mockToken1 = new MockERC20("Token1", "T1");

        engine = new LiquidationEngine(
            address(mockToken0),
            address(mockToken1),
            treasury
        );

        // Setup initial balances
        mockToken0.mint(address(engine), 10000);
        mockToken1.mint(address(engine), 10000);
    }

    function testPartialLiquidation() public {
        // Setup position below maintenance margin but above liquidation margin
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

        uint256 collateralBefore = pos.collateral;
        engine.liquidate(borrower, liquidator);

        // Verify 50% reduction in collateral
        assertEq(engine.positions(borrower).collateral, collateralBefore / 2);

        // Verify liquidator received 80% of liquidated collateral
        assertEq(
            mockToken0.balanceOf(liquidator),
            ((collateralBefore / 2) * Constants.LIQUIDATOR_REWARD) / 100
        );
    }

    function testFullLiquidation() public {
        // Setup position below liquidation margin
        EventsAndStructs.Position memory pos = EventsAndStructs.Position({
            collateral: 1000,
            borrowedPrincipal: 800,
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

        uint256 collateralBefore = pos.collateral;
        engine.liquidate(borrower, liquidator);

        // Verify position is closed
        assertFalse(engine.positions(borrower).isActive);
        assertEq(engine.positions(borrower).collateral, 0);

        // Verify liquidator received 80% of liquidated collateral
        assertEq(
            mockToken0.balanceOf(liquidator),
            (collateralBefore * Constants.LIQUIDATOR_REWARD) / 100
        );
    }
}

contract MockERC20 is IERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        decimals = 18;
    }

    function mint(address to, uint256 amount) public {
        balanceOf[to] += amount;
        totalSupply += amount;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}
