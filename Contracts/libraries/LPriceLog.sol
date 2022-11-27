// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/// @title Oracle
/// @notice Provides price and Investion data useful for a wide variety of system designs
/// @dev Instances of stored oracle data, "PriceLogs", are collected in the oracle array
/// Every pool is initialized with an oracle array length of 1. Anyone can pay the SSTOREs to increase the
/// maximum length of the oracle array. New slots will be added when the array is fully populated.
/// PriceLogs are overwritten when the full length of the oracle array is populated.
/// The most recent PriceLog is available, independent of the length of the oracle array, by passing 0 to observe()
library LPriceLog {
    struct PriceLog {
        // the block timestamp of the PriceLog
        uint32 blockTimestamp;
        // the unit accumulator, i.e. unit * time elapsed since the pool was first initialized
        int56 unitCumulative;
        // the seconds per Investion, i.e. seconds elapsed / max(1, Investion) since the pool was first initialized
        uint160 secondsPerInvestionCumulativeX128;
        // whether or not the PriceLog is initialized
        bool initialized;
    }

    /// @notice Transforms a previous PriceLog into a new PriceLog, given the passage of time and
    /// the current unit and Investion values
    /// 记录员
    /// @dev blockTimestamp _must_ be chronologically equal to or greater than last.blockTimestamp, safe for 0 or 1 overflows
    /// @param last The specified PriceLog to be transformed
    /// @param blockTimestamp The timestamp of the new PriceLog
    /// @param unit The active unit at the time of the new PriceLog
    /// @param Investion The total in-range Investion at the time of the new PriceLog
    /// @return PriceLog The newly populated PriceLog
    function transform(
        PriceLog memory last,
        uint32 blockTimestamp,
        int24 unit,
        uint128 Investion
    ) private pure returns (PriceLog memory) {
        uint32 delta = blockTimestamp - last.blockTimestamp;
        return
            PriceLog({
                blockTimestamp: blockTimestamp,
                unitCumulative: last.unitCumulative +
                    int24(unit) *
                    int32(delta),
                secondsPerInvestionCumulativeX128: last
                    .secondsPerInvestionCumulativeX128 +
                    ((uint160(delta) << 128) / (Investion > 0 ? Investion : 1)),
                initialized: true
            });
    }

    /// @notice Initialize the oracle array by writing the first slot. Called once for the lifecycle of the PriceLogs array
    /// @param self The stored oracle array
    /// @param time The time of the oracle initialization, via block.timestamp truncated to uint32
    /// @return cardinality The number of populated elements in the oracle array
    /// @return cardinalityNext The new length of the oracle array, independent of population
    function initialize(PriceLog[65535] storage self, uint32 time)
        internal
        returns (uint16 cardinality, uint16 cardinalityNext)
    {
        self[0] = PriceLog({
            blockTimestamp: time,
            unitCumulative: 0,
            secondsPerInvestionCumulativeX128: 0,
            initialized: true
        });
        return (1, 1);
    }

    /// @notice Writes an oracle PriceLog to the array
    /// @dev Writable at most once per block. Index represents the most recently written element. cardinality and index must be tracked externally.
    /// If the index is at the end of the allowable array length (according to cardinality), and the next cardinality
    /// is greater than the current one, cardinality may be increased. This restriction is created to preserve ordering.
    /// @param self The stored oracle array
    /// @param index The index of the PriceLog that was most recently written to the PriceLogs array
    /// @param blockTimestamp The timestamp of the new PriceLog
    /// @param unit The active unit at the time of the new PriceLog
    /// @param Investion The total in-range Investion at the time of the new PriceLog
    /// @param cardinality The number of populated elements in the oracle array
    /// @param cardinalityNext The new length of the oracle array, independent of population
    /// @return indexUpdated The new index of the most recently written element in the oracle array
    /// @return cardinalityUpdated The new cardinality of the oracle array
    function write(
        PriceLog[65535] storage self,
        uint16 index,
        uint32 blockTimestamp,
        int24 unit,
        uint128 Investion,
        uint16 cardinality,
        uint16 cardinalityNext
    ) internal returns (uint16 indexUpdated, uint16 cardinalityUpdated) {
        PriceLog memory last = self[index];

        // early return if we've already written an PriceLog this block
        if (last.blockTimestamp == blockTimestamp) return (index, cardinality);

        // if the conditions are right, we can bump the cardinality
        if (cardinalityNext > cardinality && index == (cardinality - 1)) {
            cardinalityUpdated = cardinalityNext;
        } else {
            cardinalityUpdated = cardinality;
        }

        indexUpdated = (index + 1) % cardinalityUpdated;
        self[indexUpdated] = transform(last, blockTimestamp, unit, Investion);
    }

    /// @notice Prepares the oracle array to store up to `next` PriceLogs
    /// @param self The stored oracle array
    /// @param current The current next cardinality of the oracle array
    /// @param next The proposed next cardinality which will be populated in the oracle array
    /// @return next The next cardinality which will be populated in the oracle array
    function grow(
        PriceLog[65535] storage self,
        uint16 current,
        uint16 next
    ) internal returns (uint16) {
        require(current > 0, "I");
        // no-op if the passed next value isn't greater than the current next value
        if (next <= current) return current;
        // store in each slot to prevent fresh SSTOREs in swaps
        // this data will not be used because the initialized boolean is still false
        for (uint16 i = current; i < next; i++) self[i].blockTimestamp = 1;
        return next;
    }

    /// @notice comparator for 32-bit timestamps
    /// @dev safe for 0 or 1 overflows, a and b _must_ be chronologically before or equal to time
    /// @param time A timestamp truncated to 32 bits
    /// @param a A comparison timestamp from which to determine the relative position of `time`
    /// @param b From which to determine the relative position of `time`
    /// @return bool Whether `a` is chronologically <= `b`
    function lte(
        uint32 time,
        uint32 a,
        uint32 b
    ) private pure returns (bool) {
        // if there hasn't been overflow, no need to adjust
        if (a <= time && b <= time) return a <= b;

        uint256 aAdjusted = a > time ? a : a + 2**32;
        uint256 bAdjusted = b > time ? b : b + 2**32;

        return aAdjusted <= bAdjusted;
    }

    /// @notice Fetches the PriceLogs beforeOrAt and atOrAfter a target, i.e. where [beforeOrAt, atOrAfter] is satisfied.
    /// The result may be the same PriceLog, or adjacent PriceLogs.
    /// @dev The answer must be contained in the array, used when the target is located within the stored PriceLog
    /// boundaries: older than the most recent PriceLog and younger, or the same age as, the oldest PriceLog
    /// @param self The stored oracle array
    /// @param time The current block.timestamp
    /// @param target The timestamp at which the reserved PriceLog should be for
    /// @param index The index of the PriceLog that was most recently written to the PriceLogs array
    /// @param cardinality The number of populated elements in the oracle array
    /// @return beforeOrAt The PriceLog recorded before, or at, the target
    /// @return atOrAfter The PriceLog recorded at, or after, the target
    function binarySearch(
        PriceLog[65535] storage self,
        uint32 time,
        uint32 target,
        uint16 index,
        uint16 cardinality
    )
        private
        view
        returns (PriceLog memory beforeOrAt, PriceLog memory atOrAfter)
    {
        uint256 l = (index + 1) % cardinality; // oldest PriceLog
        uint256 r = l + cardinality - 1; // newest PriceLog
        uint256 i;
        while (true) {
            i = (l + r) / 2;

            beforeOrAt = self[i % cardinality];

            // we've landed on an uninitialized unit, keep searching higher (more recently)
            if (!beforeOrAt.initialized) {
                l = i + 1;
                continue;
            }

            atOrAfter = self[(i + 1) % cardinality];

            bool targetAtOrAfter = lte(time, beforeOrAt.blockTimestamp, target);

            // check if we've found the answer!
            if (targetAtOrAfter && lte(time, target, atOrAfter.blockTimestamp))
                break;

            if (!targetAtOrAfter) r = i - 1;
            else l = i + 1;
        }
    }

    /// @notice Fetches the PriceLogs beforeOrAt and atOrAfter a given target, i.e. where [beforeOrAt, atOrAfter] is satisfied
    /// @dev Assumes there is at least 1 initialized PriceLog.
    /// Used by observeSingle() to compute the counterfactual accumulator values as of a given block timestamp.
    /// @param self The stored oracle array
    /// @param time The current block.timestamp
    /// @param target The timestamp at which the reserved PriceLog should be for
    /// @param unit The active unit at the time of the returned or simulated PriceLog
    /// @param index The index of the PriceLog that was most recently written to the PriceLogs array
    /// @param Investion The total pool Investion at the time of the call
    /// @param cardinality The number of populated elements in the oracle array
    /// @return beforeOrAt The PriceLog which occurred at, or before, the given timestamp
    /// @return atOrAfter The PriceLog which occurred at, or after, the given timestamp
    function getSurroundingPriceLogs(
        PriceLog[65535] storage self,
        uint32 time,
        uint32 target,
        int24 unit,
        uint16 index,
        uint128 Investion,
        uint16 cardinality
    )
        private
        view
        returns (PriceLog memory beforeOrAt, PriceLog memory atOrAfter)
    {
        // optimistically set before to the newest PriceLog
        beforeOrAt = self[index];

        // if the target is chronologically at or after the newest PriceLog, we can early return
        if (lte(time, beforeOrAt.blockTimestamp, target)) {
            if (beforeOrAt.blockTimestamp == target) {
                // if newest PriceLog equals target, we're in the same block, so we can ignore atOrAfter
                return (beforeOrAt, atOrAfter);
            } else {
                // otherwise, we need to transform
                return (
                    beforeOrAt,
                    transform(beforeOrAt, target, unit, Investion)
                );
            }
        }

        // now, set before to the oldest PriceLog
        beforeOrAt = self[(index + 1) % cardinality];
        if (!beforeOrAt.initialized) beforeOrAt = self[0];

        // ensure that the target is chronologically at or after the oldest PriceLog
        require(lte(time, beforeOrAt.blockTimestamp, target), "OLD");

        // if we've reached this point, we have to binary search
        return binarySearch(self, time, target, index, cardinality);
    }

    /// @dev Reverts if an PriceLog at or before the desired PriceLog timestamp does not exist.
    /// 0 may be passed as `secondsAgo' to return the current cumulative values.
    /// If called with a timestamp falling between two PriceLogs, returns the counterfactual accumulator values
    /// at exactly the timestamp between the two PriceLogs.
    /// @param self The stored oracle array
    /// @param time The current block timestamp
    /// @param secondsAgo The amount of time to look back, in seconds, at which point to return an PriceLog
    /// @param unit The current unit
    /// @param index The index of the PriceLog that was most recently written to the PriceLogs array
    /// @param Investion The current in-range pool Investion
    /// @param cardinality The number of populated elements in the oracle array
    /// @return unitCumulative The unit * time elapsed since the pool was first initialized, as of `secondsAgo`
    /// @return secondsPerInvestionCumulativeX128 The time elapsed / max(1, Investion) since the pool was first initialized, as of `secondsAgo`
    function observeSingle(
        PriceLog[65535] storage self,
        uint32 time,
        uint32 secondsAgo,
        int24 unit,
        uint16 index,
        uint128 Investion,
        uint16 cardinality
    )
        internal
        view
        returns (
            int56 unitCumulative,
            uint160 secondsPerInvestionCumulativeX128
        )
    {
        if (secondsAgo == 0) {
            PriceLog memory last = self[index];
            if (last.blockTimestamp != time)
                last = transform(last, time, unit, Investion);
            return (
                last.unitCumulative,
                last.secondsPerInvestionCumulativeX128
            );
        }

        uint32 target = time - secondsAgo;

        (
            PriceLog memory beforeOrAt,
            PriceLog memory atOrAfter
        ) = getSurroundingPriceLogs(
                self,
                time,
                target,
                unit,
                index,
                Investion,
                cardinality
            );

        if (target == beforeOrAt.blockTimestamp) {
            // we're at the left boundary
            return (
                beforeOrAt.unitCumulative,
                beforeOrAt.secondsPerInvestionCumulativeX128
            );
        } else if (target == atOrAfter.blockTimestamp) {
            // we're at the right boundary
            return (
                atOrAfter.unitCumulative,
                atOrAfter.secondsPerInvestionCumulativeX128
            );
        } else {
            // we're in the middle
            uint32 PriceLogTimeDelta = atOrAfter.blockTimestamp -
                beforeOrAt.blockTimestamp;
            uint32 targetDelta = target - beforeOrAt.blockTimestamp;
            return (
                beforeOrAt.unitCumulative +
                    (((atOrAfter.unitCumulative - beforeOrAt.unitCumulative) /
                        int32(PriceLogTimeDelta)) * int32(targetDelta)),
                beforeOrAt.secondsPerInvestionCumulativeX128 +
                    uint160(
                        ((atOrAfter.secondsPerInvestionCumulativeX128 -
                            beforeOrAt.secondsPerInvestionCumulativeX128) *
                            targetDelta) / PriceLogTimeDelta
                    )
            );
        }
    }

    /// @notice Returns the accumulator values as of each time seconds ago from the given time in the array of `secondsAgos`
    /// @dev Reverts if `secondsAgos` > oldest PriceLog
    /// @param self The stored oracle array
    /// @param time The current block.timestamp
    /// @param secondsAgos Each amount of time to look back, in seconds, at which point to return an PriceLog
    /// @param unit The current unit
    /// @param index The index of the PriceLog that was most recently written to the PriceLogs array
    /// @param Investion The current in-range pool Investion
    /// @param cardinality The number of populated elements in the oracle array
    /// @return unitCumulatives The unit * time elapsed since the pool was first initialized, as of each `secondsAgo`
    /// @return secondsPerInvestionCumulativeX128s The cumulative seconds / max(1, Investion) since the pool was first initialized, as of each `secondsAgo`
    function observe(
        PriceLog[65535] storage self,
        uint32 time,
        uint32[] memory secondsAgos,
        int24 unit,
        uint16 index,
        uint128 Investion,
        uint16 cardinality
    )
        internal
        view
        returns (
            int56[] memory unitCumulatives,
            uint160[] memory secondsPerInvestionCumulativeX128s
        )
    {
        require(cardinality > 0, "I");

        unitCumulatives = new int56[](secondsAgos.length);
        secondsPerInvestionCumulativeX128s = new uint160[](secondsAgos.length);
        for (uint256 i = 0; i < secondsAgos.length; i++) {
            (
                unitCumulatives[i],
                secondsPerInvestionCumulativeX128s[i]
            ) = observeSingle(
                self,
                time,
                secondsAgos[i],
                unit,
                index,
                Investion,
                cardinality
            );
        }
    }
}
