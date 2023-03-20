// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;
import "../../libraries/base/LCoin.sol";
import "../../libraries/LProfitShares.sol";

/// @title Permissionless pool actions
/// @notice Contains market methods that can be called by MarketManagers
interface ITTSwapV1MarketorActions {
    function setMarketProfitshareByMarketor(
        LProfitShares.Info memory _profitshare
    ) external;
}
