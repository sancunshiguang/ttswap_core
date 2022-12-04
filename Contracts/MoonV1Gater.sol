// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./libraries/base/LGate.sol";
import "./MoonV1Manager.sol";

contract MoonV1Gater {
    //门户信息
    //Gate Parameter
    address public immutable override marketCreator;

    constructor() {
        marketCreator = msg.sender;
    }

    mapping(address => LGate.Info) public gateList;

    modifier onlyMarketCreator() {
        require(msg.sender == marketCreator);
        _;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    modifier onlyMarketManager() {
        require(
            MoonV1Manager(marketCreator).ismarketManager[msg.sender] == true
        );
        _;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    modifier onlyGator() {
        require(gateList[msg.sender].marketunlock == true);
        _;
    }

    /////////////////////////门户管理-市场////////////////////////////
    ///////////////////////// Gate Manage///////////////////////////
    function lockGatebyMarketor(address _gateraddress)
        external
        override
        onlyMarketManager
    {
        require(
            gateList[_gateraddress].isUsed == true,
            "the gater isnot exist"
        );
        gateList[_gateraddress].marketunlock = true;
    }

    function unlockGatebyMarketor(address _gateraddress)
        external
        override
        onlyMarketManager
    {
        require(
            gateList[_gateraddress].isUsed == true,
            "the gater isnot exist"
        );
        gateList[_gateraddress].marketunlock = false;
    }

    //提升权威
    //impoveauthrity
    //更新门户内容
    function updateGatebyMarketor(LGate.Info memory _gater)
        external
        override
        onlyMarketManager
    {
        require(
            gateList[_gater.gateAddress].isUsed == true,
            "the gater is exister"
        );
        _gater.marketunlock = gateList[_gater.gateAddress].marketunlock;
        _gater.unlock = gateList[_gater.gateAddress].unlock;
        gateList[_gater.gateAddress] = _gater;
    }

    function delGatebyMarketor(address _gater)
        external
        override
        onlyMarketManager
    {
        require(gateList[_gater].isUsed == true, "the gater is exister");

        delete gateList[_gater];
    }

    ///////////////////////// 门户管理-门户////////////////////////////
    ///////////////////////// Gate Manage///////////////////////////

    function lockGatebyGater() external override onlyGator {
        require(
            gateList[msg.sender].isUsed == true &&
                gateList[msg.sender].gateAddress == msg.sender,
            "the gater isnot exist"
        );
        gateList[msg.sender].unlock = true;
    }

    function unlockGatebyGater() external override onlyGator {
        require(
            gateList[msg.sender].isUsed == true &&
                gateList[msg.sender].gateAddress == msg.sender,
            "the gater isnot exist"
        );
        gateList[msg.sender].unlock = false;
    }

    //更新门户内容
    function updateGatebyGator(LGate.Info memory _gater)
        external
        override
        onlyGator
    {
        require(
            gateList[_gater.gateAddress].isUsed == true,
            "the gater is exister"
        );
        require(
            gateList[_gater.gateAddress].gateAddress == msg.sender,
            "the gater is your"
        );
        _gater.marketunlock = false;
        _gater.unlock = true;
        gateList[_gater.gateAddress] = _gater;
    }

    function addGater(LGate.Info memory _gater) external override {
        require(
            gateList[_gater.gateAddress].isUsed != true,
            "the gater is exister"
        );
        require(_gater.gateAddress == msg.sender, "the gater is your");

        _gater.marketunlock = false; //默认是被冻结状态
        _gater.unlock = false; //默认是被冻结状态
        gateCustomerNextKey[_gater.gateAddress] = 0; //初始化门户用户数据为0
        gateList[_gater.gateAddress] = _gater; //添加门户信息到门户列表
    }
}
