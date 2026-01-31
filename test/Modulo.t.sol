// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";

/// @notice A service that provides modulo operation for signed integers result according
/// to number theory.
/// @dev The modulo operation in Solidity is not the same as in mathematics for negative
/// numbers.
///      This service provides the correct modulo operation for signed integers.

contract ModuloService {

    function modulo(int256 value, int256 divisor) external pure returns (int256) {
        return (((value % divisor) + divisor) % divisor);
    }

}

contract ModuloServiceTest is Test {

    ModuloService service;

    function setUp() public {
        service = new ModuloService();
    }

    function testModulo() public view {
        int256 result = service.modulo(int256(-2), int256(7));
        assertEq(result, 5);
        int256 result2 = service.modulo(int256(10), int256(7));
        assertEq(result2, 3);
    }

}
