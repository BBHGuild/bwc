# 2026 EVM Contract Vulnerability Incidents Classification & Analysis.

This database uses the [BWC](../BWC/BWC.md) to classify Contract Vulnerability Incidents. Note off-chain issues have been excluded they're the most prevalent and resulted in more values lost. Humans remains to be the weakest point human stupidity or ingenuity(depending on how you look at it) could be infinite. It's unfeasible to track it.

---

## 2026-02-02 - 14

- **Date**: 2026-02-02
- **Project**: [Matcha Meta (SwapNet)](https://x.com/matchametaxyz)
- **Value Lost**: ~\$16,800,000
- **Chain**: Base
- **BWC**:
  - **Broader Classification**: `BWC 2: Access Control Vulnerabilities`
  - **Primary Classification**: `BWC 2.2.3: Untrusted Arbitrary Calls`
  - **Secondary Classification**: `BWC 2.2.1: Unsafe Token Approvals`
- **Description**:
  - Matcha Meta's SwapNet router was exploited for ~\$16.8M (later analysis suggests ~\$17M) due to an arbitrary call vulnerability in a closed-source contract.
  - **Vulnerability**: The SwapNet router failed to validate inputs properly, allowing unauthorized arbitrary calls. The attacker used this to force the contract to call `transferFrom` on various tokens, draining funds from users who had granted infinite approvals to the router.
  - **Attack Flow**:
    1. **Reconnaissance**: The attacker identified users with infinite approvals to the SwapNet router.
    2. **Execution**: The attacker exploited the arbitrary call flaw to inject calls to `token.transferFrom(victim, attacker, amount)`, bypassing the router's intended logic.
    3. **Laundering**: Funds were swapped for USDC (~\$10.5M) and then ~3,655 ETH on Base, which was subsequently bridged to Ethereum Mainnet.
- **References**:
  - [BlockSec Analysis](https://blocksec.com/blog/17m-closed-source-smart-contract-exploit-arbitrary-call-swapnet-aperture)
  - [News Article (TimesCrypto)](https://timescrypto.com/cryptonews/blockchain/matcha-meta-exploit-drained-16-8m-via-compromised-router/article-21194/)
  - [Matcha Meta X](https://x.com/matchametaxyz)
  - [Attack Transaction (Basescan)](https://basescan.org/tx/0xc15df1d131e98d24aa0f107a67e33e66cf2ea27903338cc437a3665b6404dd57)

---

## 2026-01-26 - 13

- **Date**: 2026-01-26
- **Project**: Individual Swap Incident (Illiquid Pool)
- **Value Lost**: ~\$140,000
- **Chain**: Ethereum
- **BWC**:
  - **Broader Classification**: `BWC 5: Economic & Game-Theoretic Vulnerabilities`
  - **Primary Classification**: `BWC 5.3.1: Lack of Slippage Control`
  - **Secondary Classification**: `BWC 1.3.7: Flawed Off-Chain Infrastructure (Potential UI/Routing Failure)`
- **Description**:
  - An individual user suffered a catastrophic loss of ~\$140,000 in a single swap transaction, receiving only ~0.09 EUR in return.
  - **Vulnerability**: The transaction was executed through a liquidity pool with insufficient depth (illiquid). The user's transaction likely lacked a proper `amountOutMin` (slippage protection) parameter, or the interface used failed to warn/prevent the routing through the empty pool.
  - **Execution**: The user attempted to swap a high-value amount of tokens. Due to the lack of liquidity in the selected pool, the trade suffered ~100% price impact. Without a slippage revert, the transaction executed, effectively donating the funds to the pool's liquidity providers or back-running MEV bots.
- **References**:
  - [Community Alert (deebeez)](https://x.com/deeberiroz/status/2015763113325252857)
  - [Swap Transaction (Etherscan)](https://etherscan.io/tx/0xa4fdac0e82003fc66af56f6cefb736c95fe6d4d5a690e46a63c80b93a5b8c808)

---

## 2026-01-11 - 12

- **Date**: 2026-01-11 (Estimated based on report timing)
- **Project**: MetaverseToken (MT)
- **Value Lost**: ~\$37,000
- **Chain**: BSC
- **BWC**:
  - **Broader Classification**: `BWC 5: Economic & Game-Theoretic Vulnerabilities`
  - **Primary Classification**: `BWC 5.2.1: Price Manipulation`
- **Description**:
  - TenArmor detected a suspicious attack involving the MetaverseToken (MT) on BSC, resulting in a loss of approximately \$37,000.
  - **Vulnerability**: Limited details were provided, but the incident has been classified as price manipulation based on the detected on-chain behavior.
  - **Attack Flow**: The specific mechanics involved an interaction with the MT contract that drained funds, likely via market manipulation or a flaw in how the token handles price/value calculations.
- **References**:
  - [TenArmor Alert](https://x.com/TenArmorAlert/status/2010630024274010460)
  - [Attack Transaction (BscScan)](https://bscscan.com/tx/0xc758ab15fd51e713ff8b4184620610a1ac809be06ec374305c32d3b244256a64)

---

## 2026-01-01 - 11

- **Date**: 2026-01-01
- **Project**: [Valinity](https://x.com/valinitydefi)
- **Value Lost**: ~\$63,000
- **Chain**: Ethereum
- **BWC**:
  - **Broader Classification**: `BWC 3: Smart Contract Logic & State Manipulation`
  - **Primary Classification**: `BWC 3.4.2: Flawed Incentive Structures (Flawed Rebalance Logic)`
  - **Secondary Classification**: `BWC 5.2.1: Price Manipulation (Spot Price Dependency)`
- **Description**:
  - Valinity was exploited for ~\$63k due to a business logic flaw in its rebalancing mechanism.
  - **Vulnerability**: The `acquireByLTVDisparity` function, intended to rebalance the synthetic `VY` token holdings based on LTV ratios and Uniswap V3 spot prices, was publicly callable. Crucially, the logic was flawed as it was hardcoded to execute swaps of `VY` into a liquidity pool that held negligible liquidity (~\$106 USDC).
  - **Attack Flow**:
    1. **Price Manipulation**: The attacker swapped USDC for PAXG to artificially increase the PAXG price on Uniswap V3.
    2. **Forced Dump**: The attacker called the public `acquireByLTVDisparity` function. Due to the inflated PAXG price (which altered the LTV calculation), the contract logic triggered a sell-off of `VY` tokens into the illiquid pool.
    3. **Arbitrage/Borrow**: The attacker bought the dumped `VY` tokens cheaply from the pool and used them as collateral to borrow hard assets (ETH, BTC, PAXG) from the protocol, exiting with the profit.
  - **Note**: The protocol paused contracts following the exploit.
- **References**:
  - [TenArmor Alert](https://x.com/TenArmorAlert/status/2007644832815018351)
  - [Weilin Li Analysis](https://x.com/hklst4r/status/2007366523464093850)
  - [Attack Transaction (Etherscan)](https://etherscan.io/tx/0x7f1406435172b8d8675dec95a7f6aa89d10b7ca008150de8742f7fa824e3395c)

---

## 2026-01-01 - 10

- **Date**: 2026-01-01
- **Project**: PRXVTai
- **Value Lost**: ~\$97,000
- **Chain**: Base
- **BWC**:
  - **Broader Classification**: `BWC 3: Smart Contract Logic & State Manipulation`
  - **Primary Classification**: `BWC 3.4.2: Flawed Incentive Structures (Reward Accounting Mismatch)`
  - **Secondary Classification**: `BWC 2.3.1: Missing Validation in Callbacks (Missing Token Transfer Hooks)`
- **Description**:
  - PRXVTai was exploited for ~\$97k on Base due to a flaw in its staking reward mechanics.
  - **Vulnerability**: The `PRXVTStaking` contract minted a **transferable** receipt token (`stPRXVT`) representing staked `AgentTokenV2`. However, the contract failed to implement the necessary hooks (e.g., `_beforeTokenTransfer`) to update reward accounting state variables when these receipt tokens were transferred between users.
  - **Attack Flow**:
    1. **Staking/Transfer**: The attacker likely staked tokens to receive `stPRXVT` or transferred `stPRXVT` between wallets.
    2. **Accounting Desync**: Because the reward logic (`earned()`) calculated rewards based on the *current* balance but the "reward debt" (or `userRewardPerTokenPaid`) was not synchronized during transfers, the system failed to correctly track how long the tokens were held by specific addresses.
    3. **Drain**: This allowed the attacker to claim inflated rewards, which were then bridged to Ethereum.
- **References**:
  - [CertiK Alert](https://x.com/CertiKAlert/status/2006653156927889666)
  - [Attack Transaction (Basescan)](https://basescan.org/tx/0x88610208c00f5d5ca234e45205a01199c87cb859f881e8b35297cba8325a5494)

---

## 2026-01-20 - 9

- **Date**: 2026-01-20
- **Project**: [SynapLogic](https://x.com/SynapLogic)
- **Value Lost**: ~\$88,000
- **Chain**: Base
- **BWC**:
  - **Broader Classification**: `BWC 3: Smart Contract Logic & State Manipulation`
  - **Primary Classification**: `BWC 3.2.8: Faulty Array & List Handling (Duplicate Entries)`
  - **Secondary Classification**: `BWC 3.4.2: Flawed Incentive Structures`
- **Description**:
  - SynapLogic on Base was exploited for ~\$88k due to a logic flaw in its referral system.
  - **Vulnerability**: The `swapExactTokensForETHSupportingFeeOnTransferTokens` function accepted a user-supplied array `address[] refBy` to distribute referral rewards (10% per referee) but failed to check for duplicate addresses or cap the total payout percentage.
  - **Attack Flow**:
    1. **Duplicate Injection**: The attacker called the function with the `refBy` array containing their own address repeated 31 times (e.g., `[self, self, ... x31]`).
    2. **Reward Multiplication**: The contract calculated the reward as 31 * 10% = 310% of the input value.
    3. **Drain**: The contract paid out the inflated reward in ETH/USDC from its reserves to the attacker, draining the purchasing contract.
  - **Note**: The attacker also minted SYP tokens during the process, but these were locked in vesting and could not be sold. The profit was derived solely from draining the contract's liquidity backing the referral payouts.
- **References**:
  - [SlowMist Alert](https://x.com/SlowMist_Team/status/2013448818365473101)
  - [Weilin Li Analysis](https://x.com/hklst4r/status/2013440353844461979)
  - [Attack Transaction (Basescan)](https://basescan.org/tx/0xc54c00046364b6e889db18c73beee9b81df6b5ca822b6d262b3d30cdf376c4b1)

---

## 2026-01-20 - 8

- **Date**: 2026-01-20
- **Project**: [MakinaFi](https://x.com/makinafi)
- **Value Lost**: ~\$4,130,000 (1,299 ETH)
- **Chain**: Ethereum
- **BWC**:
  - **Broader Classification**: `BWC 5: Economic & Game-Theoretic Vulnerabilities`
  - **Primary Classification**: `BWC 5.2.1: Price Manipulation (Asset Inflation)`
  - **Secondary Classification**: `BWC 4.2.2: Oracle Manipulation (Internal Accounting as Oracle)`
- **Description**:
  - MakinaFi's DUSD Machine was exploited for ~\$4.13M due to a vulnerability in its internal accounting logic.
  - **Vulnerability**: The protocol used a specific **Weiroll script** to calculate the value of its positions (specifically in the MIM-3CRV Curve pool) to determine the Assets Under Management (AUM). This script relied on spot values that could be manipulated.
  - **Attack Flow**:
    1. **Manipulation**: The attacker used large flash loans to inflate the value of the MIM-3CRV pool and the associated rewards.
    2. **AUM Update**: The attacker called `updateTotalAum`, which ran the vulnerable script. This recorded an artificially inflated value for the protocol's holdings, consequently spiking the price of the DUSD token (which is derived from AUM).
    3. **Extraction**: The attacker utilized the DUSD/USDC Curve pool (which relies on this internal price) to swap DUSD for USDC at the inflated rate.
  - **Execution Twist**: The original attacker (0x2F93...) deployed the exploit contract but was **front-run by an MEV bot** (0x935...). The MEV bot replicated the attack logic and secured the funds.
  - **Status**: The protocol is paused (Recovery Mode). The team is negotiating with the MEV builder and a Rocket Pool validator who unintentionally received a portion of the funds to recover the assets.
- **References**:
  - [CertiK Incident Analysis](https://www.certik.com/resources/blog/makina-incident-analysis)
  - [MakinaFi Official Update](https://x.com/makinafi/status/2014079031423930710)
  - [Attack Tx](https://etherscan.io/tx/0x569733b8016ef9418f0b6bde8c14224d9e759e79301499908ecbcd956a0651f5)

---

## 2026-01-21 - 7

- **Date**: 2026-01-21
- **Project**: [SagaEVM](https://x.com/Sagaxyz__) (Saga Protocol Chainlet)
- **Value Lost**: ~\$6.8M bridged to Ethereum)
- **Chain**: SagaEVM / Ethereum
- **BWC**:
  - **Broader Classification**: `BWC 3: Smart Contract Logic & State Manipulation`
  - **Primary Classification**: `BWC 3.2.5: Broken State Adjustment (Infinite Mint)`
  - **Secondary Classification**: `BWC 10.3: Cross-Protocol Interoperability Attacks (IBC Message Validation)`
- **Description**:
  - SagaEVM, an EVM-compatible chainlet of the Saga Protocol, was exploited for approximately \$7 million, resulting in a chain halt at block height 6593800. The exploit targeted the ecosystem's stablecoin, Saga Dollar (\$D).
  - **Vulnerability**: The flaw existed within the chain's precompile bridge contract responsible for handling Inter-Blockchain Communication (IBC). The system failed to properly validate custom payloads, allowing a malicious helper contract to bypass collateral checks and mint infinite \$D tokens "out of thin air."
  - **Attack Flow**:
    1. **Injection**: The attacker deployed a malicious helper contract (0x7D69...) on SagaEVM.
    2. **Infinite Mint**: The helper contract sent crafted IBC messages to the precompile bridge, triggering the unauthorized minting of ~\$7M in \$D.
    3. **Extraction**: The attacker bridged the illicitly minted \$D to Ethereum Mainnet via the Squid Router.
    4. **Laundering**: On Ethereum, the funds were swapped via 1inch and KyberSwap into ETH  (2,000+ ETH), USDC, yUSD, and tBTC. A portion (\$800k) was deposited into Uniswap V4 liquidity positions (NFTs).
  - **Status**: SagaEVM remains paused. The Saga SSC mainnet and other chainlets were unaffected. The \$D token depegged ~25% following the inflation event.
  - **Addresses**:
    - Attacker (Saga/ETH): `0x2044697623AfA31459642708c83f04eCeF8C6ECB`
    - Malicious Helper Contract (Saga): `0x7D69E4376535cf8c1E367418919209f70358581E`
- **References**:
  - [Official Saga Incident Update](https://medium.com/sagaxyz/sagaevm-security-incident-investigation-update-29a1d2a6b0cd)
  - [Analysis Tweet (Weilin Li)](https://x.com/hklst4r/status/2014016362054639943)
  - [Attacker Address (Etherscan)](https://etherscan.io/address/0x2044697623afa31459642708c83f04ecef8c6ecb)
  - [Loss Transaction (Etherscan)](https://etherscan.io/tx/0x6aff59e800dc219ff0d1614b3dc512e7a07159197b2a6a26969a9ca25c3e33b4)
  - [QuillAudits Analysis Tweet](https://x.com/PeckShieldAlert/status/2011069662377980147)

---

## 2026-01-12 - 6

- **Date**: 2026-01-12
- **Project**: [YO Protocol](https://x.com/yield)
- **Value Lost**: ~\$3,710,000 (Covered by Protocol Treasury)
- **Chain**: Ethereum
- **BWC**:
  - **Broader Classification**: `BWC 5: Economic & Game-Theoretic Vulnerabilities`
  - **Primary Classification**: `BWC 5.3.1: Lack of Slippage Control`
  - **Secondary Classification**: `BWC 1.3.7: Flawed Off-Chain Infrastructure`
- **Description**:
  - YO Protocol suffered a loss of ~\$3.71M during a routine rebalancing operation due to a misconfigured automated swap. The protocol's "Automated Harvesting System" attempted to swap ~\$3.84M worth of stkGHO for USDC but received only ~\$112k, resulting in a 97% loss.
  - **Vulnerability**: The incident was an operational failure rather than a smart contract exploit. The vault operator (keeper bot) submitted a transaction to the Odos Router with an effectively disabled slippage parameter (set to `17,872,058`). The on-chain harvesting logic checked for "execution drift" but failed to validate the sanity of the initial output quote.
  - **Execution**: The aggregator, following the permissive instructions, routed the massive trade through fragmented and illiquid Uniswap V4 pools (and others including Curve/Balancer). The route utilized pools with extreme fee tiers (up to 88%) and insufficient liquidity, vaporizing the funds into the hands of LPs positioned in these pools.
  - **Incident Response**: The YO Protocol team utilized their multisig to backstop the loss, purchasing ~3.71M GHO via CoW Swap (which offers MEV protection) and redepositing it into the vault. An on-chain message was sent to the LPs requesting a return of funds in exchange for a 10% bounty.
- **References**:
  - [Rekt News: Yo](https://rekt.news/yo-protocols-slippage-bomb)

---

## 2026-01-12 - 5

- **Date**: 2026-01-12
- **Project**: dHEDGE
- **Value Lost**: \$0 (Critical Vulnerability Patched; >\$10M Risk)
- **Chain**: Ethereum / Optimism
- **BWC**:
  - **Broader Classification**: `BWC 4: Input & Data Validation Vulnerabilities`
  - **Primary Classification**: `BWC 4.5.1: Parser Differential / Inconsistent Validation`
  - **Secondary Classification**: `BWC 10.3: Cross-Protocol Interoperability Attacks`
- **Description**:
  - A critical vulnerability was identified in dHEDGE’s 1inch integration guard that could have allowed a malicious pool manager to bypass slippage protection and drain over \$10M in user funds.
  - **Vulnerability**: The issue stemmed from a **Parser Differential** between the dHEDGE contract guard and the 1inch Router. The dHEDGE guard calculated slippage based on the `token` input parameter provided in the function call. However, the 1inch `unoswap` function for Uniswap V3 pools ignores this `token` input entirely, determining the swap direction (ZeroForOne) solely based on a specific bitmask within the `pool` uint256 identifier.
  - **Attack Flow**:
    1. **Parser Deception**: A malicious manager provides a worthless "Fake Token" as the `token` input. The dHEDGE guard calculates slippage logic based on this Fake Token (which the attacker controls to ensure checks pass).
    2. **Execution Divergence**: The manager constructs the `pool` identifier such that the 1inch Router executes a swap of the *real* pool assets (e.g., USDT) -> Fake Token, ignoring the `token` input provided in step 1.
    3. **Bypass**: Because the dHEDGE guard logic assumes the Fake Token is the source asset being swapped, it fails to validate the slippage/outflow of the real USDT, allowing the manager to drain the pool.
  - **Incident Response**: The vulnerability was disclosed by a whitehat researcher following an audit contest where it was initially missed. The protocol developers confirmed the severity and patched the issue before any exploitation occurred.
- **References**:
  - [Vulnerability Disclosure Write-up](https://x.com/s4muraii77/status/2012140371938070888)

---

## 2026-01-08 - 4

- **Date**: 2026-01-08
- **Project**: [TMXTribe](https://x.com/TMXdex)
- **Value Lost**: ~\$1,400,000
- **Chain**: Arbitrum
- **BWC**:
  - **Broader Classification**: `BWC 3: Smart Contract Logic & State Manipulation`
  - **Primary Classification**: `BWC 3.4.2: Flawed Incentive Structures`
  - **Secondary Classification**: `BWC 1.1.2: Barriers to Verification (The Specialist Gap)`
- **Description**:
  - TMXTribe, a GMX fork, was exploited for approximately \$1.4M over a 36-hour period due to flawed logic in its unverified contracts. The attack involved a loop of minting and staking TMX LP tokens using USDT, swapping the deposited USDT for USDG (the protocol's stablecoin), unstaking, and draining the acquired USDG.
  - **Vulnerability**: The specific root cause was a logic bug in the LP staking and swapping mechanics that failed to account for this extraction loop. The contracts were unverified, hiding the exact flaw from independent review.
  - **Incident Response**: Despite the exploit continuing for 36 hours, the team failed to pause the protocol. On-chain activity showed the team deploying and upgrading contracts during the attack but taking no effective action to stop the drainage.
  - **Addresses**:
    - Exploiter 1: `0x763a67E4418278f84c04383071fC00165C112661`
    - Exploiter 2: `0x16Ed3AFf3255FDDB44dAa73B4dE06f0c2E15288d`
- **References**:
  - [Rekt News Postmortem](https://rekt.news/tmztribe-rekt)
  - [Exploiter Address (Arbiscan)](https://arbiscan.io/address/0x763a67e4418278f84c04383071fc00165c112661)

---

## 2026-01-08 - 3

- **Date**: 2026-01-08
- **Project**: [Truebit](https://x.com/Truebitprotocol)
- **Value Lost**: ~\$26,600,000
- **Chain**: Ethereum
- **BWC**:
  - **Broader Classification**: `BWC 6: Arithmetic & Numeric Vulnerabilities`
  - **Primary Classification**: `BWC 6.1: Integer Overflow & Underflow`
- **Description**:
  - Truebit was exploited for approximately \$26.6M due to an integer overflow vulnerability. A malicious actor was able to mint tokens for 0 ETH and subsequently swap them for 8,535 ETH.
  - **Vulnerability**: The `getPurchasePrice()` function, responsible for calculating the minting cost, relied on an internal calculation where intermediate values (`v9 + v12`) overflowed `2^256`. This overflow caused the price calculation to wrap around and result in zero (after division), allowing the attacker to mint TRU tokens for free.
  - **Attack Flow**: The attacker called `AdminUpgradeabilityProxy.buyTRU()` to mint 240M tokens for 0 ETH, then called `sellTRU()` to drain ETH from the protocol. This process was repeated with increasing amounts.
  - **Addresses**:
    - Exploiter 1: `0x6C8EC8f14bE7C01672d31CFa5f2CEfeAB2562b50`
    - Exploiter 2: `0xc0454E545a7A715c6D3627f77bEd376a05182FBc`
    - Protocol Contract: `0x764C64b2A09b09Acb100B80d8c505Aa6a0302EF2`
- **References**:
  - [CertiK Alert](https://x.com/CertiKAlert/status/2009627269451715005)
  - [Exploiter 1 Address](https://etherscan.io/address/0x6C8EC8f14bE7C01672d31CFa5f2CEfeAB2562b50)
  - [Attack Transaction](https://etherscan.io/tx/0xcd4755645595094a8ab984d0db7e3b4aabde72a5c87c4f176a030629c47fb014)

---

## 2026-01-06 - 2

- **Date**: 2026-01-06
- **Project**: [IPOR Fusion (USDC Optimizer on Arbitrum)](https://x.com/ipor_io)
- **Value Lost**: ~\$336,000
- **Chain**: Arbitrum
- **BWC**:
  - **Broader Classification**: `BWC 10: Network & Consensus Evolution Attacks`
  - **Primary Classification**: `BWC 10.4.1: EIP-7702 Delegation Risks`
  - **Secondary Classification**: `BWC 4.1.1: Insufficient Input Validation`
- **Description**:
  - A legacy IPOR Fusion vault (USDC on Arbitrum) was exploited for ~\$336k. The exploit leveraged a "perfect storm" of a legacy vulnerability and a new attack vector introduced by EIP-7702.
  - **Vulnerability**: The incident was caused by the combination of two factors:
    1.  **Legacy Logic Error**: The specific legacy vault lacked strict validation for "fuses" (logic modules) in its `configureInstantWithdrawalFuses` function, trusting that only verified addresses would add them.
    2.  **EIP-7702 Delegation Hijack**: An administrator account (`0xd8a1...`) had delegated its execution to a helper contract (`0xa3cc...`) via EIP-7702. This helper contract contained a vulnerability allowing arbitrary calls.
  - **Attack Flow**:
    1.  **Identity Hijacking**: The attacker exploited the arbitrary call vulnerability in the delegated helper contract to force the admin's EOA to call the Vault.
    2.  **Malicious Fuse Injection**: Acting as the admin, the attacker added a malicious "fuse" to the vault.
    3.  **Drain**: The attacker triggered `instantWithdraw`, causing the vault to execute the malicious fuse code and transfer assets to the attacker.
  - **Incident Response**: IPOR Labs acknowledged the exploit, confirmed it was isolated to this single legacy vault due to its unique configuration, and stated that the IPOR DAO would cover the shortfall from the treasury.
- **References**:
  - [IPOR Official Post-Mortem](https://blog.ipor.io/post-mortem-ipor-usdc-optimizer-arbitrum-vault-exploit-aff11fd01b62)
  - [Malicious Fuse Injection Tx](https://arbiscan.io/tx/0x238b4e619158432ff5ceb279cfea38007d048af4f59901c7af2efcf32e9671b6)
  - [IPOR Security Update Tweet](https://x.com/ipor_io/status/2008728627190321480)

---

## 2026-01-03 - 1

- **Date**: 2026-01-03
- **Project**: Flow Blockchain / deBridge / LayerZero
- **Value Lost**: Undetermined (Significant breakdown in cross-chain accounting; Specific transactions of ~\$200k+ cited)
- **Chain**: Flow, Cross-chain
- **BWC**:
  - **Broader Classification**: `BWC 1: Ecosystem & Off-Chain Risks`
  - **Primary:** `BWC 1.1.6: Unverifiable Outcomes` (State finality was revoked by decree, not consensus rules).
  - **Secondary:** `BWC 1.1.1: Indispensable Intermediaries` (The validators acted as "Landlords" deciding who retains assets, failing the Walkaway Test).
- **Description**:
  - Following an undisclosed exploit, the Flow Blockchain team executed a mandatory chain rollback to revert the network state. However, the team allegedly failed to coordinate this action with critical bridge providers (e.g., deBridge, LayerZero), leading to a catastrophic state desynchronization between Flow and the broader ecosystem.
  - **Centralization Risk:** The decision to unilaterally roll back the chain highlights the risks of centralized governance in Layer-1 blockchains, where "finality" can be revoked by the operator.
  - **Bridge Mismatch (Double Spend & Loss):** The rollback created a temporal paradox for cross-chain transactions processed during the rollback window:
    1.  **Bridged Out (Double Spend):** Users who bridged funds *out* of Flow had their assets released on the destination chain. The rollback restored their balances on Flow to the pre-transfer state, effectively doubling their funds.
    2.  **Bridged In (Total Loss):** Users who bridged funds *into* Flow had their assets locked on the source chain. The rollback erased the crediting transaction on Flow, leaving the users with no assets on either chain.
- **References**:
  - [Flow Blockchain Announcement](https://x.com/flow_blockchain/status/2005095181755052120)
  - [deBridge/Community Alert](https://x.com/flow_blockchain/status/2005058237272584680)
  
---

It’s important to emphasize that the intent behind this content is not to criticize or blame the affected projects but to provide objective overviews that serve as educational material for the community to learn from and better protect projects in the future.
