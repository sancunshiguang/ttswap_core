// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../libraries/base/LCoin.sol";

/// @title Permissioned pool actions
/// @notice Contains pool methods that may only be called by the factory owner
interface ICoinV1MarketorActions {
    /*
        门户管理币
    */
    function addCoinbyMarketor(LCoin.Info memory _coinInfo) external;

    function lockCoinbyMarketor(address _internalCoinAddress) external;

    function unlockCoinbyMarketor(address _internalCoinAddress) external;

    function updateCoinbyMarketor(LCoin.Info memory _coinInfo) external;

    function impoveGateCoinbyMarketor(address _contractaddress) external;

    function delCoinbyMarketor(address _contractaddress) external;

    function delCoinbyMarketor(uint128 _coinNo) external;

    function addCoinDetailInfobyMarketor(
        LCoin.DetailInfo memory _coinDetailInfo
    ) external;

    function addCoinFullinfobyMarketor(
        LCoin.Info memory _coinInfo,
        LCoin.DetailInfo memory _coinDetailInfo
    ) external;
}
