# 2016 EVM Contract Vulnerability Incidents Classification & Analysis.

This database uses the [BWC](../BWC/BWC.md) to classify Contract Vulnerability Incidents. Note off-chain issues have been excluded they're the most prevalent and resulted in more values lost. Humans remains to be the weakest point human stupidity or ingenuity(depending on how you look at it) could be infinite. It's unfeasible to track it.

---

## 2016-06-17 - The DAO Hack

- **Date**: 2016-06-17
- **Project**: The DAO
- **Value Lost**: \$60,000,000 (approx. 3.6M ETH)
- **Chain**: Ethereum Mainnet
- **BWC**:
  - Broader Classification: BWC 3: Smart Contract Logic & State Manipulation
  - Primary Classification: BWC 3.1.1: Standard Reentrancy
- **Description**:
  - The DAO smart contract contained a critical reentrancy vulnerability in its `splitDAO` function.
  - The contract logic performed an external call to send Ether to the user *before* updating the user's internal balance (or share count).
  - The attacker deployed a malicious contract with a fallback function. When The DAO contract sent ETH to this malicious contract, the fallback function triggered, recursively calling the `splitDAO` function again.
  - Since the state (balance) hadn't been updated yet, the subsequent calls were also successful, allowing the attacker to drain funds repeatedly in a single transaction stack.
  - This event led to the controversial hard fork that created Ethereum (ETH) and Ethereum Classic (ETC).

### Vulnerable Code Pattern

```solidity
// Simplified representation of the vulnerability
mapping(address => uint) public balances;

function withdraw() public {
    uint amount = balances[msg.sender];
    
    // Check
    require(amount > 0);

    // Interaction (Vulnerability: External call before state update)
    (bool sent, ) = msg.sender.call{value: amount}("");
    require(sent, "Failed to send Ether");

    // Effect
    balances[msg.sender] = 0;
}
```

- **References**:
  - [Chainlink - Reentrancy Attacks and The DAO Hack](https://blog.chain.link/reentrancy-attacks-and-the-dao-hack/)
  - [Phil Daian - Analysis of the DAO exploit](https://hackingdistributed.com/2016/06/18/analysis-of-the-dao-exploit/)

---

It’s important to emphasize that the intent behind this content is not to criticize or blame the affected projects but to provide objective overviews that serve as educational material for the community to learn from and better protect projects in the future.
