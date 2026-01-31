# Immunefi Vulnerability Severity Classification System

At Immunefi, we classify bugs on a simplified 4-level scale:

- Critical
- High
- Medium
- Low

## Smart Contracts

| Level       | Impact                                                                                                                                            |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| 4. Critical | - Manipulation of governance voting result deviating from voted outcome and resulting in a direct change from intended effect of original results |
|             | - Direct theft of any user funds, whether at-rest or in-motion, other than unclaimed yield                                                        |
|             | - Direct theft of any user NFTs, whether at-rest or in-motion, other than unclaimed royalties                                                     |
|             | - Permanent freezing of funds                                                                                                                     |
|             | - Permanent freezing of NFTs                                                                                                                      |
|             | - Unauthorized minting of NFTs                                                                                                                    |
|             | - Predictable or manipulable RNG that results in abuse of the principal or NFT                                                                    |
|             | - Unintended alteration of what the NFT represents (e.g. token URI, payload, artistic content)                                                    |
|             | - Protocol insolvency                                                                                                                             |
| 3. High     | - Theft of unclaimed yield                                                                                                                        |
|             | - Theft of unclaimed royalties                                                                                                                    |
|             | - Permanent freezing of unclaimed yield                                                                                                           |
|             | - Permanent freezing of unclaimed royalties                                                                                                       |
|             | - Temporary freezing of funds                                                                                                                     |
|             | - Temporary freezing NFTs                                                                                                                         |
| 2. Medium   | - Smart contract unable to operate due to lack of token funds                                                                                     |
|             | - Block stuffing                                                                                                                                  |
|             | - Griefing (e.g. no profit motive for an attacker, but damage to the users or the protocol)                                                       |
|             | - Theft of gas                                                                                                                                    |
|             | - Unbounded gas consumption                                                                                                                       |
| 1. Low      | - Contract fails to deliver promised returns, but doesn't lose value                                                                              |

## Out of Scope & Rules

These are the default impacts recommended to projects to mark as out of scope for their bug bounty program. The actual list of out of scope impacts differ from program to program.

- Impacts requiring attacks that the reporter has already exploited themselves, leading to damage.
- Impacts caused by attacks requiring access to leaked keys/credentials.
- Impacts caused by attacks requiring access to privileged addresses (including, but not limited to: governance and strategist contracts) without additional modifications to the privileges attributed.
- Impacts relying on attacks involving the depegging of an external stablecoin where the attacker does not directly cause the depegging due to a bug in code.
- Mentions of secrets, access tokens, API keys, private keys, etc. in Github will be considered out of scope without proof that they are in-use in production.
- Best practice recommendations.
- Feature requests.
- Impacts on test files and configuration files unless stated otherwise in the bug bounty program.
- Impacts requiring phishing or other social engineering attacks against project's employees and/or customers.

## Smart Contracts/Blockchain DLT

- Incorrect data supplied by third party oracles.
- Not to exclude oracle manipulation/flash loan attacks.
- Impacts requiring basic economic and governance attacks (e.g. 51% attack).
- Lack of liquidity impacts.
- Impacts from Sybil attacks.
- Impacts involving centralization risks.

## The following activities are prohibited by default on bug bounty programs on Immunefi. However, projects may add further restrictions to their own program:

- Any testing on mainnet or public testnet deployed code; all testing should be done on local-forks of either public testnet or mainnet.
- Any testing with pricing oracles or third-party smart contracts.
- Attempting phishing or other social engineering attacks against our employees and/or customers.
- Any testing with third-party systems and applications (e.g. browser extensions) as well as websites (e.g. SSO providers, advertising networks).
- Any denial of service attacks that are executed against project assets.
- Automated testing of services that generates significant amounts of traffic.
- Public disclosure of an unpatched vulnerability in an embargoed bounty.
