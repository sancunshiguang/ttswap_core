// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./shop/IMoonV1ShopActions.sol";
import "./shop/IMoonV1ShopDerivedState.sol";
import "./shop/IMoonV1ShopEvents.sol";
import "./shop/IMoonV1ShopImmutables.sol";
import "./shop/IMoonV1ShopOwnerActions.sol";
import "./shop/IMoonV1ShopState.sol";

interface ITTSwapV1Shop is
    IMoonV1ShopActions,
    IMoonV1ShopDerivedState,
    IMoonV1ShopEvents,
    IMoonV1ShopImmutables,
    IMoonV1ShopState,
    IMoonV1ShopOwnerActions
{}
