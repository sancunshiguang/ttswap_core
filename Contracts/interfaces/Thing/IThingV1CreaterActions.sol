// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../libraries/base/LThing.sol";

/// @title Permissioned pool actions
/// @notice Contains pool methods that may only be called by the factory owner
interface IThingV1CreaterActions {
    function lockThingbyCreater(address _internalThingsAddress) external;

    function unlockThingbyCreater(address _internalThingsAddress) external;

    function addThingbyCreator(
        LThing.Info memory _thingsInfo,
        address _gateaddress
    ) external;

    function updateThingbyCreator(LThing.Info memory _ThingsInfo) external;
}
