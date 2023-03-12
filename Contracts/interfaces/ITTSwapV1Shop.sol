// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./Shop/ITTSwapV1ShopActions.sol";
import "./Shop/ITTSwapV1ShopDerivedState.sol";
import "./Shop/ITTSwapV1ShopEvents.sol";
import "./Shop/ITTSwapV1ShopImmutables.sol";
import "./Shop/ITTSwapV1ShopOwnerActions.sol";
import "./Shop/ITTSwapV1ShopState.sol";

interface ITTSwapV1Shop is
    ITTSwapV1ShopActions,
    ITTSwapV1ShopDerivedState,
    ITTSwapV1ShopEvents,
    ITTSwapV1ShopImmutables,
    ITTSwapV1ShopState,
    ITTSwapV1ShopOwnerActions
{}
