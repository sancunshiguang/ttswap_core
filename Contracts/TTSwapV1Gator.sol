// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./libraries/base/LGate.sol";
import "./interfaces/Marketor/IMarketorV1State.sol";

contract TTSwapV1Gator {
    //门户信息
    //Gate Parameter

    mapping(address => LGate.Info) public gateList;

    address public immutable marketorContractAddress;
    address public marketCreator;

    constructor(address _marketorContractAddress, address _marketCreator) {
        marketorContractAddress = _marketorContractAddress;
        marketCreator = _marketCreator;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    modifier onlyGator() {
        require(gateList[msg.sender].marketunlock == true);
        _;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details

    modifier onlyMarketor() {
        require(IMarketorV1State(marketorContractAddress).isValidMarketor());
        _;
    }

    /////////////////////////门户管理-市场////////////////////////////
    ///////////////////////// Gate Manage///////////////////////////
    function lockGatebyMarketor(address _gatoraddress) external onlyMarketor {
        require(
            gateList[_gatoraddress].isUsed == true,
            "the gator isnot exist"
        );
        gateList[_gatoraddress].marketunlock = true;
    }

    function unlockGatebyMarketor(address _gatoraddress) external onlyMarketor {
        require(
            gateList[_gatoraddress].isUsed == true,
            "the gator isnot exist"
        );
        gateList[_gatoraddress].marketunlock = false;
    }

    //提升权威
    //impoveauthrity
    //更新门户内容
    function updateGatebyMarketor(LGate.Info memory _gator)
        external
        onlyMarketor
    {
        require(
            gateList[_gator.gateAddress].isUsed == true,
            "the gator is exister"
        );
        _gator.marketunlock = gateList[_gator.gateAddress].marketunlock;
        _gator.unlock = gateList[_gator.gateAddress].unlock;
        gateList[_gator.gateAddress] = _gator;
    }

    function delGatebyMarketor(address _gator) external onlyMarketor {
        require(gateList[_gator].isUsed == true, "the gator is exister");

        delete gateList[_gator];
    }

    ///////////////////////// 门户管理-门户////////////////////////////
    ///////////////////////// Gate Manage///////////////////////////

    function lockGatebyGater() external onlyGator {
        require(
            gateList[msg.sender].isUsed == true &&
                gateList[msg.sender].gateAddress == msg.sender,
            "the gator isnot exist"
        );
        gateList[msg.sender].unlock = true;
    }

    function unlockGatebyGater() external onlyGator {
        require(
            gateList[msg.sender].isUsed == true &&
                gateList[msg.sender].gateAddress == msg.sender,
            "the gator isnot exist"
        );
        gateList[msg.sender].unlock = false;
    }

    //更新门户内容
    function updateGatebyGator(LGate.Info memory _gator) external onlyGator {
        require(
            gateList[_gator.gateAddress].isUsed == true,
            "the gator is exister"
        );
        require(
            gateList[_gator.gateAddress].gateAddress == msg.sender,
            "the gator is your"
        );
        _gator.marketunlock = false;
        _gator.unlock = true;
        gateList[_gator.gateAddress] = _gator;
    }

    function addGater(LGate.Info memory _gator) external {
        require(
            gateList[_gator.gateAddress].isUsed != true,
            "the gator is exister"
        );
        require(_gator.gateAddress == msg.sender, "the gator is your");

        _gator.marketunlock = false; //默认是被冻结状态
        _gator.unlock = false; //默认是被冻结状态

        gateList[_gator.gateAddress] = _gator; //添加门户信息到门户列表
    }

    function isValidGator() external view returns (bool) {
        return gateList[msg.sender].marketunlock;
    }
}
