// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

import {Config} from "forge-std/Config.sol";
import {MyToken} from "src/MyToken.sol";

/// @notice Multi-chain deployment of script.

contract MytokenScript is Script, Config {

    mapping(uint256 => address) public deployments;

    function setUp() public {}

    function run() public {
        // Load config and create forks for all chains
        _loadConfigAndForks("./deployments.toml", true);

        // Deploy to each configured chain
        for (uint256 i = 0; i < chainIds.length; i++) {
            uint256 chainId = chainIds[i];
            deployToChain(chainId);
        }

        // Verify cross-chain configuration
        verifyCrossChainSetup();
    }

    function deployToChain(uint256 chainId) internal {
        // Switch to the chain's fork
        vm.selectFork(forkOf[chainId]);

        console.log("\n========================================");
        console.log("Deploying to chain:", chainId);
        console.log("========================================");

        vm.startBroadcast();

        // Deploy with chain-specific configuration
        MyToken token = new MyToken(config.get("owner").toAddress(), config.get("owner").toAddress());

        vm.stopBroadcast();

        // Store deployment results
        deployments[chainId] = address(token);

        // Save to config file
        config.set("token", address(token));
    }

    function verifyCrossChainSetup() internal view {
        console.log("\n========================================");
        console.log("Cross-chain deployment summary:");
        console.log("========================================");

        for (uint256 i = 0; i < chainIds.length; i++) {
            uint256 chainId = chainIds[i];
            console.log("\nChain", chainId);
            console.log("  token:", deployments[chainId]);
        }
    }

}
