// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IStrategy {
    error CallerIsNotTheVault();

    function launch() external;
    function exitFromTheStrategy() external;
    function calcAmountToExit() external returns (uint256);
}