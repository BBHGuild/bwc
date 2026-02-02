# 2017 EVM Contract Vulnerability Incidents Classification & Analysis.

This database uses the [BWC](../BWC/BWC.md) to classify Contract Vulnerability Incidents. Note off-chain issues have been excluded they're the most prevalent and resulted in more values lost. Humans remains to be the weakest point human stupidity or ingenuity(depending on how you look at it) could be infinite. It's unfeasible to track it.

---

## 2017-11-06 - Parity Multi-Sig Library Self-Destruct

- **Date**: 2017-11-06
- **Project**: Parity
- **Value Lost**: \$300,000,000 (approx. 513,774 ETH frozen)
- **Chain**: Ethereum Mainnet
- **BWC**:
  - Broader Classification: BWC 3: Smart Contract Logic & State Manipulation
  - Primary Classification: BWC 3.2.1: Improper Initialization
- **Description**:
  - The Parity multi-signature wallets relied on a single shared library contract for their logic (acting as the implementation for many light proxies).
  - This library contract was deployed but left uninitialized, meaning it had no owner.
  - A user (`devops199`) was able to call the `initWallet` function on the library contract itself, effectively claiming ownership of the standard library.
  - The user then triggered the `kill()` function, which executed `selfdestruct`.
  - The destruction of the library contract rendered all dependent multi-sig wallets non-functional, permanently freezing the funds held within them.
- **References**:
  - [I accidentally killed it and evaporated $300 million](https://medium.com/cybermiles/i-accidentally-killed-it-and-evaporated-300-million-6b975dc1f76b)
  - [Parity Security Alert](https://parity.io/blog/security-alert-2/)

---

It’s important to emphasize that the intent behind this content is not to criticize or blame the affected projects but to provide objective overviews that serve as educational material for the community to learn from and better protect projects in the future.
