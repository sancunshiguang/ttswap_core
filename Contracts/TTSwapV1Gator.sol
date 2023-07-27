// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./libraries/base/LGate.sol";
import "./interfaces/Marketor/IMarketorV1State.sol";
import "./TTSwapV1Marketor.sol";
import "./interfaces/ITTSwapV1Gator.sol";

contract TTSwapV1Gator is ITTSwapV1Gator {
    //门户信息
    //Gate Parameter

    mapping(address => LGate.Info) public gateList;
    mapping(address => LGate.DetailInfo) public gateDetailList;
    //记录门户编号
    mapping(uint128 => address) public gateNumbers;
    //记录门户最大编号
    uint128 public maxGateNumbers;

    address public marketorContractAddress;
    address public marketCreator;

    constructor(address _marketorContractAddress, address _marketCreator) {
        marketorContractAddress = _marketorContractAddress;
        marketCreator = _marketCreator;
        maxGateNumbers = 1;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    modifier onlyGator() {
        require(gateList[msg.sender].marketunlock == true);
        _;
    }
    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    modifier onlyMarketCreator() {
        require(marketCreator == msg.sender, "you are not marketcreater");
        _;
    }
    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details

    modifier onlyMarketor() {
        require(
            IMarketorV1State(marketorContractAddress).isValidMarketor(
                msg.sender
            ),
            "you are marketor"
        );
        _;
    }

    function setGaterEnv(
        address _marketorContractAddress,
        address _marketCreator
    ) external onlyMarketCreator {
        marketorContractAddress = _marketorContractAddress;
        marketCreator = _marketCreator;
    }

    /////////////////////////门户管理-市场////////////////////////////
    ///////////////////////// Gate Manage///////////////////////////
    function lockGatebyMarketor(
        address _gatoraddress
    ) external override onlyMarketor {
        require(
            gateList[_gatoraddress].isUsed == true,
            "the gator isnot exist"
        );
        gateList[_gatoraddress].marketunlock = false;
        emit e_lockGatebyMarketor(_gatoraddress, msg.sender);
    }

    function unlockGatebyMarketor(
        address _gatoraddress
    ) external override onlyMarketor {
        require(
            gateList[_gatoraddress].isUsed == true,
            "the gator isnot exist"
        );
        gateList[_gatoraddress].marketunlock = true;
        emit e_unlockGatebyMarketor(_gatoraddress, msg.sender);
    }

    //提升权威
    //impoveauthrity
    //更新门户内容
    function updateGatebyMarketor(
        LGate.Info memory _gator
    ) external override onlyMarketor {
        require(
            gateList[_gator.gateAddress].isUsed == true,
            "the gator is exister"
        );
        _gator.marketunlock = gateList[_gator.gateAddress].marketunlock;
        _gator.gateunlock = gateList[_gator.gateAddress].gateunlock;
        gateList[_gator.gateAddress] = _gator;
        emit e_updateGatebyMarketor(
            _gator.gateAddress,
            _gator.name,
            msg.sender
        );
    }

    function delGatebyMarketor(address _gator) external override onlyMarketor {
        require(gateList[_gator].isUsed == true, "the gator is exister");

        delete gateList[_gator];
        emit e_delGatebyMarketor(_gator, msg.sender);
    }

    ///////////////////////// 门户管理-门户////////////////////////////
    ///////////////////////// Gate Manage///////////////////////////

    function lockGatebyGater() external override onlyGator {
        require(
            gateList[msg.sender].isUsed == true &&
                gateList[msg.sender].gateAddress == msg.sender,
            "the gator isnot exist"
        );
        gateList[msg.sender].gateunlock = false;

        emit e_lockGatebyGater(msg.sender);
    }

    function unlockGatebyGater() external override onlyGator {
        require(
            gateList[msg.sender].isUsed == true &&
                gateList[msg.sender].gateAddress == msg.sender,
            "the gator isnot exist"
        );
        gateList[msg.sender].gateunlock = true;
        emit e_unlockGatebyGater(msg.sender);
    }

    //更新门户内容
    function updateGatebyGator(
        LGate.Info memory _gator
    ) external override onlyGator {
        require(
            gateList[_gator.gateAddress].isUsed == true,
            "the gator is exister"
        );
        require(
            gateList[_gator.gateAddress].gateAddress == msg.sender,
            "the gator is your"
        );
        _gator.marketunlock = gateList[_gator.gateAddress].marketunlock;
        _gator.gateunlock = gateList[_gator.gateAddress].gateunlock;
        gateList[_gator.gateAddress] = _gator;
        emit e_updateGatebyGator(_gator.gateAddress, _gator.name);
    }

    function addGater(LGate.Info memory _gator) external override {
        require(
            gateList[_gator.gateAddress].isUsed != true,
            "the gator is exister"
        );
        require(_gator.gateAddress == msg.sender, "the gator is your");

        _gator.marketunlock = false; //默认是被冻结状态
        _gator.gateunlock = false; //默认是被冻结状态
        _gator.gateNo = maxGateNumbers; //门户编号
        _gator.createtimestamp = block.timestamp; //创建时间
        require(maxGateNumbers + 1 > maxGateNumbers, "the gator is your");
        gateList[_gator.gateAddress] = _gator; //添加门户信息到门户列表
        gateNumbers[maxGateNumbers] = _gator.gateAddress;
        maxGateNumbers += 1;
        emit e_addGater(_gator.gateAddress, _gator.name);
    }

    function addGaterDetailInfo(
        LGate.DetailInfo memory _gatorDatailinfo
    ) external override {
        require(gateList[msg.sender].isUsed == true, "the gator is not exist");
        gateDetailList[msg.sender] = _gatorDatailinfo;
        emit e_addGaterDetail(msg.sender);
    }

    function getGaterDetailInfo(
        address _gateaddress
    ) external view override returns (LGate.DetailInfo memory) {
        return gateDetailList[_gateaddress];
    }

    function isValidGator() external view override returns (bool) {
        return gateList[msg.sender].marketunlock;
    }

    function isValidGatorFromAddress(
        address vgaddress
    ) external view override returns (bool) {
        return gateList[vgaddress].marketunlock;
    }

    function getGaterNo() external view override returns (uint128) {
        return gateList[msg.sender].gateNo;
    }

    function getGaterNoFromAddress(
        address _gateAddress
    ) external view override returns (uint128) {
        return gateList[_gateAddress].gateNo;
    }

    function getGaterInfo(
        uint8 _gateNumber
    ) external view override returns (LGate.Info memory) {
        return gateList[gateNumbers[_gateNumber]];
    }

    function getMaxGateNumber() external view override returns (uint128) {
        return maxGateNumbers;
    }
}
