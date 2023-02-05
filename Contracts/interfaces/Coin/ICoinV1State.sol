// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../libraries/base/LCoin.sol";

/// @title Pool state that can change
/// @notice These methods compose the pool's state, and can change with any frequency including multiple times
/// per transaction
interface ICoinV1State {
    function getCoinInfo(address _contractaddress)
        external
        view
        returns (LCoin.Info memory);
}
