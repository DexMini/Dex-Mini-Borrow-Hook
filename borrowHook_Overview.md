# Advanced Lending & Borrowing with Concentrated Liquidity

Dex Mini's innovative Borrow Hook, accessible through our intuitive dApp, empowers both retail and institutional users with unprecedented control over on-chain liquidity. 

In the standard lending market, users deposit collateral (e.g., ETH) and borrow assets (e.g., DAI) based on a loan-to-value (LTV) ratio. If the value of the collateral drops, the LTV ratio increases. When the LTV exceeds a set liquidation threshold, the loan becomes eligible for liquidation. The platform's smart contract detects this breach and triggers the process. External liquidators, incentivized by discounts or a share of the collateral, step in to liquidate the loan. The collateral is sold, and the proceeds are used to repay the debt, with any surplus returned to the borrower. This process helps mitigate risk for the platform and lenders by protecting against defaults caused by price volatility.

## Our Lending Hook
We're not just enhancing liquidity management; we're redefining it.

### Key Benefits:

#### Precision Liquidity Deployment & Enhanced LTV:
- Deploy collateral within custom, granular liquidity ranges (e.g., -100 to +100 ticks), aligning with precise market conditions.
- Achieve industry-leading Loan-to-Value (LTV) ratios, borrowing up to 95% against ETH.
- Execute sophisticated borrowing strategies with unparalleled control over price positions.

#### Optimized Fee Generation: 
- Maximize returns from concentrated liquidity, effectively offsetting borrowing costs.
- Participate and earn rewards through incentivized liquidity provision.

#### Cross-Pool Flexibility: 
- Deposit collateral in one pool (e.g., WBTC/ETH) and borrow from another (e.g., USDT/GHO), unlocking diverse and advanced trading strategies.

#### Collateral Efficiency via Built-in Zap: 
- Seamlessly convert single-asset deposits into dual-token liquidity, optimizing capital utilization.

### Core Innovations Driving Capital Efficiency and Security:

- **Automated Limit Adjustments**: Our intelligent system dynamically adjusts debt/collateral ceilings per block, ensuring continuous organic borrowing while mitigating risks from sudden, large-scale withdrawals ("whale moments"). This provides a crucial safety buffer against vulnerabilities and market manipulation.

- **Robust Liquidation Engine**: Prioritizing timely elimination of bad debt, our advanced liquidation engine maintains protocol safety and optimizes LTV ratios.

- **Unified Liquidity through Tick Consolidation**: Addressing liquidity fragmentation, the Borrow Hook consolidates user liquidity into discrete ticks, enabling efficient position management.

- **Dynamic Loan-to-Value (LTV)**: Borrow up to a predefined LTV ratio, dynamically adjusted based on collateral type and market conditions.

- **Base Layer for Advanced DeFi Protocols**: The Borrow Hook serves as a fundamental building block for innovative, capital-efficient DeFi protocols.

### Risk & Reward Synergy

Borrowers' performance directly influences liquidity providers (LPs):
- ✅ Profitable Positions → Enhance LP returns through sustained trading activity.
- ⚠️ Defaults & Liquidations → Impact pool value, emphasizing the need for robust risk management.

This interconnected system ensures that borrowers and LPs are aligned, fostering an ecosystem where both parties benefit from responsible financial strategies.

## How It Works

Dex Mini integrates seamlessly with Uniswap v4, where liquidity is concentrated within specific price ranges. Borrowers engage with this structure through three fundamental pillars:

1. **Liquidity Availability** – Borrowing requires sufficient LP coverage within the selected range.
2. **Collateral Alignment** – Matching borrowing ranges with active LP positions minimizes slippage and enhances efficiency.
3. **Risk Mitigation** – Positions moving beyond LP-supported ranges risk under collateralization and liquidation.

### Step-by-Step Workflow

#### 1. Deposit Collateral
- Supply assets to earn passive yield and unlock borrowing capacity.
- Set a price range (lower/upper ticks) or use the Zap feature for seamless single-asset conversion.

#### 2. Borrow Assets
- Access liquidity within designated ranges, borrowing either a single asset or a token pair.

#### 3. Monitor & Manage
- Track your LTV ratio and liquidation thresholds in real time to maintain a secure position.

## Liquidation & Risk Management

Dex Mini prioritizes the safety of both borrowers and liquidity providers with a sophisticated, two-tiered liquidation system and proactive risk mitigation tools.

### Margin Requirements: Safeguarding Your Position

- **Minimum Maintenance Margin (MMR)**: This essential collateral buffer acts as a first line of defense, preventing immediate liquidation during minor market fluctuations.
- **Full Liquidation Threshold**: A critical safety boundary. Breaching this threshold triggers a full liquidation to protect liquidity providers from potential losses.

