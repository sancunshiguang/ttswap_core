// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../libraries/base/LCoin.sol";
import "../../libraries/base/LSTThings.sol";
import "../../libraries/base/LGate.sol";
import "../../libraries/base/LCustomer.sol";

/// @title Pool state that can change
/// @notice These methods compose the pool's state, and can change with any frequency including multiple times
/// per transaction
interface IManagerV1State {
    function ismarketManager() external view returns (bool);
}
