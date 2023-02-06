// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./market/IMoonV1MarketImmutables.sol";
import "./market/IMoonV1MarketState.sol";
import "./market/IMoonV1MarketDerivedState.sol";
import "./market/IMoonV1MarketCreatorActions.sol";
import "./market/IMoonV1MarketManagerActions.sol";
import "./market/IMoonV1MarketGatorActions.sol";
import "./market/IMoonV1MarketEvents.sol";

interface IMoonV1Market is
    IMoonV1MarketImmutables,
    IMoonV1MarketState,
    IMoonV1MarketDerivedState,
    IMoonV1MarketCreatorActions,
    IMoonV1MarketManagerActions,
    IMoonV1MarketGatorActions,
    IMoonV1MarketEvents
{}
