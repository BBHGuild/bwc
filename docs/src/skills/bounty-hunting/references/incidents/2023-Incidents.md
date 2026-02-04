# 2023 EVM Contract Vulnerability Incidents Classification & Analysis.

This database uses the [BWC](../../../../README.md) to classify Contract Vulnerability Incidents. Note off-chain issues have been excluded they're the most prevalent and resulted in more values lost. Humans remains to be the weakest point human stupidity or ingenuity(depending on how you look at it) could be infinite. It's unfeasible to track it.

---

## 2023-06-22 - 1

- **Date**: 2023-06-22 (Disclosure Date)
- **Project**: General EIP-2612 Implementations
- **Value Lost**: \$0 (Vulnerability Disclosure)
- **Chain**: EVM
- **BWC**:
  - **Broader Classification**: `BWC 8: Denial of Service (DoS) Vulnerabilities`
  - **Primary Classification**: `BWC 8.11: DoS via Front-Running (Griefing)`
  - **Secondary Classification**: `BWC 5.1.1: Front-Running`
- **Description**:
  - Security researchers at Trust Security detailed a Denial of Service vector known as "Permit Griefing" affecting contracts integrating EIP-2612.
  - **The Flaw:** Many contracts implement a "multicall" or "permit-then-execute" flow where `permit()` is called to set token allowances before executing a trade or deposit. The contracts typically expect the `permit()` call to succeed and will revert the entire transaction if it fails.
  - **The Exploit:** Because the permit signature is visible in the mempool, an attacker can front-run the user's transaction and submit the `permit()` call themselves. The attacker's transaction succeeds, consuming the user's nonce and granting the approval. However, when the user's transaction subsequently attempts to call `permit()` with the same (now used) nonce, it reverts. Although the approval exists, the user's intent (the trade or deposit) is blocked.
- **References**:
  - [Trust Security: Permission Denied](https://www.trust-security.xyz/post/permission-denied)
---

## 2023-12-06 - 1

- **Date**: 2023-12-06
- **Project**: TIME Contract ERC2771 Exploit
- **Value Lost**: \$212,000
- **Chain**: Ethereum Mainnet
- **BWC**:
  - Broader Classification: BWC 4: Input & Data Validation Vulnerabilities
  - Primary Classification: BWC 4.4.1: ERC-2771 + Multicall
- **Description**:
  - The TIME contract was exploited due to a vulnerability in its `multicall` function, which was set as a trusted forwarder for ERC-2771 meta-transactions. The issue stemmed from the `multicall` function not complying with the ERC-2771 standard for trusted forwarders.
  - **The Flaw:** A compliant trusted forwarder must append the original `msg.sender` (20 bytes) to the end of the calldata it forwards. The TIME contract's `multicall` function failed to do this.
  - ```javascript
    // Flawed Multicall implementation
    function aggregate(Call[] calldata calls) public payable returns (uint256 blockNumber, bytes[] memory returnData) {
        ...
        (success, returnData[i]) = call.target.call(call.callData); // Fails to append msg.sender
        ...
    }
    ```
  - **The Mechanism:** The `ERC2771Context` contract, used for handling meta-transactions, retrieves the sender's address by reading the last 20 bytes of the calldata it receives from a trusted forwarder.
  - ```javascript
    // ERC2771Context logic to extract sender
    function _msgSender() internal view virtual override returns (address sender) {
        if (isTrustedForwarder(msg.sender) && msg.data.length >= 20) {
            assembly {
                sender := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            return super._msgSender();
        }
    }
    ```
  - **The Exploit:** Because the flawed `multicall` didn't append the real sender, the last 20 bytes of the _original calldata provided by the attacker_ were read by `_msgSender`. This allowed the attacker to craft a call where the last 20 bytes contained any address they wished to impersonate, such as the contract's owner, thereby bypassing access controls and draining funds.
  - **The Fix:** A secure `multicall` implementation appends the sender, ensuring the correct address is forwarded.
  - ```javascript
    // Secure Multicall3 implementation
    function aggregate(Call[] calldata calls) public payable returns (uint256 blockNumber, bytes[] memory returnData) {
        ...
        (success, returnData[i]) = call.target.call(abi.encodePacked(call.callData, msg.sender)); // Correctly appends msg.sender
        ...
    }
    ```
- **References**:
  - [Time Exploit ](https://etherscan.io/tx/0xecdd111a60debfadc6533de30fb7f55dc5ceed01dfadd30e4a7ebdb416d2f6b6)
  - [Openzeppelin ERC2771 disclosure](https://blog.openzeppelin.com/arbitrary-address-spoofing-vulnerability-erc2771context-multicall-public-disclosure)

---

## 2023-09-25 - 1

- **Date**: 2023-09-25 (Disclosure Date)
- **Project**: Multiple Smart Accounts (ERC-1271 Implementations)
- **Value Lost**: \$0 (Critical Vulnerability Disclosure)
- **Chain**: EVM Chains (Multi-chain)
- **BWC**:
  - **Broader Classification**: `BWC 4: Input & Data Validation Vulnerabilities`
  - **Primary Classification**: `BWC 4.3.2: Incomplete Signature Schemes`
  - **Secondary Classification**: `BWC 4.3.1: Missing Signature Validation`
- **Description**:
  - A widespread vulnerability was identified in the implementation of ERC-1271 `isValidSignature` across multiple smart account providers.
  - **The Flaw:** The standard implementation often only verified that the signature recovered to the correct `owner` address. It failed to verify that the signature was intended *specifically* for the contract instance receiving it.
  - **The Exploit:** If a user deployed multiple smart accounts (e.g., `Account A` and `Account B`) controlled by the same EOA key, a valid signature intended for `Account A` (e.g., a Permit signature) could be replayed on `Account B` because `Account B` only checked if the signer was the owner (which was true). This allowed attackers to replay authorizations across different accounts or chains owned by the same user.
  - **Vulnerable Code Pattern:**
    ```solidity
    function isValidSignature(bytes32 _hash, bytes calldata _signature) external view returns (bytes4) {
        // VULNERABLE: Only checks signer identity, not the destination scope
        if (recoverSigner(_hash, _signature) == owner) {
            return 0x1626ba7e;
        } else {
            return 0xffffffff;
        }
    }
    ```
- **References**:
  - [Curious Apple Mirror Post](https://mirror.xyz/curiousapple.eth/pFqAdW2LiJ-6S4sg_u1z08k4vK6BCJ33LcyXpnNb8yU)
  - [Alchemy Security Update](https://www.alchemy.com/blog/erc-1271-replay-vulnerability)

It’s important to emphasize that the intent behind this content is not to criticize or blame the affected projects but to provide objective overviews that serve as educational material for the community to learn from and better protect projects in the future.
