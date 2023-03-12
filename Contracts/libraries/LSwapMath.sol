// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./LFullMath.sol";
import "./LSqrtPriceMath.sol";
import "./LLowGasSafeMath.sol";
import "./LSafeCast.sol";

/// @title Computes the result of a swap within ticks
/// @notice Contains methods for computing the result of a swap within a single tick price range, i.e., a single tick.
library LSwapMath {
    using LSafeCast for uint256;
    using LSafeCast for int256;

    /// @notice Computes the result of swapping some amount in, or amount out, given the parameters of the swap,调整内容,删除computeSwapStep中每一步去计算手续费,买的时间开始计手续费,卖的时候最后计手续费
    /// @dev The fee, plus the amount in, will never exceed the amount remaining if the swap's `amountSpecified` is positive
    /// @param sqrtRatioCurrentX96 The current sqrt price of the pool
    /// @param sqrtRatioTargetX96 The price that cannot be exceeded, from which the direction of the swap is inferred
    /// @param liquidity The usable liquidity
    /// @param amountRemaining How much input or output amount is remaining to be swapped in/out
    /// @return sqrtRatioNextX96 The price after swapping the amount in/out, not to exceed the price target
    /// @return amountIn The amount to be swapped in, of either token0 or token1, based on the direction of the swap
    /// @return amountOut The amount to be received, of either token0 or token1, based on the direction of the swap

    function computeSwapStep(
        uint160 sqrtRatioCurrentX96,
        uint160 sqrtRatioTargetX96,
        uint128 liquidity,
        int256 amountRemaining
    )
        internal
        pure
        returns (uint160 sqrtRatioNextX96, uint256 amountIn, uint256 amountOut)
    {
        bool zeroForOne = sqrtRatioCurrentX96 >= sqrtRatioTargetX96;
        bool exactIn = amountRemaining >= 0;

        if (exactIn) {
            amountIn = zeroForOne
                ? LSqrtPriceMath.getAmount0Delta(
                    sqrtRatioTargetX96,
                    sqrtRatioCurrentX96,
                    liquidity,
                    true
                )
                : LSqrtPriceMath.getAmount1Delta(
                    sqrtRatioCurrentX96,
                    sqrtRatioTargetX96,
                    liquidity,
                    true
                );
            if (amountRemaining.toUint256() >= amountIn)
                sqrtRatioNextX96 = sqrtRatioTargetX96;
            else
                sqrtRatioNextX96 = LSqrtPriceMath.getNextSqrtPriceFromInput(
                    sqrtRatioCurrentX96,
                    liquidity,
                    amountRemaining.toUint256(),
                    zeroForOne
                );
        } else {
            amountOut = zeroForOne
                ? LSqrtPriceMath.getAmount1Delta(
                    sqrtRatioTargetX96,
                    sqrtRatioCurrentX96,
                    liquidity,
                    false
                )
                : LSqrtPriceMath.getAmount0Delta(
                    sqrtRatioCurrentX96,
                    sqrtRatioTargetX96,
                    liquidity,
                    false
                );
            if (uint256(-amountRemaining) >= amountOut)
                sqrtRatioNextX96 = sqrtRatioTargetX96;
            else
                sqrtRatioNextX96 = LSqrtPriceMath.getNextSqrtPriceFromOutput(
                    sqrtRatioCurrentX96,
                    liquidity,
                    uint256(-amountRemaining),
                    zeroForOne
                );
        }

        bool max = sqrtRatioTargetX96 == sqrtRatioNextX96;

        // get the input/output amounts
        if (zeroForOne) {
            amountIn = max && exactIn
                ? amountIn
                : LSqrtPriceMath.getAmount0Delta(
                    sqrtRatioNextX96,
                    sqrtRatioCurrentX96,
                    liquidity,
                    true
                );
            amountOut = max && !exactIn
                ? amountOut
                : LSqrtPriceMath.getAmount1Delta(
                    sqrtRatioNextX96,
                    sqrtRatioCurrentX96,
                    liquidity,
                    false
                );
        } else {
            amountIn = max && exactIn
                ? amountIn
                : LSqrtPriceMath.getAmount1Delta(
                    sqrtRatioCurrentX96,
                    sqrtRatioNextX96,
                    liquidity,
                    true
                );
            amountOut = max && !exactIn
                ? amountOut
                : LSqrtPriceMath.getAmount0Delta(
                    sqrtRatioCurrentX96,
                    sqrtRatioNextX96,
                    liquidity,
                    false
                );
        }

        // cap the output amount to not exceed the remaining output amount
        if (!exactIn && amountOut > uint256(-amountRemaining)) {
            amountOut = uint256(-amountRemaining);
        }
    }
}
