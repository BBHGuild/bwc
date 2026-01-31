// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

contract ReentrancyTemplate {

    address target;

    constructor(address victim) {
        target = victim;
    }
    /**
     * @dev Initiates the reentrancy attack. Make any calls to the target contract, and continue reentrancy attack in
     * the below callback function
     */

    function initiateAttack() external view {
        // Initiate call to the target contract
        console.log("Initiating attack on %s", target);

        // TODO: Modify the attack here to initiate reentrancy in your victim
        // Interface(target).someFunction();
    }

    /**
     * @dev Function run the first time the callback is entered
     */
    function _executeAttack() internal {
        // TODO: Modify the attack here
    }

    /**
     * @dev Function run after the attack is executed
     */
    function _completeAttack() internal view {
        console.log("Attacker balance after %s", address(this).balance);
        // TODO: Modify the attack cleanup here
    }

    /**
     * @dev Function run when target contract makes external call back to attack contract
     */
    function _reentrancyCallback() internal virtual {
        console.log(">>> Execute attack");
        _executeAttack();
    }

    /**
     * @dev Handles the receipt of ERC677 token type.
     */
    function onTokenTransfer(address, uint256, bytes memory) external returns (bool) {
        _reentrancyCallback();
        return true;
    }

    /**
     * @dev Handles the receipt of ERC1363 token type.
     */
    function onTransferReceived(address, address, uint256, bytes memory) external returns (bytes4) {
        _reentrancyCallback();
        return this.onTransferReceived.selector;
    }

    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     */
    function onERC1155Received(address, address, uint256, uint256, bytes calldata) external returns (bytes4) {
        _reentrancyCallback();
        return this.onERC1155Received.selector;
    }

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     */
    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external returns (bytes4) {
        _reentrancyCallback();
        return this.onERC1155BatchReceived.selector;
    }

    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     */
    function onERC721Received(address, address, uint256, bytes calldata) external returns (bytes4) {
        _reentrancyCallback();
        return this.onERC721Received.selector;
    }

    /**
     * @dev Fallback function called when no other functions match the function signature
     */
    fallback() external payable virtual {
        _reentrancyCallback();
    }

    /**
     * @dev Function called when native asset is sent with no calldata
     */
    receive() external payable virtual {
        _reentrancyCallback();
    }

    /**
     * @dev We need to implement this function to tell contracts we support their callback interface
     * @return true Always returns true
     */
    function supportsInterface(bytes4) public pure returns (bool) {
        return true;
    }

}

contract ReentrancyTest is Test {

    ReentrancyTemplate public attackContract;
    address victimContract = address(0x0); // Modify this to be your victim contract

    function setUp() public {
        attackContract = new ReentrancyTemplate(address(victimContract));
    }

    function testReentrancyAttack() public view {
        attackContract.initiateAttack();
    }

}