### Liquidation Process: A Two-Tiered Approach

#### Partial Liquidation (MMR Breach):
- Triggered when your collateral value falls below the MMR.
- A portion of your position is automatically liquidated to restore the required safety margin.
- Position modifications are temporarily restricted to prevent further risk.

#### Full Liquidation (Critical Threshold Breach):
- Activated when your collateral value breaches the full liquidation threshold.
- Remaining assets are distributed to liquidity providers.
- Protocol reserves cover any potential shortfalls, ensuring liquidity provider safety.

### Proactive Risk Mitigation: Staying Ahead of Market Volatility

#### Auto-Deleverage System
- Automatically unwinds high-risk positions, preventing cascading liquidations and maintaining overall protocol stability.

#### Liquidation Price Alerts (Uniswap Oracle Powered):
- Utilizes Uniswap's robust oracle to filter out temporary price fluctuations, ensuring accurate alerts.
- Provides real-time notifications based on your collateral value, accrued fees, and leverage (e.g., >10x).

### Empowering Users with Automated Position Protection

#### Trigger Health Factor:
- Sets the point at which automated position protection activates.
- Allows users to define a health factor threshold below their current level.
- When the position's health factor drops below this trigger, the system automatically executes a transaction to bolster the position.
- Automation uses available collateral to pay back debt.
- Gas fees and a small service fee are deducted from the collateral.

#### Target Health Factor:
- Determines the desired health factor level the automation will achieve.
- The system repays debt until the position reaches this target health factor.

### Continuous Monitoring and Control:
- Automated protection remains active until manually deactivated.
- Multiple automation events may occur during market downturns, each restoring the position to the target health factor.
- Users can cancel automation at any time.

### Strategies to Avoid Liquidation:
1. Maintain your Loan-to-Value (LTV) ratio below established risk thresholds.
2. Proactively add collateral or repay debt during periods of market volatility.
3. Utilize real-time monitoring tools to continuously track your position's health.

## Security & Transparency

Dex Mini prioritizes security and trust, employing:
- Rigorous smart contract audits
- Bug bounty programs
- Multi-layered risk mitigation (reserve factors, dynamic hooks, real-time monitoring)

> **Note:** DeFi carries inherent risks—users should always conduct due diligence before participating.

Dex Mini redefines DeFi lending by integrating concentrated liquidity strategies with institutional-grade risk management. With Auto-Deleverage mechanisms, cross-pool flexibility, and LP-focused protections, Dex Mini creates a sustainable ecosystem where capital efficiency meets user empowerment.

**Stay agile, monitor wisely, and leverage responsibly to maximize your DeFi potential.**

⚠ **Note:** Smart contracts inherently carry risk. Never invest more than you can afford to lose.

## Key Component

Borrow Hook introduces a revolutionary liquidity protocol, seamlessly integrating concentrated liquidity, intelligent risk management, and institutional-grade security. Leveraging the power of Uniswap v4 Hooks, Dex Mini empowers both retail and professional DeFi participants to maximize capital efficiency.

### Key Advantages:
- **Enhanced Capital Efficiency:** Dex Mini Borrow hook unlocks unprecedented capital utilization through its innovative integration of concentrated liquidity and flexible lending strategies.
- **Oracle-Free Design:** Built on Uniswap v4's oracle-free architecture, Borrow Hook minimizes reliance on external data feeds, reducing potential points of failure.

### Core Value Proposition for Diverse Participants:

#### Liquidity Providers (LPs):
- Maximize earnings through swap fees, borrowing interest, and liquidation rewards.
- Benefit from robust risk mitigation mechanisms, safeguarding their capital.

#### Borrowers:
- Access capital efficiently by posting collateral within customizable price ranges.
- Leverage Uniswap v4's architecture for secure and efficient borrowing.

#### Market Makers:
- Provide deep, low-slippage liquidity with advanced, built-in risk controls.
- Optimize profitability through adaptive fee structures.

## How Dex Mini Integrates with Uniswap v4

### 1. Swap Execution Flow
1. User triggers `Router.swap()`.
2. `PoolManager.swap()` calls the `beforeSwap()` hook function for risk assessment.
3. Trade executes.
4. `afterSwap()` hook function performs post-trade validations:
   - Checks real-time price via `poolManager.getSlot0()`.
   - Enforces penalties/liquidations if collateral requirements aren't met.

### 2. Liquidity Provision Flow
1. LP deposits liquidity using `modifyPosition()`.
2. `afterModifyPosition()` ensures liquidity is allocated for lending/borrowing.

## Detailed Workflow

