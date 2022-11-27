// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

/// @title Permissioned pool actions
/// @notice Contains pool methods that may only be called by the factory owner
interface IMoonV1ShopOwnerActions {
    /// @notice Set the denominator of the protocol's % share of the fees
    /// @param profitProtocol0 new protocol fee for token0 of the pool
    /// @param profitProtocol1 new protocol fee for token1 of the pool
    function setFeeProtocolbyMarketor(
        uint8 profitProtocol0,
        uint8 profitProtocol1
    ) external;

    /// @notice Collect the protocol fee accrued to the pool
    /// @return amount0 The protocol fee collected in token0
    /// @return amount1 The protocol fee collected in token1
    function collectProtocol()
        external
        returns (uint128 amount0, uint128 amount1);

    function setFeeProfitSharesbyMarketor(
        uint8 _marketshare,
        uint8 _gatershare,
        uint8 _commandershare,
        uint8 _usershare
    ) external;
}
