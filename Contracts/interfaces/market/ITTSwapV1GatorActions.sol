// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../libraries/base/LCoin.sol";
import "../../libraries/base/LThing.sol";
import "../../libraries/base/LGate.sol";

/// @title Permissioned pool actions
/// @notice Contains pool methods that may only be called by the factory owner
interface ITTSwapV1GatorActions {
    /*
        门户管理币
    */
    function addCoinbyGator(LCoin.Info memory) external;

    function unlockCoinbyGator(address) external;

    function lockCoinbyGator(address) external;

    function updateCoinbyGator(LCoin.Info memory) external;

    /*
        门户管理物品
    */
    function lockSTGoodsbyGator(address) external;

    function unlockSTGoodsbyGator(address) external;

    function updateSTGoodsbyGator(LThing.Info memory) external;

    /*
        门户管理门户
    */

    function lockGatebyGater() external;

    function unlockGatebyGater() external;

    function updateGatebyGator(LGate.Info memory) external;

    function createShopbyGator(
        address _coin,
        address _thing,
        uint24 _profit
    ) external returns (address shop);
}
