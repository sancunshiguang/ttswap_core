// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./shop/IMoonV1ShopImmutables.sol";
import "./shop/IMoonV1ShopState.sol";
import "./shop/IMoonV1ShopDerivedState.sol";
import "./shop/IMoonV1ShopActions.sol";
import "./shop/IMoonV1ShopOwnerActions.sol";
import "./shop/IMoonV1ShopEvents.sol";

/// @title The interface for a Uniswap V3 Pool
/// @notice A Uniswap pool facilitates swapping and automated market making between any two assets that strictly conform
/// to the ERC20 specification
/// @dev The pool interface is broken up into many smaller pieces
interface IMoonV1Shop is
    IMoonV1ShopImmutables,
    IMoonV1ShopState,
    IMoonV1ShopDerivedState,
    IMoonV1ShopActions,
    IMoonV1ShopOwnerActions,
    IMoonV1ShopEvents
{

}
