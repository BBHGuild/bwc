// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Clones} from "@openzeppelin-contracts/proxy/Clones.sol";
import {ERC1967Proxy} from "@openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {BeaconProxy} from "@openzeppelin-contracts/proxy/beacon/BeaconProxy.sol";
import {UpgradeableBeacon} from "@openzeppelin-contracts/proxy/beacon/UpgradeableBeacon.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin-contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Test, console} from "forge-std/Test.sol";
import {ContractATransparent, ContractAUUPS, ContractBTransparent, ContractBUUPS} from "src/Upgrade.sol";

contract UpgradesTest is Test {

    error UUPSUnauthorizedCallContext();

    using Clones for address;

    bytes32 internal constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    function setUp() public {}

    function test_UUPSProxy() public {
        ContractAUUPS contractAUUPS = new ContractAUUPS();
        ERC1967Proxy UUPSProxy =
            new ERC1967Proxy(address(contractAUUPS), abi.encodeWithSignature("initialize(uint256)", 5));

        ContractBUUPS contractBUUPS = new ContractBUUPS();
        address(UUPSProxy)
            .call(
                abi.encodeWithSignature(
                    "upgradeToAndCall(address,bytes)", contractBUUPS, abi.encodeWithSignature("initialize(uint256)", 5)
                )
            );
    }

    function test_TransparentProxy() public {
        ContractATransparent contractATransparent = new ContractATransparent();
        TransparentUpgradeableProxy transparentUpgradeableProxy = new TransparentUpgradeableProxy(
            address(contractATransparent), address(this), abi.encodeWithSignature("initialize(uint256)", 5)
        );

        bytes32 adminSlotValue = vm.load(address(transparentUpgradeableProxy), ADMIN_SLOT);

        address adminAddress = address(uint160(uint256(adminSlotValue)));

        ContractBTransparent contractBTransparent = new ContractBTransparent();

        adminAddress.call(
            abi.encodeWithSignature(
                "upgradeAndCall(address,address,bytes)",
                address(transparentUpgradeableProxy),
                address(contractBTransparent),
                abi.encodeWithSignature("initialize(uint256)", 5)
            )
        );
    }

    function test_BeaconProxy() public {
        ContractATransparent contractATransparent = new ContractATransparent();
        UpgradeableBeacon upgradeableBeacon = new UpgradeableBeacon(address(contractATransparent), address(this));

        BeaconProxy beaconProxy =
            new BeaconProxy(address(upgradeableBeacon), abi.encodeWithSignature("initialize(uint256)", 5));

        ContractBTransparent contractBTransparent = new ContractBTransparent();

        upgradeableBeacon.upgradeTo(address(contractBTransparent));

        address(beaconProxy).call(abi.encodeWithSignature("initialize(uint256)", 5));
    }

    function test_MinimalProxy() public {
        ContractATransparent contractATransparent = new ContractATransparent();

        address instanceOfContractA = address(contractATransparent).clone();

        address(instanceOfContractA).call(abi.encodeWithSignature("initialize(uint256)", 5));
    }

    function test_MinimalProxy_UUPS() public {
        ContractAUUPS contractAUUPS = new ContractAUUPS();

        address instanceOfContractA = address(contractAUUPS).clone();

        address(instanceOfContractA).call(abi.encodeWithSignature("initialize(uint256)", 5));

        ContractBUUPS contractBUUPS = new ContractBUUPS();

        // vm.expectRevert(UUPSUnauthorizedCallContext.selector);
        (bool success, bytes memory returnData) = address(instanceOfContractA)
            .call(abi.encodeWithSignature("upgradeToAndCall(address,bytes)", contractBUUPS, bytes("")));

        assertFalse(success, "The call should have reverted but it succeeded");
        bytes memory expectedRevertData = abi.encodeWithSignature("UUPSUnauthorizedCallContext()");
        assertEq(returnData, expectedRevertData, "Revert data did not match UUPSUnauthorizedCallContext");
    }

}
