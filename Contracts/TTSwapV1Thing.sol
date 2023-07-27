// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;
import "./libraries/base/LThing.sol";
import "./interfaces/Marketor/IMarketorV1State.sol";
import "./interfaces/Gator/IGatorV1State.sol";
import "./interfaces/ITTSwapV1Thing.sol";

contract TTSwapV1Thing is ITTSwapV1Thing {
    //owneraddress => thingMaxNo
    mapping(address => uint128) public thingMaxNo;
    //门户物品信息
    //owneraddress => thingNo => thingaddress
    mapping(address => mapping(uint128 => address)) public ownerThingList;
    //owneraddress => thingaddress=>thingNo
    mapping(address => mapping(address => uint128)) public ownerThingNo;

    //标准物品
    //标准物品地址 => 标准物品信息
    //thingaddress => thingInfo
    mapping(address => LThing.Info) public ThingsList;
    //thingaddress => thingDetailInfo
    mapping(address => LThing.DetailInfo) public ThingsDetailList;

    address public gatorContractAddress;
    address public marketorContractAddress;
    address public marketCreator;

    constructor(
        address _gatorContractAddress,
        address _marketorContractAddress
    ) {
        gatorContractAddress = _gatorContractAddress;
        marketorContractAddress = _marketorContractAddress;
        marketCreator = msg.sender;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    modifier onlyGator() {
        require(IGatorV1State(gatorContractAddress).isValidGator());
        _;
    }

    modifier onlyMarketor() {
        require(IMarketorV1State(marketorContractAddress).isValidMarketor());
        _;
    }
    modifier onlyMarketCreator() {
        require(marketCreator == msg.sender, "you are not marketcreater");
        _;
    }

    function setThingEnv(
        address _marketorContractAddress,
        address _gatorContractAddress,
        address _marketCreator
    ) external onlyMarketCreator {
        marketorContractAddress = _marketorContractAddress;
        gatorContractAddress = _gatorContractAddress;
        marketCreator = _marketCreator;
    }

    /////////////////////////物品设置-市场/////////////////////
    /////////////////////////things Manage/////////////////////
    function addThingbyMarketor(
        LThing.Info memory _thingsInfo
    ) external override onlyMarketor {
        require(
            ThingsList[_thingsInfo.contractAddress].isUsed != true,
            "the things exist"
        );
        _thingsInfo.creator = msg.sender;
        _thingsInfo.marketunlock = true;
        _thingsInfo.gateunlock = true;
        _thingsInfo.isUsed = true;
        ThingsList[_thingsInfo.contractAddress] = _thingsInfo;
        emit e_addThingbyMarketor(_thingsInfo);
    }

    function lockThingbyMarketor(
        address _internalThingsAddress
    ) external override onlyMarketor {
        ThingsList[_internalThingsAddress].marketunlock = false;
        emit e_lockThingbyMarketor(_internalThingsAddress);
    }

    function unlockThingbyMarketor(
        address _internalThingsAddress
    ) external override onlyMarketor {
        ThingsList[_internalThingsAddress].marketunlock = true;
        emit e_unlockThingbyMarketor(_internalThingsAddress);
    }

    function updateThingbyMarketor(
        LThing.Info memory _thingsInfo
    ) external override onlyMarketor {
        require(
            ownerThingNo[marketorContractAddress][
                _thingsInfo.contractAddress
            ] >= 0,
            "the Thing don't exist in the market"
        );
        _thingsInfo.marketunlock = true;
        _thingsInfo.gateunlock = false;
        _thingsInfo.isUsed = true;
        ThingsList[_thingsInfo.contractAddress] = _thingsInfo;
        emit e_updateThingbyMarketor(_thingsInfo);
    }

    function impoveThingbyMarketor(
        address _contractaddress
    ) external override onlyMarketor {
        uint128 thing_MaxNo = thingMaxNo[marketorContractAddress];
        if (thing_MaxNo >= 1 && thing_MaxNo + 1 >= thing_MaxNo) {
            thing_MaxNo += 1;
        } else {
            thing_MaxNo = 1;
        }
        thingMaxNo[marketorContractAddress] = thing_MaxNo;
        ownerThingList[marketorContractAddress][thing_MaxNo] = _contractaddress;

        ownerThingNo[marketorContractAddress][_contractaddress] = thing_MaxNo;
        emit e_impoveThingbyMarketor(_contractaddress);
    }

    function delMarketThingbyMarketor(
        address _contractaddress
    ) external override onlyMarketor {
        require(
            ownerThingNo[marketorContractAddress][_contractaddress] >= 1,
            "the Thing is not exists"
        );

        delete ownerThingList[marketorContractAddress][
            ownerThingNo[marketorContractAddress][_contractaddress]
        ];
        delete ownerThingNo[marketorContractAddress][_contractaddress];
        emit e_delMarketThingbyMarketor(_contractaddress);
    }

    function delMarketThingbyMarketor(uint128 _thingNo) external onlyMarketor {
        require(
            ownerThingList[marketorContractAddress][_thingNo] != address(0),
            "the Thing is not exists"
        );

        delete ownerThingNo[marketorContractAddress][
            ownerThingList[marketorContractAddress][_thingNo]
        ];
        delete ownerThingList[marketorContractAddress][_thingNo];
        emit e_delMarketThingbyMarketor(_thingNo);
    }

    /////////////////////////物品设置-门户/////////////////////
    /////////////////////////things Manage/////////////////////

    function unlockThingbyGator(
        address _internalThingsAddress
    ) external override onlyGator {
        require(
            ThingsList[_internalThingsAddress].addfromgator == msg.sender,
            "you have not the right"
        );
        ThingsList[_internalThingsAddress].gateunlock = true;
        emit e_unlockThingbyGator(msg.sender, _internalThingsAddress);
    }

    function lockThingbyGator(
        address _internalThingsAddress
    ) external override onlyGator {
        require(
            ThingsList[_internalThingsAddress].addfromgator == msg.sender,
            "you have not the right"
        );
        ThingsList[_internalThingsAddress].gateunlock = false;
        emit e_lockThingbyGator(msg.sender, _internalThingsAddress);
    }

    function updateThingbyGator(
        LThing.Info memory _ThingsInfo
    ) external override onlyGator {
        require(
            ThingsList[_ThingsInfo.contractAddress].addfromgator == msg.sender,
            "you have not the right"
        );

        _ThingsInfo.marketunlock = false;
        _ThingsInfo.gateunlock = false;
        _ThingsInfo.isUsed = true;
        _ThingsInfo.addfromgator = msg.sender;
        ThingsList[_ThingsInfo.contractAddress] = _ThingsInfo;
        emit e_updateThingbyGator(msg.sender, _ThingsInfo);
    }

    /////////////////////////物品设置-创建者/////////////////////
    /////////////////////////things Manage/////////////////////
    function lockThingbyCreater(
        address _internalThingsAddress
    ) external override {
        require(
            ThingsList[_internalThingsAddress].creator == msg.sender,
            "you have not the privileges of this"
        );
        ThingsList[_internalThingsAddress].createrunlock = false;
        emit e_lockThingbyCreater(msg.sender, _internalThingsAddress);
    }

    function unlockThingbyCreater(
        address _internalThingsAddress
    ) external override {
        require(
            ThingsList[_internalThingsAddress].creator == msg.sender,
            "you have not the privileges of this"
        );
        ThingsList[_internalThingsAddress].createrunlock = true;
        emit e_unlockThingbyCreater(msg.sender, _internalThingsAddress);
    }

    function addThingbyCreator(
        LThing.Info memory _thingsInfo,
        address _gateaddress
    ) external override {
        require(
            ThingsList[_thingsInfo.contractAddress].isUsed != true,
            "you have not the right"
        );

        _thingsInfo.marketunlock = true;
        _thingsInfo.gateunlock = false;
        _thingsInfo.createrunlock = false;
        _thingsInfo.isUsed = true;
        _thingsInfo.addfromgator = _gateaddress;
        _thingsInfo.creator = msg.sender;
        if (
            thingMaxNo[_gateaddress] >= 1 &&
            thingMaxNo[_gateaddress] + 1 >= thingMaxNo[_gateaddress]
        ) {
            thingMaxNo[_gateaddress] += 1;
        } else {
            thingMaxNo[_gateaddress] = 1;
        }

        ownerThingList[_gateaddress][thingMaxNo[_gateaddress]] = _thingsInfo
            .contractAddress;
        ownerThingNo[_gateaddress][_thingsInfo.contractAddress] = thingMaxNo[
            _gateaddress
        ];
        ThingsList[_thingsInfo.contractAddress] = _thingsInfo;
        emit e_addThingbyCreator(_thingsInfo, _gateaddress);
    }

    function addThingDetailInforbyCreator(
        LThing.DetailInfo memory _thingDetailinfo
    ) external override {
        require(
            ThingsList[_thingDetailinfo.contractAddress].creator == msg.sender,
            "you is not the thing creater"
        );
        ThingsDetailList[_thingDetailinfo.contractAddress] = _thingDetailinfo;
        emit e_addThingDetailbyCreator(_thingDetailinfo.contractAddress);
    }

    function addThingDetailInforbyGator(
        LThing.DetailInfo memory _thingDetailinfo
    ) external override {
        require(
            ThingsList[_thingDetailinfo.contractAddress].addfromgator ==
                msg.sender,
            "you is not the thing creater"
        );
        ThingsDetailList[_thingDetailinfo.contractAddress] = _thingDetailinfo;
        emit e_addThingDetailbyGator(_thingDetailinfo.contractAddress);
    }

    function addThingDetailInforbyMarketor(
        LThing.DetailInfo memory _thingDetailinfo
    ) external override onlyMarketor {
        ThingsDetailList[_thingDetailinfo.contractAddress] = _thingDetailinfo;
        emit e_addThingDetailbyMarketor(_thingDetailinfo.contractAddress);
    }

    function updateThingbyCreator(
        LThing.Info memory _ThingsInfo
    ) external override {
        require(
            ThingsList[_ThingsInfo.contractAddress].isUsed == true &&
                _ThingsInfo.creator == msg.sender,
            "you have not the right"
        );

        _ThingsInfo.marketunlock = ThingsList[_ThingsInfo.contractAddress]
            .marketunlock;
        _ThingsInfo.gateunlock = ThingsList[_ThingsInfo.contractAddress]
            .gateunlock;
        _ThingsInfo.createrunlock = false;
        _ThingsInfo.isUsed = true;
        _ThingsInfo.addfromgator = ThingsList[_ThingsInfo.contractAddress]
            .addfromgator;
        _ThingsInfo.creator = msg.sender;
        ThingsList[_ThingsInfo.contractAddress] = _ThingsInfo;
        emit e_updateThingbyCreator(msg.sender, _ThingsInfo);
    }

    function getThingInfoFromaddress(
        address _contractaddress
    ) external view override returns (LThing.Info memory) {
        require(
            ThingsList[_contractaddress].isUsed == true,
            "the Thing is not exists"
        );
        return ThingsList[_contractaddress];
    }

    function getThingInfoOwnerNo(
        address _owneraddress,
        uint128 _ThingNo
    ) external view override returns (LThing.Info memory) {
        require(
            ThingsList[_owneraddress].isUsed == true,
            "the Thing is not exists"
        );
        return ThingsList[ownerThingList[_owneraddress][_ThingNo]];
    }

    function getThingMaxNo(
        address _owneraddress
    ) external view override returns (uint128) {
        return thingMaxNo[_owneraddress];
    }

    function isValidThing(
        address _thing
    ) external view override returns (bool) {
        return ThingsList[_thing].marketunlock;
    }
}
