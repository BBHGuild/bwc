# 2025 EVM Contract Vulnerability Incidents Classification & Analysis.

This database uses the [BWC](../BWC/BWC.md) to classify Contract Vulnerability Incidents. Note off-chain issues have been excluded they're the most prevalent and resulted in more values lost. Humans remains to be the weakest point human stupidity or ingenuity(depending on how you look at it) could be infinite. It's unfeasible to track it.

---

## 2025-12-31 - 6

- **Date**: 2025-12-29
- **Project**: Multiple (e.g., Skep-pe) / "Anti-Rug" Vigilante Bot
- **Value Lost**: Variable (Deployer ETH Locked / Failed Launches)
- **Chain**: Ethereum
- **Actor**: `0x5c37ce78b79a09d211f3d35a617f980585e32b3c`
- **BWC**:
  - **Broader Classification**: `BWC 8: Denial of Service (DoS) Vulnerabilities`
  - **Primary Classification**: `BWC 8.11: DoS via Front-Running (Griefing)`
  - **Secondary Classification**: `BWC 3.2.1: Improper Initialization`
- **Description**:
  - A sophisticated "vigilante" bot campaign was identified targeting new token launches (often categorized as "shitcoins") that utilize a specific initialization pattern.
  - **The Flaw:** Many token contracts use a `startTrading` or `openTrading` function that unconditionally calls `IUniswapV2Factory.createPair()`. The factory reverts if a pair for the token combination already exists.
  - **The Exploit:** The bot monitors the mempool for deployers funding their token contracts with ETH in preparation for liquidity addition. The bot then front-runs the deployer's `openTrading` transaction by calling `createPair` on the Uniswap factory directly.
  - **The Impact:** When the deployer's transaction attempts to execute, it reverts because the pair now exists. This effectively "bricks" the launch. In many cases, the contracts lack a mechanism to rescue the ETH sent to the contract (or rely on `openTrading` to move it), causing the deployer's initial liquidity funds to be permanently locked or "burned."
  - **Code Snippet:**
    ```solidity
    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        
        // VULNERABILITY: The bot calls factory.createPair() before this transaction executes.
        // This causes the legitimate launch transaction to revert due to the pair already existing.
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }
    ```
