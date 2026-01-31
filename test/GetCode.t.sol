// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";

library GetCode {

    function at(address addr) internal view returns (bytes memory code) {
        assembly {
            // retrieve the size of the code, this needs assembly
            let size := extcodesize(addr)
            // allocate output byte array - this could also be done without assembly
            // by using code = new bytes(size)
            code := mload(0x40)
            // new "memory end" including padding
            mstore(0x40, add(code, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            // store length in memory
            mstore(code, size)
            // actually retrieve the code, this needs assembly
            extcodecopy(addr, add(code, 0x20), 0, size)
        }
    }

}

contract GetCodeTest is Test {

    function setUp() public {
        vm.createSelectFork("mainnet");
    }

    function test_at() public view {
        bytes memory code = GetCode.at(address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
        console.log("code length: %d", code.length);
    }

}
