// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

contract RebasingERC20 is IERC20Errors, IERC20 {

    uint256 internal _totalShares;
    mapping(address => uint256) public _shareBalance;
    mapping(address owner => mapping(address spender => uint256 allowance)) public allowance;

    receive() external payable {}

    function mint(address to, uint256 slippageBp) external payable {
        require(to != address(0), ERC20InvalidReceiver(to));
        require(msg.value > 0);

        uint256 sharesToCreate;
        if (_totalShares == 0) {
            sharesToCreate = msg.value;
        } else {
            uint256 prevBalance = address(this).balance - msg.value;
            sharesToCreate = msg.value * _totalShares / prevBalance;
            require(sharesToCreate > 0);
        }
        _totalShares += sharesToCreate;
        _shareBalance[to] += sharesToCreate;
        require(sharesToCreate * 10_000 * address(this).balance >= slippageBp * msg.value * _totalShares, "slippage");

        uint256 balance = sharesToCreate * address(this).balance / _totalShares;
        emit Transfer(address(0), to, balance);
    }

    function burn(address from, uint256 amount) external {
        _spendAllowanceOrBlock(from, msg.sender, amount);
        uint256 shares = _amountToShares(amount);
        require(shares > 0);
        _shareBalance[from] -= shares;
        _totalShares -= shares;

        (bool ok,) = from.call{value: amount}("");
        require(ok, ERC20InvalidReceiver(from));

        emit Transfer(from, address(0), amount);
    }

    function _amountToShares(uint256 amount) public view returns (uint256) {
        if (address(this).balance == 0) {
            return 0;
        }
        return amount * _totalShares / address(this).balance;
    }

    function totalSupply() public view returns (uint256) {
        return address(this).balance;
    }

    function balanceOf(address account) public view returns (uint256) {
        if (_totalShares == 0) {
            return 0;
        }
        return _shareBalance[account] * address(this).balance / _totalShares;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        transferFrom(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(to != address(0), ERC20InvalidReceiver(to));
        _spendAllowanceOrBlock(from, msg.sender, amount);
        uint256 shareTransfer = _amountToShares(amount);
        _shareBalance[from] -= shareTransfer;
        _shareBalance[to] += shareTransfer;

        emit Transfer(from, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function _spendAllowanceOrBlock(address owner, address spender, uint256 amount) internal {
        if (owner != msg.sender && allowance[owner][spender] != type(uint256).max) {
            uint256 currentAllowance = allowance[owner][spender];
            require(currentAllowance >= amount, ERC20InsufficientAllowance(spender, currentAllowance, amount));
            allowance[owner][spender] = currentAllowance - amount;
        }
    }

}
