// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../libraries/base/LThing.sol";

/// @title Permissioned pool actions
/// @notice Contains pool methods that may only be called by the factory owner
interface IThingV1GaterActions {
    /*
        门户管理币
    */

    function unlockThingbyGator(address _internalThingAddress) external;

    function lockThingbyGator(address _internalThingAddress) external;

    function updateThingbyGator(LThing.Info memory _coinInfo) external;
}
