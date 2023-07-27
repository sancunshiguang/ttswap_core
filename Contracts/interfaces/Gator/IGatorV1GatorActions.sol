// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;
import "../../libraries/base/LGate.sol";

/// @title Permissioned pool actions
/// @notice Contains pool methods that may only be called by the factory owner
interface IGatorV1GatorActions {
    function lockGatebyGater() external;

    function unlockGatebyGater() external;

    //更新门户内容
    function updateGatebyGator(LGate.Info memory _gator) external;

    //更新门户详情
    function addGaterDetailInfo(
        LGate.DetailInfo memory _gatorDatailinfo
    ) external;
}
