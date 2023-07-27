// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../libraries/base/LGate.sol";

/// @title Pool state that can change
/// @notice These methods compose the pool's state, and can change with any frequency including multiple times
/// per transaction
interface IGatorV1State {
    function isValidGator() external view returns (bool);

    function isValidGatorFromAddress(
        address vgaddress
    ) external view returns (bool);

    function getGaterNo() external view returns (uint128);

    function getGaterNoFromAddress(
        address _gateAddress
    ) external view returns (uint128);

    function getGaterInfo(
        uint8 _gateNumber
    ) external view returns (LGate.Info memory);

    function getMaxGateNumber() external view returns (uint128);

    function getGaterDetailInfo(
        address _gateaddress
    ) external view returns (LGate.DetailInfo memory);
}
