// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;
import "../../libraries/base/LGate.sol";

/// @title Permissioned pool actions
/// @notice Contains pool methods that may only be called by the factory owner
interface IGatorV1MarketorActions {
    function lockGatebyMarketor(address _gatoraddress) external;

    function unlockGatebyMarketor(address _gatoraddress) external;

    //提升权威
    //impoveauthrity
    //更新门户内容
    function updateGatebyMarketor(LGate.Info memory _gator) external;

    function delGatebyMarketor(address _gator) external;
}
