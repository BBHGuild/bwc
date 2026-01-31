// SPDX-License-Identifier: MIT
/// @notice Demo on how to generate and verify a Merkle Proof. Usefull for Testing Merkle
/// implementations.

pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Merkle} from "murky/Merkle.sol";

contract MerkleDistributorTest is Test {

    Merkle public m;

    function setUp() public {
        // Initialize
        m = new Merkle();
    }

    function testMerkle() public view {
        // Toy Data
        bytes32[] memory data = new bytes32[](4);
        data[0] = bytes32("0x0");
        data[1] = bytes32("0x1");
        data[2] = bytes32("0x2");
        data[3] = bytes32("0x3");

        // Get Root, Proof, and Verify
        bytes32 root = m.getRoot(data);
        bytes32[] memory proof = m.getProof(data, 2);
        assertEq(m.verifyProof(root, proof, data[2]), true);
    }

}
