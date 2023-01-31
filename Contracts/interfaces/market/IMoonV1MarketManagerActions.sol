// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;
import "../../libraries/base/LCoin.sol";
import "../../libraries/base/LSTThings.sol";
import "../../libraries/base/LGate.sol";

/// @title Permissionless pool actions
/// @notice Contains market methods that can be called by MarketManagers
interface IMoonV1MarketManagerActions {
    /*
        市场管理员管理币
    */
    function addCoinbyMarketor(LCoin.Info memory _coinInfo) external;

    function changeCoinScopebyMarketor(
        address _internalCoinAddress,
        uint8 _scope
    ) external;

    function lockCoinbyMarketor(address _internalCoinAddress) external;

    function unlockCoinbyMarketor(address _internalCoinAddress) external;

    function updateCoinbyMarketor(LCoin.Info memory _coinInfo) external;

    function impoveGateCoinbyMarketor(
        address _contractaddress,
        address _gateaddress
    ) external;

    function delGateCoinbyMarketor(
        address _contractaddress,
        address _gateaddress
    ) external;

    function delCoinbyMarketor(address _contractaddress) external;

    /*
        市场管理员管理物品
    */

    function addSTThingsbyMarketor(LSTThings.Info memory _STThingInfo) external;

    function changeSTThingsScopebyMarketor(
        address _internalSTThingsAddress,
        uint8 _scope
    ) external;

    function lockSTThingsbyMarketor(address _internalSTThingsAddress) external;

    function unlockSTThingsbyMarketor(address _internalSTThingsAddress)
        external;

    function updateSTThingsbyMarketor(LSTThings.Info memory _STThingInfo)
        external;

    function impoveGateSTThingsbyMarketor(
        address _contractaddress,
        address _gateaddress
    ) external;

    function delSTThingsbyMarketor(LSTThings.Info memory _STThingInfo) external;

    function delGateSTThingsbyMarketor(
        address _contractaddress,
        address _gateaddress
    ) external;

    /*
        市场管理员管理客户
    */

    function lockCustomerbyMarketor(address _CustomerAddress) external;

    function unlockCustomerbyMarketor(address _CustomerAddress) external;

    /*
        市场管理员管理门户
    */

    function lockGatebyMarketor(address _gateraddress) external;

    function unlockGatebyMarketor(address _gateraddress) external;

    function updateGatebyMarketor(LGate.Info memory _gater) external;

    function delGatebyMarketor(address _gater) external;

    function createShopbyMarketor(
        address _coin,
        address _thing,
        uint24 _profit
    ) external returns (address shop);

    function raiseShopLevelbyMarketor(address shop) external;
}
