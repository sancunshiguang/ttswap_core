// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./LBitMath.sol";

/// @title Packed Unit initialized state library
/// @notice Stores a packed mapping of tick index to its initialized state
/// @dev The mapping uses int16 for keys since ticks are represented as int24 and there are 256 (2^8) values per word.
library LUnitBitmap {
    /// @notice Computes the position in the mapping where the initialized bit for a tick lives
    /// @param unit The Unit for which to compute the position
    /// @return wordPos The key in the mapping containing the word in which the bit is stored
    /// @return bitPos The bit position in the word where the flag is stored
    function position(int24 unit)
        private
        pure
        returns (int16 wordPos, uint8 bitPos)
    {
        wordPos = int16(unit >> 8);
        bitPos = uint8(uint24(unit) % 256);
    }

    /// @notice Flips the initialized state for a given tick from false to true, or vice versa
    /// 对给定的位置的ticks进行初始化
    /// @param self The mapping in which to flip the tick
    /// @param tick The tick to flip
    /// @param tickSpacing The spacing between usable ticks
    function flipTick(
        mapping(int16 => uint256) storage self,
        int24 tick,
        int24 tickSpacing
    ) internal {
        require(tick % tickSpacing == 0); // ensure that the tick is spaced
        (int16 wordPos, uint8 bitPos) = position(tick / tickSpacing);
        uint256 mask = 1 << bitPos;
        self[wordPos] ^= mask;
    }

    /// @notice Returns the next initialized tick contained in the same word (or adjacent word) as the tick that is either
    /// to the left (less than or equal to) or right (greater than) of the given tick
    /// @param self The mapping in which to compute the next initialized tick
    /// @param tick The starting tick /开始标记
    /// @param tickSpacing The spacing between usable ticks
    /// 两个标记之间的大小
    /// @param lte Whether to search for the next initialized tick to the left (less than or equal to the starting tick)
    /// 是否向左搜索下一个初始化刻度
    /// @return next The next initialized or uninitialized tick up to 256 ticks away from the current tick
    /// 下一个已初始化或未初始化的刻度距当前刻度最多 256 个刻度
    /// @return initialized Whether the next tick is initialized, as the function only searches within up to 256 ticks
    /// 是否初始化下一个刻度，因为该函数仅在最多 256 个刻度内搜索
    function nextInitializedTickWithinOneWord(
        mapping(int16 => uint256) storage self,
        int24 tick,
        int24 tickSpacing,
        bool lte
    ) internal view returns (int24 next, bool initialized) {
        int24 compressed = tick / tickSpacing; //压缩率
        if (tick < 0 && tick % tickSpacing != 0) compressed--; // round towards negative infinity

        if (lte) {
            (int16 wordPos, uint8 bitPos) = position(compressed);
            // all the 1s at or to the right of the current bitPos
            uint256 mask = (1 << bitPos) - 1 + (1 << bitPos);
            uint256 masked = self[wordPos] & mask;

            // if there are no initialized ticks to the right of or at the current tick, return rightmost in the word
            initialized = masked != 0;
            // overflow/underflow is possible, but prevented externally by limiting both tickSpacing and tick
            /*
             next = initialized
                ? (compressed -
                    int24(bitPos - LBitMath.mostSignificantBit(masked))) *
                    tickSpacing
                : (compressed - int24(bitPos)) * tickSpacing;
            */

            next = initialized
                ? (compressed -
                    int24(
                        uint24(bitPos - LBitMath.mostSignificantBit(masked))
                    )) * tickSpacing
                : (compressed - int24(uint24(bitPos))) * tickSpacing;
        } else {
            // start from the word of the next tick, since the current tick state doesn't matter
            (int16 wordPos, uint8 bitPos) = position(compressed + 1);
            // all the 1s at or to the left of the bitPos
            uint256 mask = ~((1 << bitPos) - 1);
            uint256 masked = self[wordPos] & mask;

            // if there are no initialized ticks to the left of the current tick, return leftmost in the word
            initialized = masked != 0;
            // overflow/underflow is possible, but prevented externally by limiting both tickSpacing and tick
            /*
            next = initialized
                ? (compressed +
                    1 +
                    int24(LBitMath.leastSignificantBit(masked) - bitPos)) *
                    tickSpacing
                : (compressed + 1 + int24(type(uint8).max - bitPos)) *
                    tickSpacing;
            */
            next = initialized
                ? (compressed +
                    1 +
                    int24(
                        uint24(LBitMath.leastSignificantBit(masked) - bitPos)
                    )) * tickSpacing
                : (compressed + 1 + int24(uint24(type(uint8).max - bitPos))) *
                    tickSpacing;
        }
    }
}
