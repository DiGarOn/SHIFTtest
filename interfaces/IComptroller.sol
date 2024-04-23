// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.0;

interface IComptroller {

    /*** Assets You Are In ***/

    function enterMarkets(
        address[] calldata mTokens
    ) external virtual returns (uint[] memory);
    function exitMarket(address mToken) external virtual returns (uint);

    /*** Policy Hooks ***/

    function mintAllowed(
        address mToken,
        address minter,
        uint mintAmount
    ) external virtual returns (uint);

    function redeemAllowed(
        address mToken,
        address redeemer,
        uint redeemTokens
    ) external virtual returns (uint);

    // Do not remove, still used by MToken
    function redeemVerify(
        address mToken,
        address redeemer,
        uint redeemAmount,
        uint redeemTokens
    ) external pure virtual;

    function borrowAllowed(
        address mToken,
        address borrower,
        uint borrowAmount
    ) external virtual returns (uint);

    function repayBorrowAllowed(
        address mToken,
        address payer,
        address borrower,
        uint repayAmount
    ) external virtual returns (uint);

    function liquidateBorrowAllowed(
        address mTokenBorrowed,
        address mTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount
    ) external view virtual returns (uint);

    function seizeAllowed(
        address mTokenCollateral,
        address mTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens
    ) external virtual returns (uint);

    function transferAllowed(
        address mToken,
        address src,
        address dst,
        uint transferTokens
    ) external virtual returns (uint);

    /*** Liquidity/Liquidation Calculations ***/

    function liquidateCalculateSeizeTokens(
        address mTokenBorrowed,
        address mTokenCollateral,
        uint repayAmount
    ) external view virtual returns (uint, uint);
}
