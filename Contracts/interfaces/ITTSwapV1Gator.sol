// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./Gator/IGatorV1CustomerActions.sol";
import "./Gator/IGatorV1Events.sol";
import "./Gator/IGatorV1GatorActions.sol";
import "./Gator/IGatorV1Immutables.sol";
import "./Gator/IGatorV1MarketorActions.sol";
import "./Gator/IGatorV1State.sol";

/// @title The interface for a Uniswap V3 Pool
/// @notice A Uniswap pool facilitates swapping and automated market making between any two assets that strictly conform
/// to the ERC20 specification
/// @dev The pool interface is broken up into many smaller pieces
interface ITTSwapV1Gator is
    IGatorV1CustomerActions,
    IGatorV1Events,
    IGatorV1GatorActions,
    IGatorV1Immutables,
    IGatorV1MarketorActions,
    IGatorV1State
{

}
