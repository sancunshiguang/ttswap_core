// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./Customer/ICustomerV1Events.sol";
import "./Customer/ICustomerV1Immutables.sol";
import "./Customer/ICustomerV1State.sol";
import "./Customer/ICustomerV1CustomerActions.sol";
import "./Customer/ICustomerV1GatorActions.sol";
import "./Customer/ICustomerV1MarketorActions.sol";

/// @title The interface for a Uniswap V3 Pool
/// @notice A Uniswap pool facilitates swapping and automated market making between any two assets that strictly conform
/// to the ERC20 specification
/// @dev The pool interface is broken up into many smaller pieces
interface ITTSwapV1Customer is
    ICustomerV1Events,
    ICustomerV1Immutables,
    ICustomerV1State,
    ICustomerV1CustomerActions,
    ICustomerV1GatorActions,
    ICustomerV1MarketorActions
{

}