### Step 1: Borrower Defines Position
- **Price Range:** Set `tickLower` & `tickUpper` (e.g., ±100 ticks from market).
- **Collateral:** Deposit token0 (e.g., ETH).
- **Loan Amount:** Borrow token1 (e.g., USDC) up to the Max LTV (e.g., 75%).

### Step 2: LPs Supply Liquidity
- LPs provide targeted liquidity using `afterModifyPosition()`.
- Borrowers only access liquidity within their selected range.

### Step 3: Price-Driven Execution
- **In-Range:** Position remains active, earning fees.
- **Out-of-Range:** Position freezes, triggering potential penalties or liquidation.

### Step 4: Automated Liquidation Checks
- `afterSwap()` continuously verifies collateral health.

#### Liquidation Triggers:
- **Partial:** If equity < 3% Maintenance Margin.
- **Full:** If equity < 2% Liquidation Margin.

## Understanding Credit Management

Credit management determines your borrowing capacity based on the collateral you provide.

### 1. Credit Limit: Your Maximum Borrowing Power
- Represents the maximum amount you can borrow against your supplied collateral.
- **Calculation:** Credit Limit = ∑(Supplied Assets × Collateral Factor)

**Example:**
- You supply $1,000 USDC as collateral.
- The Collateral Factor for USDC is 60%.
- Your Credit Limit = $1,000 × 60% = $600.

### 2. Remaining Credit: Your Available Borrowing Capacity
- Indicates how much more you can borrow before reaching your Credit Limit.
- **Calculation:** Remaining Credit = Credit Limit - Borrowed Amount

**Example:**
- If you've already borrowed $100, your Remaining Credit is:
  - Remaining Credit = $600 - $100 = $500
- This means you have $500 of borrowing capacity remaining.

### Safety Margin: Assessing Your Risk
- Expressed as a percentage indicating proximity to liquidation.
- **Calculation:** Safety Margin = (Remaining Credit / Credit Limit) × 100%

**Example:**
- $500 / $600 = 83.3% safety margin
- You've utilized 16.7% of your borrowing power
- You have 83.3% left

> **Critical Risk:** If your Remaining Credit reaches $0, you are at immediate risk of liquidation.

## Illustrative Scenarios

### 1. Regular User Swap Walkthrough (Alice)
**Scenario:** Alice swaps 1 ETH for USDC in the ETH/USDC pool

**Participants:** Alice, Router, PoolManager (PM), BorrowHook

**Swap Process:**
1. Alice initiates a swap via `Router.swap()`
2. Router calls `PoolManager.swap()`
3. PoolManager processes the swap
4. Hook checks liquidation conditions
5. Swap completes with potential penalties or liquidation triggers

### 2. Liquidity Provider's Perspective (Bob)
**Scenario:** Bob adds liquidity to the ETH/USDC pool and reserves 40% for lending

**Key Actions:**
- Adds liquidity to specific tick range
- Reserves portion of liquidity for potential loans
- Earns trading fees and borrow fees
- Can claim rewards based on liquidity provision

### 3. Borrower's Perspective (Bob Opens a Collateralized Loan)
**Scenario:** Bob wants to borrow 15,000 USDC using 10 ETH as collateral

**Process:**
1. Sets position parameters
2. Transfers collateral and pays loan fees
3. Receives borrowed amount
4. Position is monitored for potential liquidation

## Lending and Borrow Fee Structure

### Fee Breakdown:

1. **Liquidity Management Fees**
   - 0.25% per transaction
   - Allocation:
     * 30% to EigenLayer Operator
     * 70% to Dex Mini Protocol

2. **Trading Fees**
   - Allocation:
     * 90% to Liquidity Providers
     * 10% to Dex Mini Hook Reserve

3. **Collateral Deposit & Withdrawal Fees**
   - 0.25% flat fee
   - Allocation:
     * 70% to LPs
     * 30% to Dex Mini Protocol

4. **Borrowing Fees**
   - Variable APY (0.1% – 100%)
   - 100% of fees go to LPs

5. **Liquidation Penalty Fees**
   - 0.2% of position size
   - Allocation:
     * 70% to LPs
     * 30% to Dex Mini Protocol

### Why Dex Mini's Fee Model Stands Out:
- ✅ Offset Borrowing Costs
- ✅ LP-Centric Rewards
- ✅ Risk-Adaptive Pricing

> **Note:** All fees are subject to governance votes and market conditions. Always check real-time rates on the Dex Mini dApp.

By combining transparency, adaptability, and market-driven pricing, Dex Mini creates a sustainable and efficient DeFi ecosystem—whether you're trading stable assets or navigating high-risk markets.