// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../libraries/base/LCustomer.sol";

/// @title Events emitted by a pool
/// @notice Contains all events emitted by the pool
interface ICustomerV1Events {
    event e_addRelation(address, uint128 _recommanderUnikey);
    event e_updateCustomerNeckName(address, bytes32 _newname);
    event e_addCustomer(LCustomer.Info, address _gator);
    event e_lockCustomerbyMarketor(address _CustomerAddress);
    event e_unlockCustomerbyMarketor(address _CustomerAddress);
}
