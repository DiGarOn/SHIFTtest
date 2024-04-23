// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { TransferHelper } from "./additions/TransferHelper.sol";
import { IStrategy } from "../interfaces/IStrategy.sol";
import { IVault } from "../interfaces/IVault.sol";

contract Vault is IVault, Ownable {

    string public constant name = "USDC_VAULT";

    address public strategy;
    address public constant USDC = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;

    uint256 private depositedAmount;

    constructor(address _owner) Ownable(_owner){}

    // param: uint256 amount - amount of USDC to deposit. Allowance is needed
    function deposit(uint256 amount) external onlyOwner {
        if(amount == 0) revert AmountIsZero();
        TransferHelper.safeTransferFrom(USDC, msg.sender, address(this), amount);
    }

    // Transfer all USDC to owner
    function withdraw() external onlyOwner {
        uint256 balance = IERC20(USDC).balanceOf(address(this));
        if(balance == 0) revert BalanceIsZero();
        TransferHelper.safeTransfer(USDC, msg.sender, balance);
    }

    // Start the strategy
    function launchingAStrategy() external onlyOwner {
        uint256 balance = IERC20(USDC).balanceOf(address(this));

        IERC20(USDC).approve(strategy, balance);
        depositedAmount = balance;

        IStrategy(strategy).launch();
    }

    // Exit the strategy. Ensure that the owner must have enough usdc to repay the loan
    function exitFromTheStrategy() external onlyOwner {
        uint256 amountForExit = IStrategy(strategy).calcAmountToExit();
        TransferHelper.safeTransferFrom(USDC, msg.sender, strategy, amountForExit);
        IStrategy(strategy).exitFromTheStrategy();
    }

    function setStrategy(address _strategy) external onlyOwner {
        strategy = _strategy;
    }
}