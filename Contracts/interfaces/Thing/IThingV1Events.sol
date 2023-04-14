// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../libraries/base/LThing.sol";

/// @title Events emitted by a pool
/// @notice Contains all events emitted by the pool
interface IThingV1Events {
    event e_addThingbyMarketor(LThing.Info);

    event e_lockThingbyMarketor(address _internalThingAddress);

    event e_unlockThingbyMarketor(address _internalThingAddress);

    event e_updateThingbyMarketor(LThing.Info);

    event e_impoveThingbyMarketor(address _contractaddress);

    event e_delMarketThingbyMarketor(address _contractaddress);

    event e_delMarketThingbyMarketor(uint128 _thingNo);

    event e_unlockThingbyGator(address, address);

    event e_lockThingbyGator(address, address _internalThingAddress);

    event e_updateThingbyGator(address, LThing.Info);

    event e_lockThingbyCreater(address, address _internalThingsAddress);

    event e_unlockThingbyCreater(address, address _internalThingsAddress);

    event e_addThingbyCreator(LThing.Info, address _gateaddress);

    event e_updateThingbyCreator(address, LThing.Info);
}
