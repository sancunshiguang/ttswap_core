// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../libraries/base/LSTGoods.sol";

/// @title Pool state that is not stored
/// @notice Contains view functions to provide information about the pool that is computed rather than stored on the
/// blockchain. The functions here may have variable gas costs.
interface IMoonV1MarketSTGoodsCreatorActions {
    function lockGateSTGoodsbyCreater(
        address _internalSTGoodsAddress,
        address _gateaddress
    ) external;

    function unlockGateSTGoodsbyCreater(
        address _internalSTGoodsAddress,
        address _gateaddress
    ) external;

    function addGateSTGoodsbyCreator(
        LSTGoods.Info memory _STGoodsInfo,
        address _gateaddress
    ) external;

    function updateGateSTGoodsbyCreator(
        LSTGoods.Info memory _STGoodsInfo,
        address _gateaddress
    ) external;
}
