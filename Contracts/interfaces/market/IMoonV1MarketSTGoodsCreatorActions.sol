// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../libraries/base/LSTThings.sol";

/// @title Pool state that is not stored
/// @notice Contains view functions to provide information about the pool that is computed rather than stored on the
/// blockchain. The functions here may have variable gas costs.
interface IMoonV1MarketSTThingsCreatorActions {
    function lockGateSTThingsbyCreater(
        address _internalSTThingsAddress,
        address _gateaddress
    ) external;

    function unlockGateSTThingsbyCreater(
        address _internalSTThingsAddress,
        address _gateaddress
    ) external;

    function addGateSTThingsbyCreator(
        LSTThings.Info memory _STThingsInfo,
        address _gateaddress
    ) external;

    function updateGateSTThingsbyCreator(
        LSTThings.Info memory _STThingsInfo,
        address _gateaddress
    ) external;
}
