// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../libraries/LProfitShares.sol";

/// @title Permissionless pool actions
/// @notice Contains pool methods that can be called by anyone
interface IMoonV1MarketCreatorActions {
    function setMarketProfitshare(LProfitShares.Info memory) external;

    function setMarketManager(address) external;

    function delMarketManager(address) external;
}
