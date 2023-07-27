// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;
import "../../libraries/base/LCoin.sol";

/// @title Events emitted by a pool
/// @notice Contains all events emitted by the pool
interface ICoinV1Events {
    event e_addCoinbyGator(address, LCoin.Info);

    event e_unlockCoinbyGator(address, address);

    event e_lockCoinbyGator(address, address);

    event e_updateCoinbyGator(address, LCoin.Info);

    event e_delCoinbyGator(address, uint128);

    event e_delCoinbyGator(address, address);

    event e_addCoinbyMarketor(LCoin.Info);

    event e_lockCoinbyMarketor(address);

    event e_unlockCoinbyMarketor(address);

    event e_updateCoinbyMarketor(LCoin.Info);

    event e_impoveGateCoinbyMarketor(address);

    event e_delCoinbyMarketor(address);

    event e_delCoinbyMarketor(uint128);

    event e_addCoinDetailbyGator(address);
}
