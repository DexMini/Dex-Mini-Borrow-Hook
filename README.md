# Dex Mini Borrow Hook v4

<div align="center">

[![Foundry][foundry-badge]][foundry-url] [![Uniswap v4][uniswap-badge]][uniswap-url] [![License: MIT][license-badge]][license-url]

<img src="https://img.shields.io/badge/Ethereum-3C3C3D?style=for-the-badge&logo=ethereum&logoColor=white" alt="Ethereum" />

**Advanced Lending & Borrowing with Concentrated Liquidity**

</div>

## 📑 Overview

Dex Mini is innovative Borrow Hook empowers both retail and institutional users with unprecedented control over on-chain liquidity. Built on Uniswap v4, our protocol redefines DeFi lending by integrating concentrated liquidity with institutional-grade risk management.

```mermaid
%% Swap Execution Sequence Diagram
sequenceDiagram
    participant User
    participant Router
    participant PoolManager
    participant BorrowHook
    participant LiquidityProviders
    
    User->>Router: swap()
    Router->>PoolManager: swap()
    PoolManager->>BorrowHook: beforeSwap()
    Note right of BorrowHook: Risk assessment<br/>Collateral check<br/>Borrowing validation
    BorrowHook-->>PoolManager: approval
    PoolManager->>PoolManager: executeSwap()
    PoolManager->>BorrowHook: afterSwap()
    Note right of BorrowHook: Post-trade validation<br/>Liquidation check<br/>Fee distribution
    BorrowHook-->LiquidityProviders: Fee allocation
    BorrowHook-->>User: swapResult + position update
```

## 🚀 Key Features

<div align="center">

| Feature | Description |
|---------|-------------|
| 📈 **Precision Liquidity** | Deploy collateral within custom ranges with up to 95% LTV against ETH |
| 💸 **Optimized Fee Generation** | Maximize returns from concentrated liquidity to offset borrowing costs |
| 🔄 **Cross-Pool Flexibility** | Deposit in one pool and borrow from another for advanced strategies |
| 🔌 **Built-in Zap** | Convert single-asset deposits into dual-token liquidity effortlessly |
| 🛡️ **Auto-Deleverage** | Intelligent system for dynamic debt/collateral ceiling adjustments |
| ⚡ **Advanced Liquidation** | Robust two-tiered liquidation system for optimal risk management |
| 🧠 **Oracle-Free Design** | Minimized reliance on external data feeds for enhanced security |

</div>

## 🌐 User Journey

```mermaid
flowchart TD
    A[User] --> B[Deposit Collateral]
    B --> C{Set Position Range}
    C -->|Custom| D[Manual tick specification]
    C -->|Auto| E[Zap single asset]
    D --> F[Borrow Assets]
    E --> F
    F --> G[Monitor Position]
    G --> H{Position Health}
    
    H -->|Healthy| I[Earn LP Fees]
    I --> G
    
    H -->|At Risk| J[Warning Threshold]
    J -->|Add Collateral| G
    J -->|Do Nothing| K[Liquidation Check]
    
    K -->|Partial Liquidation| L[Below MMR 3%]
    K -->|Full Liquidation| M[Below LTV 2%]
    
    L --> N[Restore Position]
    N --> G
    
    M --> O[Distribute Assets to LPs]
    
    style A fill:#6495ED,stroke:#4169E1,color:#fff
    style B fill:#4CAF50,stroke:#388E3C,color:#fff
    style F fill:#FF9800,stroke:#F57C00,color:#fff
    style L fill:#FFC107,stroke:#FFB300,color:#000
    style M fill:#F44336,stroke:#D32F2F,color:#fff
```

## 🔧 Hook Integration Architecture

```mermaid
graph TB
    subgraph Uniswap v4 Core
        PM[PoolManager]
        R[Router]
    end
    
    subgraph BorrowHook Framework
        subgraph Hook Lifecycle
            BS[beforeSwap]
            AS[afterSwap]
            AMP[afterModifyPosition]
        end
        
        subgraph Risk Management
            RA[Risk Assessment]
            LM[Liquidation Manager]
            ADL[Auto-Deleverage]
        end
        
        subgraph Position Management
            PM2[Position Manager]
            CM[Collateral Manager]
            Fee[Fee Distribution]
        end
    end
    
    subgraph Users
        LP[Liquidity Providers]
        B[Borrowers]
        MM[Market Makers]
    end
    
    R --> PM
    PM <--> BS
    PM <--> AS
    PM <--> AMP
    
    BS --> RA
    AS --> LM
    AMP --> PM2
    
    RA <--> CM
    LM <--> ADL
    PM2 <--> Fee
    
    CM <--> B
    Fee <--> LP
    ADL <--> MM
    
    style BS fill:#4CAF50,stroke:#388E3C,color:#fff
    style AS fill:#FFC107,stroke:#FFA000,color:#000
    style AMP fill:#2196F3,stroke:#1976D2,color:#fff
    style LM fill:#F44336,stroke:#D32F2F,color:#fff
```

## 💻 Core Functions

```solidity
// Position creation
function createBorrowPosition(
    PoolKey memory key,
    int24 tickLower,
    int24 tickUpper,
    uint256 collateralAmount,
    uint256 borrowAmount
) external returns (uint256 positionId) {
    // Validate position parameters
    require(borrowAmount <= getMaxBorrowAmount(collateralAmount, key), "Exceeds max LTV");
    
    // Setup collateral and position
    poolManager.modifyPosition(
        key, 
        IPoolManager.ModifyPositionParams({
            tickLower: tickLower,
            tickUpper: tickUpper,
            liquidityDelta: collateralAmount.toInt256()
        }),
        abi.encode(BorrowParams({
            borrowAmount: borrowAmount,
            recipient: msg.sender
        }))
    );
    
    // Return the new position ID
    return nextPositionId++;
}
```

