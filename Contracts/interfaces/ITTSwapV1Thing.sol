// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./Thing/IThingV1Events.sol";
import "./Thing/IThingV1GatorActions.sol";
import "./Thing/IThingV1Immutables.sol";
import "./Thing/IThingV1MarketorActions.sol";
import "./Thing/IThingV1State.sol";
import "./Thing/IThingV1CreaterActions.sol";

/// @title The interface for a Uniswap V3 Pool
/// @notice A Uniswap pool facilitates swapping and automated market making between any two assets that strictly conform
/// to the ERC20 specification
/// @dev The pool interface is broken up into many smaller pieces
interface ITTSwapV1Thing is
    IThingV1Events,
    IThingV1GatorActions,
    IThingV1Immutables,
    IThingV1MarketorActions,
    IThingV1State,
    IThingV1CreaterActions
{

}