- **References**:
  - [Deeberiroz X Alert](https://x.com/deeberiroz/status/2006295428137161113)
  - [Threat Actor Address](https://etherscan.io/address/0x5c37ce78b79a09d211f3d35a617f980585e32b3c)
---

## 2025-12-29 - 5

- **Date**: 2025-12-29
- **Project**: MSCST (Staking Contract) / GPC Token
- **Value Lost**: ~\$129,900
- **Chain**: BSC
- **BWC**:
  - **Broader Classification**: `BWC 2: Access Control Vulnerabilities`
  - **Primary Classification**: `BWC 2.1.1: Missing Access Control`
  - **Secondary Classification**: `BWC 5.2.1: Price Manipulation` (Atomic Sandwich)
- **Description**:
  - **Note**: This incident occurred in late 2025.
  - The MSCST staking contract on BSC was exploited for ~\$129.9k via an atomic sandwich attack facilitated by a public function.
  - **Vulnerability**: The `releaseReward` function lacked access control, allowing any caller to trigger internal logic. Additionally, the function allowed the caller to specify a `fee` parameter (or implicitly used the contract's balance) to execute a swap.
  - **Attack Flow**:
    1. **Flashloan & Dump**: The attacker flashloaned GPC tokens and swapped them for BNB, lowering the price of GPC.
    2. **Trigger Vulnerability**: The attacker called `releaseReward` with the `fee` set to the contract's MSC balance. This function swapped MSC for GPC and transferred the GPC directly to the GPC/BNB liquidity pool (calling `sync`), effectively increasing the GPC reserves and further lowering the price (making GPC cheaper).
    3. **Arbitrage**: The attacker swapped their BNB back for GPC at the artificially lowered price, profiting from the spread, and repaid the flashloan.
- **References**:
  - [TenArmor Alert](https://x.com/TenArmorAlert/status/2005509505988055471)
  - [Weilin Li Analysis](https://x.com/hklst4r/status/2005515461773885670)
  - [Attack Transaction (BscScan)](https://bscscan.com/tx/0x6c9ed4c2d81b6abfdf297b0cbc13585ed91f2a5e69e3545d3ea4316f50021b56)

---

## 2025-12-24 - 4

- **Date**: 2025-12-24
- **Project**: EIP-7702 Delegatee Contract (Unnamed)
- **Value Lost**: ~\$280,000
- **Chain**: BSC
- **BWC**:
  - **Broader Classification**: `BWC 10: Network & Consensus Evolution Attacks`
  - **Primary Classification**: `BWC 10.4.1: EIP-7702 Delegation Risks` (Initialization Front-Running)
  - **Secondary Classification**: `BWC 3.2.1: Improper Initialization`
- **Description**:
  - An uninitialized EIP-7702 delegatee contract was exploited on BSC, resulting in a loss of approximately \$280,000.
  - **Vulnerability**: The contract, intended to serve as a code source for EIP-7702 delegations, was deployed without being initialized.
  - **Attack Flow**: The attacker called the exposed initialization function to grant themselves the owner role of the delegatee contract. Once in control of the logic contract, they were able to manipulate the accounts that had delegated to it, effectively draining the funds from the delegators.
  - **Aftermath**: The stolen funds (~95 ETH equivalent) were subsequently deposited into Tornado Cash.
- **References**:
  - [CertiK Alert](https://x.com/CertiKAlert/status/2004016723264160150)
  - [Attack Transaction (BscScan)](https://bscscan.com/tx/0x7e0d120a234b91e7d134ab3444e33a8827bab8488b4df9810d7ada866cc16649)

---

## 2025-12-21 - 3

- **Date**: 2025-12-21
- **Project**: CHAR (Token Pair)
- **Value Lost**: ~\$144,500
- **Chain**: BSC
- **BWC**:
  - **Broader Classification**: `BWC 5: Economic & Game-Theoretic Vulnerabilities`
  - **Primary Classification**: `BWC 5.1.2: Back-Running` (MEV Skimming)
  - **Secondary Classification**: `BWC 1.1.7: User Disempowerment` (Operational Error / "Fat Finger")
- **Description**:
  - A user or project team member suffered a loss of ~\$144.5k involving the CHAR token on BSC.
  - **Vulnerability**: This was an operational error rather than a smart contract flaw. The victim mistakenly transferred CHAR tokens directly to the Uniswap V2-style liquidity pair address instead of interacting with the router to swap them.
  - **Execution**: The liquidity pool contract's balance became greater than its tracked reserves (sync mismatch). An MEV bot detected this discrepancy and executed a transaction (likely calling `skim()` or a swap) to extract the excess tokens, effectively claiming the "donated" funds.
- **References**:
  - [TenArmor Alert](https://x.com/TenArmorAlert/status/2003381605763526817)
  - [Attack Transaction (BscScan)](https://bscscan.com/tx/0x1db1c2a9ba616659df28dff35e23051b7791e1c078fa8ccefe22a4f6c8513a7e)

---

## 2025-12-19 - 2

- **Date**: 2025-12-19
- **Project**: Dragun69
- **Value Lost**: ~\$87,400
- **Chain**: BSC
- **BWC**:
  - **Broader Classification**: `BWC 3: Smart Contract Logic & State Manipulation`
  - **Primary Classification**: `BWC 3.3.3: Improper Handling of Native Tokens` (Missing `msg.value` Check)
  - **Secondary Classification**: `BWC 4.1.1: Insufficient Input Validation`
- **Description**:
  - **Note**: This incident occurred in late 2025 but was logged in the 2026 database due to disclosure/reporting timing.
  - The "Dragun69: Router" contract on BSC was exploited for ~\$87.4k due to a missing validation check on native token transfers.
  - **Vulnerability**: The router's swap function (specifically for ETH -> Token swaps) failed to verify `msg.value`. The contract logic assumed that the BNB amount specified in the swap parameters was provided by the caller in the current transaction. However, without the check, the contract utilized its own accumulated BNB balance to execute the swap.
  - **Attack Flow**:
    1. **Trigger**: The attacker called the Aggregator Proxy, which triggered the vulnerable implementation to run a PancakeV3 swap.
    2. **Misappropriation**: The router, failing to check `msg.value`, spent its own WBNB/BNB reserves to fulfill the swap.
    3. **Extraction**: The swap callback verified the balance and forwarded the resulting tokens/BNB to a recipient address specified in the untrusted calldata (the attacker), effectively draining the contract.
  - **Note**: The project's deployments on Base and Ethereum were not affected as they correctly included the `msg.value` check. The BSC implementation was patched ~6 hours after the exploit.
- **References**:
  - [TenArmor Alert](https://x.com/TenArmorAlert/status/2002924740718067845)
  - [Weilin Li Analysis](https://x.com/hklst4r/status/2003003168943219156)
  - [Zyy0530 Analysis](https://x.com/Zyy0530/status/2002984605457031573)
  - [Attack Transaction (BscScan)](https://bscscan.com/tx/0x9f6f0b1fc0e946b58a5fa2ab14cf8c4b3630bba9abd6849bcb3c9b666f59cda7)

---

## 2025-12-13 - 1

- **Date**: 2025-12-13
- **Project**: [Ribbon Finance](https://x.com/ribbonfinance) (Legacy Contracts / Opyn Fork)
- **Value Lost**: ~\$2,700,000
- **Chain**: Ethereum
- **BWC**:
  - **Broader Classification**: `BWC 2: Access Control Vulnerabilities`
  - **Primary Classification**: `BWC 2.1.1: Missing Access Control` (Unprotected Oracle Configuration/Ownership)
  - **Secondary Classification**: `BWC 4.2.2: Oracle Manipulation`
- **Description**:
  - **Note**: This incident occurred in late 2025.
  - Legacy contracts associated with Ribbon Finance (specifically an Opyn fork) were exploited for approximately \$2.7M.
  - **Vulnerability**: The root cause was identified as a flawed oracle upgrade. Approximately 6 days prior to the attack, the oracle pricer was updated. This update reportedly introduced an access control vulnerability (potentially involving an unprotected `transferOwnership` or insufficient checks on the pricer whitelist logic) that allowed the attacker to manipulate price-feed proxies.
  - **Attack Flow**:
    1. **Market Creation**: The attacker created a new option market (e.g., LINK/USDC) with a short expiration time.
    2. **Oracle Manipulation**: Abusing the vulnerable oracle stack, the attacker forced arbitrary expiry prices for assets like wstETH, AAVE, LINK, and WBTC into the shared Oracle at the specific expiry timestamp.
    3. **Drain**: The attacker redeemed large short oToken positions against the MarginPool. Because the MarginPool relied on the forged expiry prices for settlement, the attacker was able to drain WETH, wstETH, USDC, and WBTC.
- **References**:
  - [Weilin Li Analysis](https://x.com/hklst4r/status/1999661564647882859)
  - [LZhou Analysis](https://x.com/lzhou1110/status/1999673530661945702)
  - [Specter Analyst Alert](https://x.com/SpecterAnalyst/status/1999532982411854109)
  - [Expiry Price Manipulation Tx (Etherscan)](https://etherscan.io/tx/0xb73e45948f4aabd77ca888710d3685dd01f1c81d24361d4ea0e4b4899d490e1e)
---

## 2025-11-20 - 5

- **Date**: 2025-11-20
- **Project**: GANA Payment
- **Value Lost**: ~\$3,100,000
- **Chain**: BSC
- **BWC**:
  - **Broader Classification**: `BWC 10: Network & Consensus Evolution Attacks`
  - **Primary Classification**: `BWC 10.4.1: EIP-7702 Delegation Risks`
  - **Secondary Classification**: `BWC 1.2.2: Private Key Leakage`, `BWC 2.1.1: Missing Access Control`
- **Description**:
  - GANA Payment, a newly launched payment protocol on BSC, was exploited for \$3.1 million just nine days after launch.
  - **Root Cause**: The exploit originated from a compromised owner private key. The attacker used this key to authorize an EIP-7702 delegation to a malicious contract.
  - **The Exploit**: The malicious delegator contract acted as a middleman, allowing the attacker to bypass the `onlyEOA` (`tx.origin == msg.sender`) check on the staking contract. Because the transaction was an EIP-7702 transaction authorized by the owner, the staking contract perceived the calls as legitimate EOA interactions from the owner.
  - **Attack Flow**:
    1.  **Access**: Compromised the owner key.
    2.  **Delegation**: Transferred ownership to 8 different addresses, each authorizing the malicious EIP-7702 delegator.
    3.  **Manipulation**: The delegated code manipulated the `gana_Computility` reward rate to an astronomical value (10,000,000,000,000,000).
    4.  **Drain**: Systematically staked and unstaked funds through these accounts, draining the protocol.
  - **Aftermath**: \$2.1M was bridged to Ethereum, and ~\$1M was laundered through Tornado Cash on BSC.
- **References**:
  - [Rekt.news Analysis](https://rekt.news/gana-payment-rekt)
  - [Malicious Delegator](https://bscscan.com/address/0x7A44bD9C6095Ca7b2A6f62FE65b81924c6cAb067)
  - [Exploit Transaction](https://bscscan.com/tx/0x0a1fabbb536cf776335e2ded5ebf70f4c9601376e7265a127afe55305eff69ad)

---

## 2025-11-11 - 4

- **Date**: 2025-11-11
- **Project**: [@ImpermaxFinance](https://x.com/ImpermaxFinance)
- **Value Lost**: 380,000 \$
- **Chain**: base
- **BWC**:
  - **Broader Classification**: `BWC 6: Arithmetic & Numeric Vulnerabilities`
  - **Primary Classification**: `BWC 6.2: Precision Loss & Rounding Errors`
  - **Secondary Classification**: `BWC 2.1.1: Missing Access Control`
- **Description**:
  - The exploit was a sophisticated, multi-stage attack that combined a precision loss vulnerability in the liquidation mechanism with a missing access control on a fund allocation function.
  - **1. Precision Loss & State Manipulation:** The attacker repeatedly created tiny, "underwater" debt positions in a low-liquidity lending market (cbBTC). By calling the `restructureBadDebt()` function, a rounding error allowed them to incrementally drain the market's `totalBalance` one wei at a time. This manipulation drove the pool's `exchangeRate` to near zero.
  - **2. Triggering a Malicious State:** The attacker continued this process until the pool's `totalBalance` was exactly zero. This triggered a fallback condition in the code where the `exchangeRate` function returned a default, artificially high value of `1e18`. At this point, the attacker held nearly 100% of the pool's shares, acquired for a negligible cost.
  - **3. Missing Access Control & Fund Drain:** The attacker then exploited an unprotected `flashAllocate` function in a separate lending vault contract. This function, which lacked proper access control, was used to force the main cbBTC vault to deposit all its funds into the attacker's manipulated, malicious pool. Due to the artificially high exchange rate, the vault received almost no shares for its large deposit. The attacker, holding all the shares, then withdrew the vault's funds.
- **References**:
  - [@hklst4r X Alert](https://x.com/hklst4r/status/1988339762537918895)
  - [Impermax Post-Mortem](https://x.com/ImpermaxFinance/status/1988636882977116667)

---

## 2025-11-04 - 3

- **Date**: 2025-11-04
- **Project**: [@MoonwellDeFi](https://x.com/MoonwellDeFi)
- **Value Lost**: 1,000,000 \$
- **Chain**: base
- **BWC**:
  - **Broader Classification**: `BWC 4: Input & Data Validation Vulnerabilities`
  - **Primary Classification**: `BWC 4.2.1: Insufficient Oracle Validation`
- **Description**: Moonwell DeFi's wrsETH price anomaly on November 4, 2025, stemmed from a Chainlink oracle malfunction. The protocol's vulnerability was its failure to validate the data received from its price oracle, blindly trusting an erroneously high price for wrsETH. An exploiter was able to repeatedly borrow over 20 wstETH with only ~0.02 wrstETH flashloaned and deposited due to the faulty oracle that returned a wrstETH price of ~\$5.8M. The attacker profited by approximately 295 ETH (~\$1M).
- **References**:
  - [Attack Tx 1 ](https://basescan.org/tx/0x190a491c0ef095d5447d6d813dc8e2ec11a5710e189771c24527393a2beb05ac)
  - [@CertiKAlertX Alert ](https://x.com/CertiKAlert/status/1985620452992253973)

---

## 2025-11-03 - 2

- **Date**: 2025-11-03
- **Project**: Balancer Hack Side Story (Sonic Chain)
- **Value Lost**: ~\$3,000,000
- **Chain**: Sonic
- **BWC**:
  - **Broader Classification**: `BWC 4: Input & Data Validation Vulnerabilities`
  - **Primary Classification**: `BWC 4.5.1: Parser Differential / Inconsistent Validation`
  - **Secondary Classification**: `BWC 10.3: Cross-Protocol Interoperability Attacks`
- **Description**:
  - On November 3, 2025, following the Balancer V2 hack, the Sonic team attempted to contain the exploit by freezing the attacker's account on the L1 level. They set the attacker's native token balance to zero and replaced their code, intending to prevent them from paying gas to move funds.
  - **The Bypass (BWC 4.5.1):** The attacker bypassed this "transport layer" freeze by exploiting an inconsistency between the L1 gas requirements and the application-level logic. The Beets Staked Sonic (stS) token supported ERC-2612 `permit`, which allows for gasless approvals via off-chain signatures. The attacker signed a `permit` (which requires no gas) to authorize a secondary wallet, then used that secondary wallet to `transferFrom` and drain the "frozen" assets.
- **References**:
  - [OpenZeppelin Analysis](https://openzeppelin.com/security)

---

## 2025-11-03 - 1

- **Date**: 2025-11-03
- **Project**: Balancer V2 & Forks
- **Value Lost**: ~\$120,000,000
- **Chains**: Ethereum, Base, Polygon, Sonic, Arbitrum, Optimism, Berachain, Gnosis, Avalanche.
- **BWC**:
  - **Broader Classification**: `BWC 6: Arithmetic & Numeric Vulnerabilities`
  - **Primary Classification**: `BWC 6.2: Precision Loss & Rounding Errors`
  - **Secondary Classification**: `BWC 1.1.2: Permissioning & Censorship Risks`, `BWC 5.1.1: Front-Running`
- **Description**:
  - **Arithmetic Vulnerability**: The core of the exploit was a precision loss vulnerability within the `upscale` function in Balancer V2's Composable Stable Pools. This function would incorrectly round down when scaling factors were non-integer values. An attacker utilized the `batchSwap` feature to execute a three-stage attack: first, they precisely adjusted a token's balance to a rounding boundary; second, they performed swaps with crafted amounts, causing the rounding error to deflate the calculated price of the Balancer Pool Tokens (BPT); finally, they swapped assets back to the artificially cheapened BPT for a significant profit. This method was replicated across multiple chains where Balancer V2 or its forks were deployed.
  - **Censorship & Centralized Interventions**: Following the exploit, several chains took centralized action. Berachain validators halted the network for a hard fork; Sonic Labs froze the attacker's wallet; Gnosis froze affected pools and suspended its bridge; and Polygon validators reportedly censored the attacker's transactions.
  - **Front-Running**: A white-hat MEV bot operator successfully front-ran some of the attacker's transactions on Ethereum, recovering and returning approximately \$600,000.
- **References**:
  - [Attack Tx (Arbitrum)](https://arbiscan.io/tx/0x7da32ebc615d0f29a24cacf9d18254bea3a2c730084c690ee40238b1d8b55773)
  - [X Post by @Phalcon_xyz with attack breakdown](https://x.com/Phalcon_xyz/status/1985302779263643915)
  - [Berachain Foundation network halt tweet](https://x.com/berachain/status/1985288599152042101)

---

## 2025-10-15 - 5

- **Date**: 2025-10-15
- **Project**: ZKsync OS
- **Value Lost**: \$0 (Critical Vulnerability Found in Audit)
- **Chain**: ZKsync Era
- **BWC**:
  - **Broader Classification**: `BWC 8: Denial of Service (DoS) Vulnerabilities`
  - **Primary Classification**: `BWC 8.7: DoS via Return Data Bomb`
  - **Secondary Classification**: `BWC 1.1.1: Indispensable Intermediaries` (L1->L2 Queue Halt)
- **Description**:
  - A critical denial-of-service vulnerability was identified in the ZKsync OS execution environment. The system preallocated a fixed 128 MB buffer for `return_data` from external calls.
  - **The Exploit**: An attacker could craft a transaction that makes numerous external calls, returning large amounts of data. This would overflow the preallocated buffer (causing a panic) while remaining within the transaction's gas limit.
  - **Impact**: Crucially, if this panic occurred within an L1->L2 transaction (which are processed sequentially in a queue), it would permanently halt the entire L1->L2 transaction queue. Since the queue processing halts on a panic, no subsequent L1->L2 transactions could ever be processed, effectively bricking the bridge.
- **References**:
  - [OpenZeppelin Audit Report](https://blog.openzeppelin.com/zksync-os-audit-return-data-buffer)

---

## 2025-10-15 - 4

- **Date**: 2025-10-15
- **Project**: ZKsync OS
- **Value Lost**: \$0 (Critical Vulnerability Found in Audit)
- **Chain**: ZKsync Era
- **BWC**:
  - **Broader Classification**: `BWC 1: Ecosystem & Off-Chain Risks`
  - **Primary Classification**: `BWC 1.4.5: Client Consensus Bug`
  - **Secondary Classification**: `BWC 7.4.2: Compiler/Architecture Correctness`
- **Description**:
  - A critical non-determinism bug was identified in ZKsync OS during an audit. The issue stemmed from the use of architecture-dependent `usize` arithmetic in Rust.
  - **The Flaw**: `usize` is 32-bit on the ZK prover's RISC-V architecture but 64-bit on the sequencer's x86_64 architecture.
  - **The Exploit Vector**: An attacker could craft a transaction with calldata lengths close to `u32::MAX`.
    - On the **Sequencer (64-bit)**, the transaction processes successfully because the 64-bit integer does not overflow.
    - On the **Prover (32-bit)**, the same calculation overflows or panics.
  - **Impact**: This discrepancy effectively breaks the "Client Consensus." The sequencer accepts a block that the prover cannot prove. If such a block were committed, it would halt the L1 verification process, potentially freezing the entire ZKsync Era network.
- **References**:
  - [OpenZeppelin Audit Report](https://blog.openzeppelin.com/zksync-os-audit-usize-arithmetic)

---

## 2025-10-10 - 3

- **Date**: 2025-10-10
- **Project**: Binance
- **Value Lost**: Unknown
- **Chain**: N/A (Centralized Exchange)
- **BWC**:
  - **Broader Classification**: `BWC 1: Ecosystem & Off-Chain Risks`
  - **Primary Classification**: `BWC 1.1.6: Closed-Source Design`
- **Description**: During a market crash, a trader's pair trade (one long, one short position) was liquidated in a seemingly adversarial manner. Instead of partially liquidating both positions to maintain the hedge, the exchange's closed-source liquidation engine allegedly closed the profitable short position entirely, while leaving the long position fully exposed to the market crash, leading to its complete liquidation shortly after. This highlights the risks of trading on platforms with opaque, unauditable liquidation systems that may prioritize the house's profit over optimal position resolution for the user.
- **References**:
  - [X Post by @coinmamba](https://x.com/coinmamba/status/1976965643996938290)

---

## 2025-10-10 - 2

- **Date**: 2025-10-10
- **Project**: Multiple (Ethena Labs, Zerobase, Venus Protocol)
- **Value Lost**: ~\$400B in total liquidations
- **Chain**: Not Specified
- **BWC**:
  - **Broader Classification**: `BWC 1: Ecosystem & Off-Chain Risks`
  - **Primary Classification**: `BWC 1.5.5: Geopolitically-Induced Network Stress`
  - **Secondary Classification**: `BWC 5.4.1: Cascade Failure from Network Congestion`, `BWC 4.2.2: Oracle Manipulation`
- **Description**: The "Black Friday" event was a systemic failure triggered by a major geopolitical event (Trump's tariff announcement), which caused a crypto market plunge and led to a cascade of liquidations. The market crash led to mass liquidations, which in turn caused the depeg of USDe and the failure of the WBETH oracle, amplifying the crisis across multiple protocols. The Venus Protocol was directly impacted by an oracle failure when the price of WBETH depegged, highlighting the vulnerability of critical off-chain infrastructure during extreme market stress.
- **References**:
  - [X Alert by @GoPlusSecurity](https://x.com/GoPlusSecurity/status/1976893591772684528)

---

## 2025-10-04 - 1

- **Date**: 2025-10-04
- **Project**: Abracadabra (@MIM_Spell)
- **Value Lost**: ~\$1,700,000
- **Chain**: Ethereum Mainnet
- **BWC**:
  - **Broader Classification**: `BWC 3: Smart Contract Logic & State Manipulation`
  - **Primary Classification**: `BWC 3.2.5: Broken State Adjustment`
- **Description**: The root cause was a flawed implementation in the `cook` function, which allows users to execute multiple operations in a single transaction. The vulnerability occurred when an attacker combined two actions: `ACTION_BORROW`, which correctly set a `needsSolvencyCheck` flag to `true`, followed by `ACTION_CUSTOM`, which called an empty helper function that incorrectly returned a fresh status object, resetting the `needsSolvencyCheck` flag to `false`. This second action overwrote the critical security flag set by the first, effectively bypassing the solvency check and allowing the attacker to borrow millions in MIM tokens against zero collateral.
- **References**:
  - [Attack Tx](https://etherscan.io/tx/0x842aae91c89a9e5043e64af34f53dc66daf0f033ad8afbf35ef0c93f99a9e5e6)
  - [X Alert by @Phalcon_xyz](https://x.com/Phalcon_xyz/status/1974533451408986417)

---

## 2025-09-30 - 11

- **Date**: 2025-09-30
- **Project**: f(x) Protocol v2
- **Value Lost**: \$0 (Funds lock-up)
- **Chain**: Not Specified
- **BWC**:
  - **Broader Classification**: `BWC 8: Denial of Service (DoS) Vulnerabilities`
  - **Primary Classification**: `BWC 8.10: DoS via Forced Recursion`
- **Description**: A critical vulnerability was discovered during an audit that allowed an attacker to permanently lock user funds. The protocol used a recursive function to update user positions. An attacker could trigger around 150 insignificant liquidations, each creating a new node in a data structure. When a legitimate user later tried to manage their position, the recursive function would attempt to traverse this long chain of nodes, exceeding the EVM's call stack limit and causing the transaction to fail. This permanently prevented users from accessing their funds.
- **References**:
  - [OpenZeppelin Audit](https://www.openzeppelin.com/news/fx-v2-audit)

---

## 2025-09-30 - 10

- **Date**: 2025-09-30
- **Project**: Uniswap v4 Hooks (Conceptual)
- **Value Lost**: \$0 (Conceptual bug pattern)
- **Chain**: Not Specified
- **BWC**:
  - **Broader Classification**: `BWC 3: Smart Contract Logic & State Manipulation`
  - **Primary Classification**: `BWC 3.4.2: Flawed Incentive Structures`
- **Description**: A conceptual vulnerability in donation-based penalty mechanisms, as seen in a Uniswap v4 hook designed to penalize just-in-time (JIT) liquidity. The hook donates a penalized LP's fees to other in-range LPs. The flaw allows an attacker to bypass this penalty by using a secondary account to be the sole recipient of their primary account's "donated" penalty fees, effectively turning the penalty into a self-rebate.
- **References**:
  - [OpenZeppelin Audit](https://www.openzeppelin.com/news/openzeppelin-uniswap-hooks-v1.1.0-rc-2-audit#liquidity-penalty-can-be-circumvented-using-secondary-accounts)

---

## 2025-09-27 - 9

- **Date**: 2025-09-27
- **Project**: Cool
- **Value Lost**: \$100,500
- **Chain**: Mainnet
- **BWC**:
  - **Broader Classification**: `BWC 2: Access Control Vulnerabilities`
  - **Primary Classification**: `BWC 2.1.1: Missing Access Control`
  - **Secondary Classification**: `BWC 5.1.1: Front-Running`
- **Description**: A proxy contract was upgraded to a new implementation named "Cool". This new implementation contained a `withdrawToken()` function that lacked proper access control. A transaction calling this unprotected function was subsequently front-run by an MEV bot, leading to the loss of all funds.
- **References**:
  - [Exploit Tx](https://etherscan.io/tx/0xb2fe540482667d464586aeb9522887a2b3f8bf07ecd9c0873f3a7adc6fa67e04)
  - [X Alert: @TenArmorAlert](https://x.com/TenArmorAlert/status/1970015815979171983)

---

## 2025-09-23 - 8

- **Date**: 2025-09-23
- **Project**: MYX Finance
- **Value Lost**: ~\$73,000,000 (from liquidations)
- **Chain**: Not Specified
- **BWC**:
  - **Broader Classification**: `BWC 5: Economic & Game-Theoretic Vulnerabilities`
  - **Primary Classification**: `BWC 5.2.1: Price Manipulation`
  - **Secondary Classification**: `BWC 1.3.8: Sybil Attacks`, `BWC 1.2.3: Insider Threat`
- **Description**: A coordinated, multi-vector attack involving massive price manipulation and a large-scale Sybil attack. Attackers used 100 coordinated wallets to claim \$170 million in an airdrop, securing a large supply of the token. They then generated billions in artificial volume (wash trading) and engineered a short squeeze that liquidated over \$73 million from retail traders. The project's official response appeared to defend the Sybil attack, suggesting potential insider complicity.
- **References**:
  - [Rekt News - Parabolic Mirage](https://rekt.news/parabolic-mirage)

---

## 2025-09-23 - 7

- **Date**: 2025-09-23
- **Project**: Base Sequencer Debate
- **Value Lost**: \$0 (Ecosystem Risk)
- **Chain**: N/A (Off-Chain)
- **BWC**:
  - **Broader Classification**: `BWC 11: Privacy & Regulatory Attack Vectors`
  - **Primary Classification**: `BWC 11.2.2: Government Overreach`
- **Description**: This incident represents a case of **Regulatory Weaponization**, where ecosystem participants called for regulatory action against a competitor (Base) over technical disagreements about its sequencer design. The core of the issue involved intentionally mischaracterizing a novel technology (a transaction sequencer) by equivocating it with a known regulated entity (a traditional exchange's matching engine) in an attempt to invite SEC scrutiny.
- **References**:
  - [Discussion between @danrobinson and @MaxResnick1 on X](https://x.com/danrobinson/status/1970557854190051463)

---

## 2025-09-13 - 6

- **Date**: 2025-09-13
- **Project**: JUDAOGlobal (Tentative)
- **Value Lost**: \$20,000,000
- **Chain**: Polygon
- **BWC**:
  - **Broader Classification**: `BWC 3: Smart Contract Logic & State Manipulation`
  - **Primary Classification**: `BWC 3.2.1: Improper Initialization`
  - **Secondary Classification**: `BWC 2.2.2: Misconfigured Proxy`
- **Description**: A developer executed a faulty proxy upgrade, setting an incorrect implementation contract for a vault holding 77 million POL tokens from a presale. Crucially, the developer forgot to call the `initialize` function on the new implementation. This failure to re-initialize the contract's state effectively wiped out all admin and upgrade privileges, leaving the contract ownerless and the \$20 million in funds permanently locked and inaccessible.
- **References**:
  - [Locked Contract](https://polygonscan.com/address/0x7D341e757f893e1a13D40370d0F6065ca9c4777E)
  - Flagged by: [@YannickCrypto](https://x.com/YannickCrypto/status/1966836235365687723)

---

## 2025-09-12 - 5

- **Date**: 2025-09-12
- **Project**: Shibarium Bridge
- **Value Lost**: ~\$3,957,000
- **Chain**: Ethereum Mainnet, Shibarium
- **BWC**:
  - **Broader Classification**: `BWC 1: Ecosystem & Off-Chain Risks`
  - **Primary Classification**: `BWC 1.2.2: Private Key Leakage`
  - **Secondary Classification**: `BWC 1.1.1: Centralization Risks`
- **Description**: A sophisticated attack compromised the Shibarium PoS bridge, resulting in the unauthorized withdrawal of multiple assets. The attacker gained control over the signing keys for 10 of the 12 network validators, allowing them to forge malicious checkpoint/exit proofs and approve fraudulent transactions. The root cause was a widespread compromise of validator keys. The incident highlighted significant centralization risks, as a majority of the validators were "internal" (operated by the core team) and their key compromise led to a catastrophic failure of the bridge's security model.
- **References**:
  - [Shibarium Bridge Security Update](https://blog.shib.io/shibarium-bridge-security-update/)
  - [Attack Tx](https://etherscan.io/tx/0xe882a83afb92d6070b848ef025ae699ec043b7c2f31b21d2a08c94306f9b817e)

---

## 2025-09-10 - 4

- **Date**: 2025-09-10
- **Project**: NPM Supply Chain Attack
- **Value Lost**: ~\$50
- **Chain**: Multiple (ETH, BTC, SOL, TRX)
- **BWC**:
  - **Broader Classification**: `BWC 1: Ecosystem & Off-Chain Risks`
  - **Primary Classification**: `BWC 1.4.4: Supply Chain Attacks`
  - **Secondary Classification**: `BWC 1.3.1: Social Engineering Exploits`
- **Description**: A widespread supply chain attack was identified where an attacker compromised a reputable developer's NPM account via a targeted phishing email. The attacker then injected a malicious, obfuscated payload into popular NPM packages. This payload was designed to compromise front-end applications and browser wallets by intercepting network requests and silently swapping user crypto addresses with the attacker's address during transactions.
- **References**:
  - [SlowMist Team Alert](https://x.com/SlowMist_Team/status/1965236512448282713)

---

## 2025-09-10 - 3

- **Date**: 2025-09-10
- **Project**: Reth (Ethereum Client)
- **Value Lost**: \$0
- **Chain**: Ethereum Mainnet
- **BWC**:
  - **Broader Classification**: `BWC 1: Ecosystem & Off-Chain Risks`
  - **Primary Classification**: `BWC 1.4.5: Client Consensus Bug`
- **Description**: A bug in the Reth Ethereum client's state root computation caused multiple nodes running this client to stall on the Ethereum mainnet. The flaw was not in a smart contract but in the client software itself, which failed to correctly compute the state root according to the protocol rules. This led to a consensus failure where the affected nodes could not agree on the state of the chain with the rest of the network, requiring operators to manually intervene.
- **References**:
  - [Announcement from Reth core developer Georgios Konstantopoulos](https://x.com/gakonst/status/1962888853682798971)

---

## 2025-09-05 - 2

- **Date**: 2025-09-05
- **Project**: Uniswap vs. Bancor
- **Value Lost**: \$Millions in legal fees
- **Chain**: Not Applicable (Legal/Off-Chain)
- **BWC**:
  - **Broader Classification**: `BWC 11: Privacy & Regulatory Attack Vectors`
  - **Primary Classification**: `BWC 11.2.1: Patent Trolling`
- **Description**: This incident is not a technical exploit but a legal one. The Bancor team filed a patent infringement lawsuit against Uniswap, claiming Uniswap's Automated Market Maker (AMM) violates their patent. This represents a case of **Regulatory Weaponization**, where the legal system is used to attack a competitor, stifle open-source innovation, and extract value, posing a systemic risk to the ecosystem.
- **References**:
  - [@haydenzadams founder Uniswap ](https://x.com/haydenzadams/status/1963878856391094291)
  - [@danrobinson patner Paradigm](https://x.com/danrobinson/status/1963722176458350737)

---

## 2025-09-02 - 1

- **Date**: 2025-09-02
- **Project**: [@bunni_xyz](https://x.com/bunni_xyz)
- **Value Lost**: \$ 8,400,000
- **Chain**: Ethereum, Unichain
- **BWC**:
  - **Broader Classification**: `BWC 6: Arithmetic & Numeric Vulnerabilities`
  - **Primary Classification**: `BWC 6.2: Precision Loss & Rounding Errors`
  - **Secondary Classification**: `BWC 5.2.1: Price Manipulation`
- **Description**:
  - The exploit's root cause was a rounding error in the smart contract logic that updated a pool's idle balance during withdrawals. While the rounding direction was safe for single operations, it became exploitable when combined in a specific sequence.
  - The attacker used a flash loan to perform a large swap, manipulating the price and draining most of one asset from a pool. They then executed a series of 44 tiny withdrawals. Each withdrawal exploited the rounding error, causing the protocol's tracked total liquidity to decrease disproportionately more than the tiny amount actually withdrawn.
  - After corrupting the pool's internal accounting, the attacker executed a final large swap and reverse swap at the highly manipulated price, draining approximately \$8.4M from the affected pools on Ethereum and Unichain.
- **References**:
  - [Bunni Post-Mortem Report](https://bunni.pro/blog/09-04-2025-exploit-post-mortem)
  - [X Announcement of Incident](https://x.com/bunni_xyz/status/1962766519391170988)

---

## 2025-08-25 - 5

- **Date**: 2025-08-25
- **Project**: Panoptic
- **Value Lost**: \$0 (White-hat rescue of over \$4M)
- **Chain**: Ethereum, Base, Unichain
- **BWC**:
  - **Broader Classification**: `BWC 7: Low-Level & EVM-Specific Vulnerabilities`
  - **Primary Classification**: `BWC 7.3.5: Insecure Cryptographic Construction`
  - **Secondary Classification**: `BWC 4.1.1: Insufficient Input Validation`
- **Description**:
  - A critical vulnerability was discovered in Panoptic's "position fingerprinting" mechanism, which allowed an attacker to bypass all solvency checks and drain funds. The flaw stemmed from a combination of an insecure cryptographic construction and insufficient input validation.
  - **Cryptographic Weakness**: The position fingerprint was generated by XORing the `keccak256` hashes of individual position IDs. Using XOR as a combiner is cryptographically insecure, as it is vulnerable to collision attacks (e.g., via Gaussian elimination).
  - **Insufficient Input Validation**: The protocol failed to validate that the user-supplied position IDs in a list were legitimate or even owned by the caller.
  - **Attack Path**: An attacker could craft a fraudulent list of arbitrary, non-existent positions that produced the same XOR fingerprint as a real, high-collateral position. By submitting this spoofed list, they could trick the contract into believing they were solvent, allowing them to withdraw collateral and drain funds.
  - The vulnerability was responsibly disclosed by a researcher from Cantina, leading to a coordinated white-hat rescue operation that successfully secured over 98% of at-risk funds, preventing any loss.
- **References**:
  - [Cantina Post-Mortem: Inside the \$4M Panoptic Rescue](https://cantina.xyz/blog/panoptic-cantina-whitehat-rescue)

---

## 2025-08-24 - 4

- **Date**: 2025-08-24
- **Project**: Unverified Staking Contract
- **Value Lost**: ~\$85,000
- **Chain**: BSC
- **BWC**:
  - **Broader Classification**: `BWC 10: Network & Consensus Evolution Attacks`
  - **Primary Classification**: `BWC 10.4.1: EIP-7702 Delegation Risks`
  - **Secondary Classification**: `BWC 5.2.1: Price Manipulation`
- **Description**:
  - An unverified staking contract on BSC was exploited for ~\$85k. The victim contract used the "EOA only" (`tx.origin == msg.sender`) check to protect its stake function from flashloan-based price manipulation.
  - **The Exploit**: The attacker deployed a malicious contract and authorized its delegation to an EOA using a 7702-type transaction. The EOA transferred ~13.9 BNB tokens to itself, triggering arbitrary smart contract logic while ensuring that future `tx.origin == msg.sender` checks pass.
  - **Attack Flow**:
    1.  **Flashloan & Pump**: In the fallback function, the malicious contract flashloaned $3.5M BSC-USD, bought POT tokens from the PancakeSwap BSC-USD/POT pool to inflate the price, then staked ~220k POT at the inflated price.
    2.  **Dump**: The attacker swapped the remaining POT tokens back to BSC-USD tokens to repay the flashloan and almost reset the BSC-USD/POT price.
    3.  **Profit**: In a subsequent transaction, the attacker unstaked and received 3.3M POT tokens (versus 220k staked) due to the inflated recorded value.
- **References**:
  - [Unverified staking contract](https://bscscan.com/address/0x0aeb8c4a449e1f712676692ef8948d8c952feb53)
  - [Exploit Transaction](https://bscscan.com/tx/0x8a7c96521ac64fc33d8d8ceecdea9c1da9c72148c4399905c38a07ee47c3f36f)

---

## 2025-08-24 - 3

- **Date**: 2025-08-24
- **Project**: ShibaSwap Treasure Finder
- **Value Lost**: \$27,000
- **Chain**: Mainnet
- **BWC**:
  - **Broader Classification**: `BWC 5: Economic & Game-Theoretic Vulnerabilities`
  - **Primary Classification**: `BWC 5.1.3: Sandwich Attacks`
  - **Secondary Classification**: `BWC 10.4.1: EIP-7702 Delegation Risks`
- **Description**: The `convert()` function in the ShibaSwap: Treasure Finder contract lacked slippage protection, enabling exploitation through sandwich attacks. Additionally, its `onlyEOA()` modifier, intended to prevent contract calls, was bypassed using an EIP-7702 account, demonstrating a protocol upgrade-induced vulnerability.
- **References**:
  - [Exploit Tx 1](https://etherscan.io/tx/0x5c17e81b5b976cff66933bc4082ac3e9b21355a455d1864ae5f8ce6d069ea8e7)
  - Flagged by: [@TenArmorAlert](https://x.com/TenArmorAlert/status/1959805512184140043)

---

## 2025-08-23 - 2

- **Date**: 2025-08-23
- **Project**: RansomVault Hacker
- **Value Lost**: \$90,000
- **Chain**: Ethereum Mainnet
- **BWC**:
  - **Broader Classification**: `BWC 5: Economic & Game-Theoretic Vulnerabilities`
  - **Primary Classification**: `BWC 5.1.1: Front-Running`
- **Description**: This incident involves a hacker's (Hacker A) ransomware contract being exploited by another attacker (Hacker B), likely an MEV bot. The `withdrawETH` function was protected by a password that was passed as a cleartext argument in the transaction data. When Hacker A tried to withdraw the ransom, their transaction sat in the public mempool. Hacker B scanned the mempool, extracted the password, and submitted their own transaction with a higher gas fee to front-run Hacker A and steal the funds.
- **References**:
  - [Exploit Tx](https://etherscan.io/tx/0x0474ae70a59d34e37fc85e9910ea9b7f71dff0256d0269d2247217c38f9bca5e)

---

## 2025-08-13 - 1

- **Date**: 2025-08-13
- **Project**: Coinbase
- **Value Lost**: \$550,000
- **Chain**: Mainnet
- **BWC**:
  - **Broader Classification**: `BWC 2: Access Control Vulnerabilities`
  - **Primary Classification**: `BWC 2.2.1: Unsafe Token Approvals`
- **Description**: Coinbase's fee-receiver wallet lost approximately \$550,000 due to mistakenly granting ERC-20 allowances to 0x's Mainnet Settler, a permissionless execution contract. This was not a hack but a configuration error that handed a sophisticated MEV bot the approval to drain dozens of token types from Coinbase's treasury, as anyone can call the Settler contract.
- **References**:
  - [Exploit Tx](https://etherscan.io/tx/0x4f59b88f96873486a5ae1b519bd29e16abcf0118334bad1218e300fd4e95bed4)
  - Flagged by: [@deeberiroz](https://x.com/deeberiroz/status/1955718986894549344)

---

## 2025-07-28 - 5

- **Date**: 2025-07-28
- **Project**: SuperRare
- **Value Lost**: \$730,000
- **Chain**: Mainnet
- **BWC**:
  - **Broader Classification**: `BWC 2: Access Control Vulnerabilities`
  - **Primary Classification**: `BWC 2.1.1: Missing Access Control`
- **Description**: The core of the vulnerability was a logically flawed `require` statement intended to enforce access control. The code `require((msg.sender != owner() || msg.sender != address(0xc2...)), "Not authorized...");` always evaluates to true for any caller, because an address cannot be two different values simultaneously. This logical error rendered the authorization check completely ineffective, making it functionally missing.
- **References**:
  - [Vulnerable Implementation](https://etherscan.io/address/0xffb512b9176d527c5d32189c3e310ed4ab2bb9ec)

---

## 2025-07-15 - 4

- **Date**: 2025-07-15
- **Project**: Arcadia
- **Value Lost**: \$3,600,000
- **Chain**: Base
- **BWC**:
  - **Broader Classification**: `BWC 2: Access Control Vulnerabilities`
  - **Primary Classification**: `BWC 2.2.4: Composable Arbitrary Calls`
- **Description**: The attacker exploited a missing validation vulnerability in the Asset Manager contracts. By supplying malicious calldata to a rebalancing function, the attacker tricked the Asset Manager into making an arbitrary call to a victim's Arcadia Account. Since the victim had authorized the Asset Manager, this call was successful, allowing the attacker to impersonate the Asset Manager and drain the victim's funds.
- **References**:
  - [Postmortem](https://arcadiafinance.notion.site/Arcadia-Post-Mortem-14-07-2025-23104482afa780fdb291cd3f41b7fc99)

---

## 2025-07-09 - 3

- **Date**: 2025-07-09
- **Project**: GMX
- **Value Lost**: \$42,000,000
- **Chain**: Arbitrum
- **BWC**:
  - **Broader Classification**: `BWC 3: Smart Contract Logic & State Manipulation`
  - **Primary Classification**: `BWC 3.1.4: Composable Reentrancy`
- **Description**: The GMX protocol was exploited via a sophisticated composable reentrancy attack. The vulnerability was in the `PositionManager.executeDecreaseOrder()` function, which made an external call (an ETH refund) to the attacker's contract. The attacker's contract then re-entered the GMX protocol, opening a large leveraged position before the initial transaction was complete. This manipulation artificially inflated the Assets Under Management (AUM) of the GLP pool, allowing the attacker to redeem their own GLP tokens at a much higher price.
- **References**:
  - [Slowmist Analysis](https://slowmist.medium.com/inside-the-gmx-hack-42-million-vanishes-in-an-instant-6e42adbdead0)

---

## 2025-07-09 - 2

- **Date**: 2025-07-09
- **Project**: ZKSwap
- **Value Lost**: \$5,000,000
- **Chain**: N/A
- **BWC**:
  - **Broader Classification**: `BWC 4: Input & Data Validation Vulnerabilities`
  - **Primary Classification**: `BWC 4.3.1: Missing Signature Validation`
- **Description**: The `verifyExitProof()` function contained a hardcoded `return true;` statement, which effectively disabled the cryptographic verification of withdrawal proofs. An attacker activated the emergency "Exodus Mode" and repeatedly called the `exit()` function with fabricated proofs, which the contract accepted due to the skipped verification, allowing the attacker to drain funds.
- **References**:
  - [Postmortem](https://blockaid.io/blog/how-zkswaps-5m-exploit-couldve-been-prevented-with-onchain-monitoring)

---

## 2025-07-02 - 1

- **Date**: 2025-07-02
- **Project**: Quickswap
- **Value Lost**: Unknown
- **Chain**: Polygon
- **BWC**:
  - **Broader Classification**: `BWC 10: Network & Consensus Evolution Attacks`
  - **Primary Classification**: `BWC 10.4.1: EIP-7702 Delegation Risks`
- **Description**: The contract implemented an `onlyEOA()` modifier to prevent contract-based calls (like flash loans). An attacker leveraged an EIP-7702 transaction to bypass this check. EIP-7702 allows a contract to execute a call while setting the `msg.sender` to the EOA that signed the transaction. This made the `onlyEOA()` check return `true`, tricking the contract into believing the caller was a standard user while allowing the attacker to execute complex contract logic.
- **References**:
  - [Vulnerable Address](https://polygonscan.com/address/0x44574d53474729f2949a7ecfb68b0641cfda4aa8)

---

## 2025-06-20 - 3

- **Date**: 2025-06-20
- **Project**: Unidentified Staking Contract
- **Value Lost**: ~\$32,000
- **Chain**: Mainnet
- **BWC**:
  - **Broader Classification**: `BWC 7: Low-Level & EVM-Specific Vulnerabilities`
  - **Primary Classification**: `BWC 7.1: Unchecked Return Values`
  - **Secondary Classification**: `BWC 3.3.4: Weird ERC20 Behaviors`
- **Description**: The staking contract was exploited due to its failure to check the return value of an external call to a legacy Compound cToken (cUSDC). An attacker called the deposit function, but the underlying `cUSDC.transferFrom` call failed and returned `false` instead of reverting. The victim contract did not validate this boolean response and proceeded as if the deposit were successful, incorrectly updating the attacker's internal balance. The attacker was then able to withdraw real funds from the contract based on their unbacked, phantom deposit.
- **References**:
  - [Exploit Tx](https://etherscan.io/tx/a02b159fb438c8f0fb2a8d90bc70d8b2273d06b55920b26f637cab072b7a0e3e)
  - Flagged by: [@deeberiroz](https://x.com/deeberiroz/status/1947213692220710950)

---

## 2025-06-17 - 2

- **Date**: 2025-06-17
- **Project**: MetaPool (mpETH)
- **Value Lost**: \$227,785
- **Chain**: Mainnet
- **BWC**:
  - **Broader Classification**: `BWC 3: Smart Contract Logic & State Manipulation`
  - **Primary Classification**: `BWC 3.2.7: Broken Invariant via Function Overriding`
- **Description**: The mpETH staking contract, which inherited from OpenZeppelin's `ERC4626Upgradeable`, was exploited due to a broken security invariant. The parent contract's security relied on an internal `_deposit` function to check that assets were received before minting shares. The mpETH contract overrode this internal function and moved the asset receipt check into its own public `deposit` function. However, the team failed to account for the inherited public `mint` function, which now called the new, check-less `_deposit` function, allowing an attacker to mint shares for free.
- **References**:
  - [X Alert](https://x.com/OpenZeppelin/status/1953111764536561867)
  - [Attack Tx (MEV Bot)](https://etherscan.io/tx/0x4f43fc6d674e85f7d306debb4a3d48e7688c2fe5a6332dd9ad57558a15c86ef9)

---

## 2025-06-02 - 1

- **Date**: 2025-06-02
- **Project**: #FPC
- **Value Lost**: \$4,700,000
- **Chain**: BSC
- **BWC**:
  - **Broader Classification**: `BWC 5: Economic & Game-Theoretic Vulnerabilities`
  - **Primary Classification**: `BWC 5.2.1: Price Manipulation`
  - **Secondary Classification**: `BWC 3.3.2: Fee-on-Transfer & Rebase Accounting Issues`
- **Description**: The protocol was exploited through a price manipulation attack that capitalized on the token's non-standard burn-on-transfer mechanism. The FPC token was designed to burn a portion of its own tokens directly from the liquidity pool during every sell transaction. An attacker used a flash loan to execute a large buy, drastically inflating the token's price, and then immediately sold the tokens. The flawed burn logic, combined with the artificially high price, allowed the attacker to drain the pool's liquidity.
- **References**:
  - [Attack Tx](https://bscscan.com/tx/0x3a9dd216fb6314c013fa8c4f85bfbbe0ed0a73209f54c57c1aab02ba989f5937)

---

## 2025-05-28 - 4

- **Date**: 2025-05-28
- **Project**: Cork Protocol
- **Value Lost**: ~\$13,200,000 (3,761 wstETH)
- **Chain**: Ethereum Mainnet
- **BWC**:
  - **Broader Classification**: `BWC 2: Access Control Vulnerabilities`
  - **Primary Classification**: `BWC 2.2.4: Composable Arbitrary Calls`
  - **Secondary Classification**: `BWC 5.2.1: Price Manipulation`
- **Description**:
  - The protocol was drained via a highly sophisticated, two-vector exploit targeting complex interactions between its market automation and a custom Uniswap V4 hook.
  - **1. Price Manipulation (Setup):** The attacker first exploited the market's rollover pricing logic. By executing a single trade in a low-volume period just before market expiry, they skewed the volume-weighted price calculation. This allowed them to purchase a massive number of `Cover Tokens` for a near-zero cost after the rollover completed.
  - **2. Arbitrary Call via Malicious Hook (Drain):** The primary vulnerability was an access control flaw in Cork's hook integration. The attacker deployed their own malicious contract that also acted as a Uniswap hook. This malicious hook was able to interact with Cork's hook in a way that bypassed authorization checks, which were absent because Cork had integrated an older version of a Uniswap periphery contract before an explicit authorization feature was added upstream. This bypass allowed the attacker to illegitimately withdraw `Depeg Swaps`.
  - With both the cheaply acquired `Cover Tokens` and the stolen `Depeg Swaps`, the attacker was able to drain the Liquidity Vault of its assets.
- **References**:
  - [Cork Protocol Exploit Post-Mortem](https://www.cork.tech/blog/post-mortem)
  - [Exploiter Contract 1](https://etherscan.io/address/0x6e54115de254805365c2d9c8a2eeb9b52e54668f)
  - [Exploiter Contract 2](https://etherscan.io/address/0x9af3dce0813fd7428c47f57a39da2f6dd7c9bb09)

---

## 2025-05-23 - 3

- **Date**: 2025-05-23
- **Project**: Mango Markets Exploiter Trial
- **Value Lost**: \$0 (Legal Precedent established, related to a \$110M exploit)
- **Chain**: N/A (Legal/Off-Chain)
- **BWC**:
  - **Broader Classification**: `BWC 11: Privacy & Regulatory Attack Vectors`
  - **Primary Classification**: `BWC 11.2.3: "Code is Law" Defense Exploitation`
- **Description**: In a landmark ruling, U.S. District Judge Arun Subramanian vacated the fraud and manipulation convictions of Avraham Eisenberg. The judge determined that the evidence was insufficient to prove Eisenberg made "false representations" to Mango Markets, reasoning that as a decentralized, permissionless smart contract, the protocol could not be deceived. This decision validated the "code is law" defense in a US court, highlighting a critical regulatory vulnerability.
- **References**:
  - [Court Ruling Document: Case 1:23-cr-00010-AS, Document 220](https://assets.bwbx.io/documents/users/iqjWHBFdfxIU/rmmTMWKeWe9s/v0)

---

## 2025-05-18 - 2

- **Date**: 2025-05-18
- **Project**: KRC/BUSD AMM Pool
- **Value Lost**: Not Specified
- **Chain**: BSC
- **BWC**:
  - **Broader Classification**: `BWC 3: Smart Contract Logic & State Manipulation`
  - **Primary Classification**: `BWC 3.3.2: Fee-on-Transfer & Rebase Accounting Issues`
  - **Secondary Classification**: `BWC 5.2.1: Price Manipulation`
- **Description**: The KRC/BUSD AMM pool was drained by exploiting a deflationary (fee-on-transfer) mechanism in the KRC token. The token's contract burned 9% of the transfer amount from the recipient's balance if the recipient was the AMM pool. This burn was invisible to the AMM's accounting, causing a desynchronization where the pool's actual KRC balance became lower than its tracked reserves. The attacker repeatedly triggered this burn, manipulating the internal price before executing a final swap to drain the remaining BUSD.
- **References**:
  - [Exploit Tx](https://bscscan.com/tx/0x78f242dee5b8e15a43d23d76bce827f39eb3ac54b44edcd327c5d63de3848daf)

---

## 2025-05-11 - 1

- **Date**: 2025-05-11
- **Project**: MBU Token
- **Value Lost**: \$2,000,000
- **Chain**: BSC
- **BWC**:
  - **Broader Classification**: `BWC 6: Arithmetic & Numeric Vulnerabilities`
  - **Primary Classification**: `BWC 6.5: Inconsistent Scaling Bugs`
- **Description**: The MBU token contract was exploited due to an inconsistent scaling bug in its `deposit` function. The contract failed to properly normalize the decimal precision of different tokens when performing calculations. This allowed an attacker to deposit a small amount of BNB and receive a vastly disproportionate number of MBU tokens in return, which were then swapped for a profit of \$2 million.
- **References**:
  - [Exploit Tx](https://bscscan.com/tx/0x2a65254b41b42f39331a0bcc9f893518d6b106e80d9a476b8ca3816325f4a150)
  - [@openzeppelin Postmortem](https://blog.openzeppelin.com/the-notorious-bug-digest-3)

---

## 2025-04-24 - 1

- **Date**: 2025-04-24
- **Project**: Zora Airdrop / 0x
- **Value Lost**: \$128,000
- **Chain**: Base
- **BWC**:
  - **Broader Classification**: `BWC 2: Access Control Vulnerabilities`
  - **Primary Classification**: `BWC 2.2.1: Unsafe Token Approvals`
- **Description**: Zora's airdrop process allocated claimable \$ZORA tokens to the 0x Settler contract, a permissionless contract designed to execute arbitrary transactions. An attacker exploited this by calling the Settler contract and instructing it to claim the tokens and send them to the attacker's own address. The root cause was the allocation of a claim (an unsafe approval) to a contract that was not designed to securely hold assets on its own behalf.
- **References**:
  - [Exploit Tx](https://basescan.org/tx/0xf71a96fe83f4c182da0c3011a0541713e966a186a5157fd37ec825a9a99deda6)
  - [Threesigma Postmortem](https://threesigma.xyz/blog/exploit/zora-airdrop-exploit-analysis)

---

## 2025-03-25 - 2

- **Date**: 2025-03-25
- **Project**: Magic Internet Money (@MIM_Spell)
- **Value Lost**: ~\$12,900,000
- **Chain**: Arbitrum
- **BWC**:
  - **Broader Classification**: `BWC 3: Smart Contract Logic & State Manipulation`
  - **Primary Classification**: `BWC 3.2.5: Broken State Adjustment`
- **Description**: The vulnerability was in the integration between the `CauldronV4` and `RouterOrder` contracts. When an attacker's position was liquidated, the collateral held within the `RouterOrder` was correctly transferred to the liquidator. However, the `RouterOrder` contract failed to update its internal state variable (`inputAmount`) that tracked this collateral. This created an inconsistent state where the `Cauldron` contract's solvency check still considered the liquidated assets as valid collateral, allowing the attacker to borrow against this "phantom collateral."
- **References**:
  - [Liquidate and Borrow Again Tx](https://arbiscan.io/tx/0x5416a5f23af22bd1c6c92dbbdb382da681884ed2be07f5c0903ab2241)

---

## 2025-03-05 - 1

- **Date**: 2025-03-05
- **Project**: 1inch (Fusion V1)
- **Value Lost**: ~\$10,000,000 (Majority returned for a bounty)
- **Chain**: Ethereum Mainnet
- **BWC**:
  - **Broader Classification**: `BWC 7: Low-Level & EVM-Specific Vulnerabilities`
  - **Primary Classification**: `BWC 7.2: Unsafe Storage & Memory Handling`
  - **Secondary Classification**: `BWC 6.1: Integer Overflow & Underflow`
- **Description**:
  - The exploit targeted a critical calldata corruption vulnerability in the deprecated 1inch Settlement (Fusion V1) contract, which was written in low-level Yul.
  - The core of the vulnerability was an integer underflow in an assembly block that calculated a memory offset. By providing a crafted, extremely large `interactionLength` value in the order data, an attacker could cause the offset calculation to underflow.
  - This allowed the attacker to overwrite a different, controlled part of the calldata being assembled in memory. Specifically, they overwrote the legitimate `resolver` address in the order's suffix data with the victim's address (a market maker).
  - This tricked the Settlement contract into making a privileged callback to the victim's contract, triggering a function that drained the market maker's funds. The majority of funds were later returned by the attacker in exchange for a bounty.
- **References**:
  - [Attack Tx](https://etherscan.io/tx/0x04975648e0db631b0620759ca934861830472678dae82b4bed493f1e1e3ed03a)
  - [1inch Post-Mortem](https://blog.decurity.io/yul-calldata-corruption-1inch-postmortem-a7ea7a53bfd9)

---

## 2025-02-23 - 1

- **Date**: 2025-02-23
- **Project**: [ZeroLend](https://x.com/zerolendxyz)
- **Value Lost**: ~\$371,000 (Initial Exploit) + Undetermined ongoing extraction from new depositors
- **Chain**: Base
- **BWC**:
  - **Broader Classification**: `BWC 5: Economic & Game-Theoretic Vulnerabilities`
  - **Primary Classification**: `BWC 5.2.1: Price Manipulation`
  - **Secondary Classification**: `BWC 1.1.7: User Disempowerment` & Extractive Design ("Zombie Market" / Cover-up)
- **Description**:
  - **Note**: This incident occurred in 2025 but was publicly exposed by Rekt.news in Jan 2026 after a 10-month cover-up.
  - ZeroLend was drained of ~\$371k on this date, but the team maintained a "Zombie Market" for months, attributing withdrawal failures to "high utilization" or UI bugs while keeping the deposit function active.
  - **Vulnerability**: The attacker utilized PT-LBTC (a Pendle Principal Token) as collateral. By manipulating the price of this illiquid derivative on the lending market, the attacker was able to borrow ~3.92 real LBTC against it, effectively draining the pool. This attack vector was identical to the Ionic Money exploit that occurred just 18 days prior (Feb 4, 2025).
  - **Cover-up & Ongoing Extraction**: ZeroLend did not disclose the loss. On-chain analysis revealed that a Gnosis Safe (created two months post-exploit) utilizing Gelato automation has been systematically withdrawing liquidity provided by new, unsuspecting depositors, effectively turning the broken protocol into a trap for users.
  - **Status** (as of Jan 2026): The ZERO token has been delisted from major exchanges, GitHub activity has ceased, and the protocol remains largely abandoned by developers despite the frontend remaining accessible.
- **References**:
  - [Rekt News: Zero To Lend](https://rekt.news/zero-to-lend)
  - [Attacker Address (Base)](https://basescan.org/address/0x218c572b1ab6065d74bebcb708a3f523d14f7719)

---

## 2025-01-13 - 1

- **Date**: 2025-01-13
- **Project**: UniLend
- **Value Lost**: ~\$197,000
- **Chain**: EVM
- **BWC**:
  - **Broader Classification**: `BWC 3: Smart Contract Logic & State Manipulation`
  - **Primary Classification**: `BWC 3.2.5: Broken State Adjustment`
- **Description**: The attacker exploited a critical flaw in the `redeemUnderlying` function's health factor calculation due to an incorrect order of operations. When a user redeemed assets, the contract would first burn their LP shares and _then_ perform the health check. However, the check incorrectly used the contract's _current_, pre-withdrawal token balance (which was still high) against the user's _new_, post-burn share balance (which was low). This mismatch led to a massively inflated health factor calculation, allowing an undercollateralized position to appear safe and enabling the attacker to drain funds.
- **References**:
  - [Attack Tx](https://etherscan.io/tx/0x44037ffc0993327176975e08789b71c1058318f48ddeff25890a577d6555b6ba)
  - [SlowMist Analysis](https://slowmist.medium.com/analysis-of-the-unilend-hack-90022fa35a54)

---

_It’s important to emphasize that the intent behind this content is not to criticize or blame the affected projects but to provide objective overviews that serve as educational material for the community to learn from and better protect projects in the future._
