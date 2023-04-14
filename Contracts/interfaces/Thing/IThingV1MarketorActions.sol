// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../libraries/base/LThing.sol";

/// @title Permissioned pool actions
/// @notice Contains pool methods that may only be called by the factory owner
interface IThingV1MarketorActions {
    /*
        门户管理币
    */
    function addThingbyMarketor(LThing.Info memory _coinInfo) external;

    function lockThingbyMarketor(address _internalThingAddress) external;

    function unlockThingbyMarketor(address _internalThingAddress) external;

    function updateThingbyMarketor(LThing.Info memory _coinInfo) external;

    function impoveThingbyMarketor(address _contractaddress) external;

    function delMarketThingbyMarketor(address _contractaddress) external;

    function delMarketThingbyMarketor(uint128 _thingNo) external;
}
