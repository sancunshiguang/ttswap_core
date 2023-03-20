// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

/// @title Pool state that never changes
/// @notice These parameters are fixed for a pool forever, i.e., the methods will always return the same values
interface ITTSwapV1MarketImmutables {
    function gatorContractAddress() external view returns (address);

    function marketContractAddress() external view returns (address);

    function marketorContractAddress() external view returns (address);

    function coinContractAddress() external view returns (address);

    function thingContractAddress() external view returns (address);

    function customerContractAddress() external view returns (address);
}
