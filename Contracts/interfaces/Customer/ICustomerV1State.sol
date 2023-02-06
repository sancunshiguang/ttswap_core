// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../libraries/base/LCustomer.sol";

/// @title Pool state that can change
/// @notice These methods compose the pool's state, and can change with any frequency including multiple times
/// per transaction
interface ICustomerV1State {
    function getCustomer(address _CustomerAddress)
        external
        view
        returns (LCustomer.Info memory);

    function isValidCustomer(address _CustomerAddress)
        external
        view
        returns (bool);

    function getCustomerRecommander(address _customer)
        external
        view
        returns (address);

    function getCustomerNumbyRecommander(address _recommander)
        external
        view
        returns (uint32);

    function getCustomerInfobyRecommander(
        address _recommander,
        uint32 _cumstomerindex
    ) external view returns (address);
}
