// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./LLowGasSafeMath.sol";
import "./LSafeCast.sol";

import "./LUnitMath.sol";
import "./LInvestionMath.sol";

/// @title unit
/// @notice Contains functions for managing unit processes and relevant calculations
library LUnit {
    using LLowGasSafeMath for int256;
    using LSafeCast for int256;

    // info stored for each initialized individual unit
    struct Info {
        // the total position liquidity that references this unit
        //流动性总量
        uint128 InvestGross;
        // amount of net liquidity added (subtracted) when unit is crossed from left to right (right to left),
        // 穿越边界后流动性净增量或减量
        int128 InvestNet;
        // fee growth per unit of liquidity on the _other_ side of this unit (relative to the current unit)
        // only has relative meaning, not absolute — the value depends on when the unit is initialized
        // 仅具有相对含义，而非绝对含义 — 值取决于刻度的初始化时间
        uint256 coinFeeGrowthOutsideX128;
        //uint256 feeGrowthOutside1X128;
        // the cumulative unit value on the other side of the unit
        // 刻度另一侧的累积刻度值
        int56 unitCumulativeOutside;
        // the seconds per unit of liquidity on the _other_ side of this unit (relative to the current unit)
        // only has relative meaning, not absolute — the value depends on when the unit is initialized
        uint160 secondsPerLiquidityOutsideX128;
        // the seconds spent on the other side of the unit (relative to the current unit)
        // only has relative meaning, not absolute — the value depends on when the unit is initialized
        // 仅具有相对含义，而非绝对含义 — 值取决于刻度的初始化时间
        uint32 secondsOutside;
        // true iff the unit is initialized, i.e. the value is exactly equivalent to the expression InvestGross != 0
        // these 8 bits are set to prevent fresh sstores when crossing newly initialized units
        // 设置这 8 位以防止在跨越新初始化的刻度时出现新的存储
        bool initialized;
    }

    /// @notice Derives max liquidity per unit from given unit spacing
    /// @dev Executed within the pool constructor
    /// @param unitSpacing The amount of required unit separation, realized in multiples of `unitSpacing`
    ///     e.g., a unitSpacing of 3 requires units to be initialized every 3rd unit i.e., ..., -6, -3, 0, 3, 6, ...
    /// @return The max liquidity per unit
    function unitSpacingToMaxinvestionPerUnit(int24 unitSpacing)
        internal
        pure
        returns (uint128)
    {
        int24 minUnit = (LUnitMath.MIN_UNIT / unitSpacing) * unitSpacing;
        int24 maxUnit = (LUnitMath.MAX_UNIT / unitSpacing) * unitSpacing;
        uint24 numUnits = uint24((maxUnit - minUnit) / unitSpacing) + 1;
        return type(uint128).max / numUnits;
    }

    /// @notice Retrieves fee growth data
    /// @param self The mapping containing all unit information for initialized units
    /// @param unitLower The lower unit boundary of the position
    /// @param unitUpper The upper unit boundary of the position
    /// @param unitCurrent The current unit
    /// @param coinFeeGrowthGlobalX128 The all-time global fee growth, per unit of liquidity, in token0
    /// @return coinFeeGrowthInsideX128 The all-time fee growth in token0, per unit of liquidity, inside the position's unit boundaries
    function getFeeGrowthInside(
        mapping(int24 => LUnit.Info) storage self,
        int24 unitLower,
        int24 unitUpper,
        int24 unitCurrent,
        uint256 coinFeeGrowthGlobalX128
    ) internal view returns (uint256 coinFeeGrowthInsideX128) {
        Info storage lower = self[unitLower];
        Info storage upper = self[unitUpper];

        // calculate fee growth below
        uint256 coinFeeGrowthBelowX128;
        if (unitCurrent >= unitLower) {
            coinFeeGrowthBelowX128 = lower.coinFeeGrowthOutsideX128;
        } else {
            coinFeeGrowthBelowX128 =
                coinFeeGrowthGlobalX128 -
                lower.coinFeeGrowthOutsideX128;
        }

        // calculate fee growth above
        uint256 coinFeeGrowthAboveX128;
        if (unitCurrent < unitUpper) {
            coinFeeGrowthAboveX128 = upper.coinFeeGrowthOutsideX128;
        } else {
            coinFeeGrowthAboveX128 =
                coinFeeGrowthGlobalX128 -
                upper.coinFeeGrowthOutsideX128;
        }

        coinFeeGrowthInsideX128 =
            coinFeeGrowthGlobalX128 -
            coinFeeGrowthBelowX128 -
            coinFeeGrowthAboveX128;
    }

    /// @notice Updates a unit and returns true if the unit was flipped from initialized to uninitialized, or vice versa
    /// 如果刻度从已初始化翻转为未初始化，则更新刻度并返回 true，反之亦然
    /// @param self The mapping containing all unit information for initialized units
    /// @param unit The unit that will be updated
    /// @param unitCurrent The current unit
    /// @param liquidityDelta A new amount of liquidity to be added (subtracted) when unit is crossed from left to right (right to left)
    /// @param coinFeeGrowthGlobalX128 The all-time global fee growth, per unit of liquidity, in token0
    /// @param secondsPerLiquidityCumulativeX128 The all-time seconds per max(1, liquidity) of the pool
    /// @param unitCumulative The unit * time elapsed since the pool was first initialized
    /// @param time The current block timestamp cast to a uint32
    /// @param upper true for updating a position's upper unit, or false for updating a position's lower unit
    /// @param maxLiquidity The maximum liquidity allocation for a single unit
    /// @return flipped Whether the unit was flipped from initialized to uninitialized, or vice versa
    function update(
        mapping(int24 => LUnit.Info) storage self,
        int24 unit,
        int24 unitCurrent,
        int128 liquidityDelta,
        uint256 coinFeeGrowthGlobalX128,
        uint160 secondsPerLiquidityCumulativeX128,
        int56 unitCumulative,
        uint32 time,
        bool upper,
        uint128 maxLiquidity
    ) internal returns (bool flipped) {
        LUnit.Info storage info = self[unit];

        uint128 InvestGrossBefore = info.InvestGross;
        uint128 InvestGrossAfter = LInvestionMath.addDelta(
            InvestGrossBefore,
            liquidityDelta
        );

        require(InvestGrossAfter <= maxLiquidity, "LO");

        flipped = (InvestGrossAfter == 0) != (InvestGrossBefore == 0);

        if (InvestGrossBefore == 0) {
            // by convention, we assume that all growth before a unit was initialized happened _below_ the unit
            if (unit <= unitCurrent) {
                info.coinFeeGrowthOutsideX128 = coinFeeGrowthGlobalX128;
                info
                    .secondsPerLiquidityOutsideX128 = secondsPerLiquidityCumulativeX128;
                info.unitCumulativeOutside = unitCumulative;
                info.secondsOutside = time;
            }
            info.initialized = true;
        }

        info.InvestGross = InvestGrossAfter;

        // when the lower (upper) unit is crossed left to right (right to left), liquidity must be added (removed)
        info.InvestNet = upper
            ? int256(info.InvestNet).sub(liquidityDelta).toInt128()
            : int256(info.InvestNet).add(liquidityDelta).toInt128();
    }

    /// @notice Clears unit data
    /// @param self The mapping containing all initialized unit information for initialized units
    /// @param unit The unit that will be cleared
    function clear(mapping(int24 => LUnit.Info) storage self, int24 unit)
        internal
    {
        delete self[unit];
    }

    /// @notice Transitions to next unit as needed by price movement
    /// @param self The mapping containing all unit information for initialized units
    /// @param unit The destination unit of the transition
    /// @param coinFeeGrowthGlobalX128 The all-time global fee growth, per unit of liquidity, in token0
    /// @param secondsPerLiquidityCumulativeX128 The current seconds per liquidity
    /// @param unitCumulative The unit * time elapsed since the pool was first initialized
    /// @param time The current block.timestamp
    /// @return InvestNet The amount of liquidity added (subtracted) when unit is crossed from left to right (right to left)
    function cross(
        mapping(int24 => LUnit.Info) storage self,
        int24 unit,
        uint256 coinFeeGrowthGlobalX128,
        uint160 secondsPerLiquidityCumulativeX128,
        int56 unitCumulative,
        uint32 time
    ) internal returns (int128 InvestNet) {
        LUnit.Info storage info = self[unit];
        info.coinFeeGrowthOutsideX128 =
            coinFeeGrowthGlobalX128 -
            info.coinFeeGrowthOutsideX128;
        info.secondsPerLiquidityOutsideX128 =
            secondsPerLiquidityCumulativeX128 -
            info.secondsPerLiquidityOutsideX128;
        info.unitCumulativeOutside =
            unitCumulative -
            info.unitCumulativeOutside;
        info.secondsOutside = time - info.secondsOutside;
        InvestNet = info.InvestNet;
    }
}
