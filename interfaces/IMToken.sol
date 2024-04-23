// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.0;

interface IMToken {
    function mint(uint mintAmount) external returns (uint);
    function mintWithPermit(
        uint mintAmount,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint);
    function redeem(uint redeemTokens) external returns (uint);
    function redeemUnderlying(
        uint redeemAmount
    ) external returns (uint);
    function borrow(uint borrowAmount) external returns (uint);
    function repayBorrow(uint repayAmount) external returns (uint);
    function repayBorrowBehalf(
        address borrower,
        uint repayAmount
    ) external returns (uint);
    function balanceOf(address owner) external view returns (uint256);
    function totalBorrowsCurrent() external returns (uint);
    function borrowBalanceCurrent(address account) external returns (uint);
}