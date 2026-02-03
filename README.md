# Blockchain Weakness Classification (BWC) & Bounty Hunter Benchmark

This repository serves as a comprehensive framework for Ethereum security research, combining a novel vulnerability taxonomy with an automated testing harness for LLM agents.

## Mission

1.  **Taxonomy (BWC):** Maintain the **Blockchain Weakness Classification**, an open-source standard for categorizing EVM smart contract vulnerabilities, moving beyond simple bug lists to comprehensive failure modes.
2.  **Incident Benchmark:** Curate a database of real-world security incidents, analyzing root causes and impact.
3.  **Bounty Hunter Agent:** Develop and refine an **LLM-driven "Bounty Hunter" skill** capable of autonomously identifying vulnerabilities and generating working Proof-of-Concept (PoC) exploits using Foundry.
4.  **Reproduction Harness:** Build a standardized benchmark of historical hacks to rigorously test the agent's ability to "one-shot" reproduce known exploits against local forks.

## Repository Structure

- **`docs/`**: Contains the BWC taxonomy, incident logs (2016-2026), and the Bounty Hunter skill definition.
- **`src/` & `test/`**: Foundry environment for the Exploit Benchmark and agent testing harnesses.

## Installation & Setup

### Prerequisites

- [Foundry](https://getfoundry.sh/) (Forge, Cast, Anvil)

### 1. Build Project

```shell
forge build
```

### 2. Install LLM Bounty Hunter Skill

To use the Bounty Hunter skill with your LLM CLI agent (e.g., Gemini CLI), create a symbolic link from this repository's skill definition to your agent's skills directory.

**For Gemini CLI:**

```shell
# Ensure your local skills directory exists
mkdir -p ~/.gemini/skills

# Link the bounty-hunting skill directory
ln -s "$(pwd)/docs/src/skills/bounty-hunting" ~/.gemini/skills/bounty-hunting
```

Once linked, you can activate the skill in your LLM session using:
`activate_skill bounty-hunting`

## Usage

### Run Tests (Exploit Benchmark)

Execute the reproduction harnesses to verify historical hacks:

```shell
forge test
```

### Documentation

Access the BWC and Incident Logs locally:

```shell
cd docs
mdbook serve
```
