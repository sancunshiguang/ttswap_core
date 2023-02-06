// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./Coin/ICoinV1Events.sol";
import "./Coin/ICoinV1GatorActions.sol";
import "./Coin/ICoinV1Immutables.sol";
import "./Coin/ICoinV1MarketorActions.sol";
import "./Coin/ICoinV1State.sol";

/// @title The interface for a Uniswap V3 Pool
/// @notice A Uniswap pool facilitates swapping and automated market making between any two assets that strictly conform
/// to the ERC20 specification
/// @dev The pool interface is broken up into many smaller pieces
interface ITTSwapV1Coin is
    ICoinV1Events,
    ICoinV1GatorActions,
    ICoinV1Immutables,
    ICoinV1MarketorActions,
    ICoinV1State
{

}
