// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IVault {
    error AmountIsZero();
    error BalanceIsZero();

    function deposit(uint256 amount) external;

    function withdraw() external;

    function launchingAStrategy() external;

    function exitFromTheStrategy() external;

    function setStrategy(address _strategy) external;
}