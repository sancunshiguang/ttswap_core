// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./market/ITTSwapV1MarketImmutables.sol";
import "./market/ITTSwapV1MarketState.sol";
import "./market/ITTSwapV1MarketDerivedState.sol";
import "./market/ITTSwapV1MarketCreatorActions.sol";
import "./market/ITTSwapV1MarketManagerActions.sol";
import "./market/ITTSwapV1MarketGatorActions.sol";
import "./market/ITTSwapV1MarketEvents.sol";

interface ITTSwapV1Market is
    ITTSwapV1MarketImmutables,
    ITTSwapV1MarketState,
    ITTSwapV1MarketDerivedState,
    ITTSwapV1MarketCreatorActions,
    ITTSwapV1MarketManagerActions,
    ITTSwapV1MarketGatorActions,
    ITTSwapV1MarketEvents
{}
