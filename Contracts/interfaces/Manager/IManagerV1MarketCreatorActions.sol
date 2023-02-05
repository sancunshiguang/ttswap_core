// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../libraries/base/LCoin.sol";
import "../../libraries/base/LSTThings.sol";
import "../../libraries/base/LGate.sol";

/// @title Permissioned pool actions
/// @notice Contains pool methods that may only be called by the factory owner
interface IManagerV1MarketCreatorActions {
    function setMarketManager(address _owner) external;

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function delMarketManager(address _owner) external;
}
