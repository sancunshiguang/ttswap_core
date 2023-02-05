// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./Manager/IManagerV1Events.sol";
import "./Manager/IManagerV1Immutables.sol";
import "./Manager/IManagerV1MarketCreatorActions.sol";
import "./Manager/IManagerV1State.sol";

/// @title The interface for a Uniswap V3 Pool
/// @notice A Uniswap pool facilitates swapping and automated market making between any two assets that strictly conform
/// to the ERC20 specification
/// @dev The pool interface is broken up into many smaller pieces
interface IMoonV1Manager is
    IManagerV1Events,
    IManagerV1Immutables,
    IManagerV1MarketCreatorActions,
    IManagerV1State
{

}
