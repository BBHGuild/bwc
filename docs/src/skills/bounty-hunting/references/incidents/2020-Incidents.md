# 2020 EVM Contract Vulnerability Incidents Classification & Analysis.

This database uses the [BWC](../../../../README.md) to classify Contract Vulnerability Incidents. Note off-chain issues have been excluded they're the most prevalent and resulted in more values lost. Humans remains to be the weakest point human stupidity or ingenuity(depending on how you look at it) could be infinite. It's unfeasible to track it.

---

## 2020-03-12 - MakerDAO Black Thursday

- **Date**: 2020-03-12
- **Project**: MakerDAO
- **Value Lost**: \$8,300,000
- **Chain**: Ethereum Mainnet
- **BWC**:
  - Broader Classification: BWC 5: Economic & Game-Theoretic Vulnerabilities, BWC 1: Ecosystem & Off-Chain Risks
  - Primary Classification: BWC 5.4.1: Cascade Failure from Network Congestion, BWC 1.3.7: Flawed Off-Chain Infrastructure
- **Description**:
  - On "Black Thursday," a massive ETH price drop caused extreme network congestion and gas price spikes on Ethereum.
  - This led to a cascade of failures in the MakerDAO system:
    1. **Oracle Lag:** Price oracles failed to update in a timely manner due to the high gas fees.
    2. **Mass Liquidations:** When the oracles finally updated with a much lower price, a large number of collateralized debt positions (CDPs) were liquidated simultaneously.
    3. **Keeper Failure:** The reference keeper software, used by most auction bidders, was not designed to handle the extreme gas prices and failed to submit bids.
    4. **Zero-Bid Auctions:** The lack of competing bids allowed a few liquidators to win collateral auctions with bids of 0 DAI, extracting over \$8.3 million worth of ETH for free.
  - This incident was a systemic failure caused by the protocol's inability to handle extreme market volatility and network congestion, coupled with a critical failure in its off-chain keeper infrastructure.
- **References**:
  - [ConsenSys - Black Thursday: The Day DeFi Died (For a Bit)](https://consensys.net/blog/news/black-thursday-the-day-defi-died-for-a-bit/)
  - [MakerDAO Posrmortem](https://insights.glassnode.com/what-really-happened-to-makerdao/)

---

It’s important to emphasize that the intent behind this content is not to criticize or blame the affected projects but to provide objective overviews that serve as educational material for the community to learn from and better protect projects in the future.
