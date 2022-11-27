// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

/// @title Math library for  Investion
library LInvestionMath {
    /// @notice Add a signed Investion delta to liquidity and revert if it overflows or underflows
    /// @param x The Investion before change
    /// @param y The delta by which Investion should be changed
    /// @return z The Investion delta
    function addDelta(uint128 x, int128 y) internal pure returns (uint128 z) {
        if (y < 0) {
            require((z = x - uint128(-y)) < x, "LS");
        } else {
            require((z = x + uint128(y)) >= x, "LA");
        }
    }
}
