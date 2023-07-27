// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../libraries/base/LThing.sol";

/// @title Pool state that can change
/// @notice These methods compose the pool's state, and can change with any frequency including multiple times
/// per transaction
interface IThingV1State {
    function getThingInfoFromaddress(
        address _contractaddress
    ) external view returns (LThing.Info memory);

    function getThingInfoOwnerNo(
        address _owneraddress,
        uint128 _ThingNo
    ) external view returns (LThing.Info memory);

    function getThingMaxNo(
        address _owneraddress
    ) external view returns (uint128);

    function isValidThing(address _thing) external view returns (bool);
}
