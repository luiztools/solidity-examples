// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

contract UniswapIntegration {
    ISwapRouter public uniswap;

    address public constant WMATIC = 0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889;
    address public constant WETH = 0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa;

    uint24 public constant poolFee = 3000;

    constructor(){
        uniswap = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    }

    function setUniswap(address _uniswap) public {
        uniswap = ISwapRouter(_uniswap);
    }

    function swap(address tokenIn, address tokenOut, uint amountIn) public returns(uint amountOut) {
        TransferHelper.safeTransferFrom(tokenIn, msg.sender, address(this), amountIn);

        TransferHelper.safeApprove(tokenIn, address(uniswap), amountIn);

        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        amountOut = uniswap.exactInputSingle(params);
    }

    function swapMaticToEth(uint amountIn) external returns(uint amountOut) {
        amountOut = swap(WMATIC, WETH);
    }

    function swapEthToMatic(uint amountIn) external returns(uint amountOut) {
        amountOut = swap(WETH, WMATIC);
    }
    
}