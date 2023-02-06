// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;
import "../../libraries/base/LCustomer.sol";

/// @title Permissioned pool actions
/// @notice Contains pool methods that may only be called by the factory owner
interface ICustomerV1CustomerActions {
    //推荐者提供码,用户进行扫码或者输入推荐者的信息
    function addRelation(uint40 _recommanderUnikey) external;

    //用户增加
    function addCustomer(LCustomer.Info memory _customer) external;

    function updateCustomerNeckName(bytes32 _newname) external;

    function addCustomer(LCustomer.Info memory _customer, address _gator)
        external;
}
