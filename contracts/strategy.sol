// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { TransferHelper } from "./additions/TransferHelper.sol";
import { IUniswapV2Router02 } from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import { IUniswapV2Pair } from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import { IUniswapV2Factory } from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IComptroller } from "../interfaces/IComptroller.sol";
import { IStrategy } from "../interfaces/IStrategy.sol";
import { IMToken } from "../interfaces/IMToken.sol";

contract Strategy is IStrategy {
    uint256 public currentLoan;
    address public immutable vault;

    IComptroller public constant comptroller = IComptroller(0xfBb21d0380beE3312B33c4353c8936a0F13EF26C);
    IMToken public constant mUSDC = IMToken(0xEdc817A28E8B93B03976FBd4a3dDBc9f7D176c22);
    IMToken public constant mDAI = IMToken(0x73b06D8d18De422E269645eaCe15400DE7462417);
    IERC20 public constant USDC = IERC20(0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913);
    IERC20 public constant DAI = IERC20(0x50c5725949A6F0c72E6C4a641F24049A917DB0Cb); // token 0
    IERC20 public constant WETH = IERC20(0x4200000000000000000000000000000000000006);
    IUniswapV2Pair pair;

    IUniswapV2Router02 public constant uniswapV2Router = IUniswapV2Router02(0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24); // SmarDex

    constructor(address _vault) {
        vault = _vault;
        pair = IUniswapV2Pair(IUniswapV2Factory(uniswapV2Router.factory()).getPair(address(USDC), address(DAI)));
    }

    // Calculates the amount of usdc to repay the loan
    function calcAmountToExit() external returns (uint256) {
        currentLoan = mDAI.borrowBalanceCurrent(address(this));
        (uint256 reserv0, uint256 reserv1, ) = pair.getReserves();
        uint256 amointIn = uniswapV2Router.getAmountIn(currentLoan, reserv1, reserv0);
        return amointIn;
    }

    // Repay the loan and close the position, transfer all usdc to the vault
    function exitFromTheStrategy() external {
        if(msg.sender != vault) revert CallerIsNotTheVault();

        address[] memory path = new address[](2);
        path[0] = address(USDC);
        path[1] = address(DAI);
        USDC.approve(address(uniswapV2Router), currentLoan);
        uniswapV2Router.swapTokensForExactTokens(
                currentLoan,
                USDC.balanceOf(address(this)),
                path,
                address(this),
                36000000000
            );

        DAI.approve(address(mDAI), currentLoan);
        uint b = mDAI.repayBorrow(currentLoan);

        uint256 amount = mUSDC.balanceOf(address(this));
        uint a = mUSDC.redeem(amount);
        TransferHelper.safeTransfer(address(USDC), vault, USDC.balanceOf(address(this)));
    }

    // Strategy itself. Allowance from vault on USDC is needed
    function launch() external {
        if(msg.sender != vault) revert CallerIsNotTheVault();

        uint256 amount = USDC.balanceOf(vault);
        USDC.approve(address(mUSDC), amount);

        TransferHelper.safeTransferFrom(address(USDC), vault, address(this), amount); // correct

        mUSDC.mint(amount);

        address[] memory market = new address[](1);
        market[0] = address(mUSDC);

        comptroller.enterMarkets(market);

        uint256 mUSDCamount = mUSDC.balanceOf(address(this));

        mDAI.borrow(mUSDCamount * 70 / 100); // LTV 70 %
        currentLoan = mUSDCamount * 70 / 100;
        DAI.approve(address(mDAI), currentLoan);

        uint256 daiBalance = DAI.balanceOf(address(this));
        DAI.approve(address(uniswapV2Router), daiBalance);

        address[] memory path = new address[](3);
        path[0] = address(DAI);
        path[1] = address(WETH);
        path[2] = address(USDC);

        uniswapV2Router.swapExactTokensForTokens(
                daiBalance,
                0,
                path,
                address(this),
                36000000000
            );

        uint256 usdcBalance = USDC.balanceOf(address(this));
        USDC.approve(address(mUSDC), usdcBalance);

        mUSDC.mint(usdcBalance);
    }
}