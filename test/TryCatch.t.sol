// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import {Test, console} from "forge-std/Test.sol";

contract TryCatch {

    error CustomError(uint256 balance);

    uint256 public balance = 10;

    function decrementBalance() external {
        require(balance > 0, "Balance is already zero");
        balance -= 1;
    }

    function revertTest() external view {
        if (balance == 9) {
            // revert without a message
            revert();
        }

        if (balance == 8) {
            uint256 a = 1;
            uint256 b = 0;
            // This is an illegal operation and should cause a panic (Panic(uint256)) due
            // to division by zero
            a / b;
        }

        if (balance == 7) {
            // revert with a message
            revert("not allowed");
        }

        if (balance == 6) {
            // revert with a message
            revert CustomError(100);
        }
    }

}

contract TryCatchTest is Test {

    event Errorhandled(uint256 balance);

    TryCatch public tryCatch;

    function setUp() public {
        tryCatch = new TryCatch();
    }

    function test_TryCatch() public {
        tryCatch.decrementBalance();
        callRevertTest();
        tryCatch.decrementBalance();
        callRevertTest();
        tryCatch.decrementBalance();
        callRevertTest();
        tryCatch.decrementBalance();
        callRevertTest();
    }

    function callRevertTest() internal view {
        try tryCatch.revertTest() {
        // Handle the success case if needed
        }
        catch Panic(uint256 errorCode) {
            // handle illegal operation and `assert` errors
            console.log("error occurred with this error code: ", errorCode);
        } catch Error(string memory reason) {
            // handle revert with a reason
            console.log("error occured with this reason: ", reason);
        } catch (bytes memory lowLevelData) {
            // revert without a message
            if (lowLevelData.length == 0) {
                console.log("revert without a message occured");
            }

            // Decode the error data to check if it's the custom error
            if (bytes4(abi.encodeWithSignature("CustomError(uint256)")) == bytes4(lowLevelData)) {
                // handle custom error
                console.log("CustomError occured here");
            }
        }
    }

}