## 📊 Credit Management

<div align="center">

```mermaid
graph LR
    subgraph Credit System
        A[Collateral Value] -->|Collateral Factor| B[Credit Limit]
        B -->|Minus Borrowed| C[Remaining Credit]
        C -->|Divided by Credit Limit| D[Safety Margin %]
    end
    
    style A fill:#4CAF50,stroke:#388E3C,color:#fff
    style B fill:#2196F3,stroke:#1976D2,color:#fff
    style C fill:#FFC107,stroke:#FFA000,color:#000
    style D fill:#F44336,stroke:#D32F2F,color:#fff
```

</div>

### Understanding Your Credit

| Metric | Formula | Example |
|--------|---------|---------|
| **Credit Limit** | Collateral × Collateral Factor | $1,000 USDC × 60% = $600 |
| **Remaining Credit** | Credit Limit - Borrowed Amount | $600 - $100 = $500 |
| **Safety Margin** | (Remaining Credit / Credit Limit) × 100% | ($500 / $600) × 100% = 83.3% |

> ⚠️ **Critical Risk:** A Safety Margin of 0% puts your position at immediate risk of liquidation.

## 🛡️ Liquidation & Risk Management

Dex Mini employs a sophisticated two-tiered liquidation system with proactive risk mitigation tools:

### Liquidation Thresholds

| Threshold | Trigger | Action |
|-----------|---------|--------|
| **MMR (3%)** | Position equity < 3% | Partial liquidation to restore margin |
| **Full Liquidation (2%)** | Position equity < 2% | Complete liquidation & asset distribution |

### Automated Position Protection

```mermaid
flowchart LR
    A[Current Health<br>Factor: 1.5] --> B{Drops Below<br>Trigger: 1.2}
    B -->|Yes| C[Automation<br>Activates]
    C --> D[Repay Debt<br>from Collateral]
    D --> E[Restore to<br>Target: 1.3]
    B -->|No| F[Continue<br>Monitoring]
    
    style A fill:#4CAF50,stroke:#388E3C,color:#fff
    style B fill:#FFC107,stroke:#FFA000,color:#000
    style C fill:#2196F3,stroke:#1976D2,color:#fff
    style E fill:#4CAF50,stroke:#388E3C,color:#fff
```

## 💰 Fee Structure

<div align="center">

| Fee Type | Rate | LP Share | Protocol Share | EigenLayer Operator |
|----------|------|----------|----------------|---------------------|
| **Liquidity Management** | 0.25% | 70% | 0% | 30% |
| **Trading** | Variable | 90% | 10% | 0% |
| **Deposit & Withdraw** | 0.25% | 70% | 30% | 0% |
| **Borrowing** | 0.1-100% APY | 100% | 0% | 0% |
| **Liquidation Penalty** | 0.2% | 70% | 30% | 0% |

</div>

## 🔐 Security & Transparency

- ✅ Rigorous smart contract audits
- ✅ Comprehensive bug bounty program
- ✅ Multi-layered risk mitigation
- ✅ Real-time monitoring systems

> ⚠️ **Note:** DeFi carries inherent risks. Always conduct due diligence before participating.

## 📦 Installation

```bash
# Clone the repository
git clone https://github.com/dex-mini/borrow-hook-v4.git
cd borrow-hook-v4

# Install dependencies
forge install

# Build the project
forge build
```

## 🧪 Testing

```bash
# Run all tests
forge test -vvv

# Run specific test suite
forge test --match-contract BorrowHookTest -vvv

# Run with gas reporting
forge test --gas-report
```

## 📚 Usage Examples

### Creating a Borrow Position

```solidity
// Set up position parameters
address token0 = WETH;
address token1 = USDC;
int24 tickLower = -100;
int24 tickUpper = 100;
uint256 collateralAmount = 10 ether;
uint256 borrowAmount = 15000 * 10**6; // 15,000 USDC

// Approve token transfer
IERC20(token0).approve(address(borrowHook), collateralAmount);

// Create position
uint256 positionId = borrowHook.createBorrowPosition(
    PoolKey({token0: token0, token1: token1, fee: 3000}),
    tickLower,
    tickUpper,
    collateralAmount,
    borrowAmount
);
```

## 🌟 Advanced Features

- **Dynamic LTV Ratios**: Borrow up to 95% against ETH based on market conditions
- **Tick Consolidation**: Combat liquidity fragmentation through consolidated positions
- **Cross-Pool Collateralization**: Use collateral from one pool to borrow from another
- **Auto-Deleverage System**: Automatically unwind high-risk positions to prevent cascading liquidations

## 📜 License

[MIT License](LICENSE)

---

<div align="center">

**Stay agile, monitor wisely, and leverage responsibly to maximize your DeFi potential.**

[Website](https://dexmini.com) • [Docs](https://docs.dexmini.com) • [Twitter](https://twitter.com/dexmini)

</div>

[foundry-badge]: https://img.shields.io/badge/Built%20with-Foundry-FF8000?style=flat-square
[foundry-url]: https://getfoundry.sh
[uniswap-badge]: https://img.shields.io/badge/Powered%20by-Uniswap%20v4-FF007A?style=flat-square
[uniswap-url]: https://uniswap.org
[license-badge]: https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square
[license-url]: https://opensource.org/licenses/MIT
