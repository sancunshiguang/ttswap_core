// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../libraries/base/LCoin.sol";

/// @title Permissioned pool actions
/// @notice Contains pool methods that may only be called by the factory owner
interface ICoinV1GatorActions {
    /*
        门户管理币
    */
    // function addCoinbyGator(LCoin.Info memory _coinInfo) external;

    function unlockCoinbyGator(address _internalCoinAddress) external;

    function lockCoinbyGator(address _internalCoinAddress) external;

    function updateCoinbyGator(
        bytes32 coinFullName, //代币全称
        bytes32 symbol, //币种简称
        bytes32 typecode, //币种类型代码
        uint8 decimals, //精度
        uint256 maxSupply, //流通量
        uint256 totalSupply, //发行量
        address contractAddress //合约地址
    ) external;

    function delCoinbyGator(uint128 _coinNo) external;

    function delCoinbyGator(address _contractaddress) external;

    // function addCoinDetailInfobyGator(
    //     LCoin.DetailInfo memory _coinDetailInfo
    // ) external;

    function addCoinFullinfobyGator(
        LCoin.Info memory _coinInfo,
        LCoin.DetailInfo memory _coinDetailInfo
    ) external;
}
