// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;
import "./libraries/base/LThing.sol";
import "./interfaces/Marketor/IMarketorV1State.sol";
import "./interfaces/Gator/IGatorV1State.sol";
import "./interfaces/ITTSwapV1Thing.sol";

abstract contract TTSwapV1Thing is ITTSwapV1Thing {
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

    address public gatorContractAddress;
    address public marketorContractAddress;

    constructor(
        address _gatorContractAddress,
        address _marketorContractAddress
    ) {
        gatorContractAddress = _gatorContractAddress;
        marketorContractAddress = _marketorContractAddress;
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

    /////////////////////////物品设置-市场/////////////////////
    /////////////////////////things Manage/////////////////////
    function addThingbyMarketor(
        LThing.Info memory _thingsInfo
    ) external onlyMarketor {
        require(
            ThingsList[_thingsInfo.contractAddress].isUsed != true,
            "the things exist"
        );
        _thingsInfo.creator = msg.sender;
        _thingsInfo.marketunlock = true;
        _thingsInfo.gateunlock = true;
        _thingsInfo.isUsed = true;
        if (
            thingMaxNo[marketorContractAddress] >= 1 &&
            thingMaxNo[marketorContractAddress] + 1 >=
            thingMaxNo[marketorContractAddress]
        ) {
            thingMaxNo[marketorContractAddress] += 1;
        } else {
            thingMaxNo[marketorContractAddress] = 1;
        }
        ownerThingList[marketorContractAddress][
            thingMaxNo[marketorContractAddress]
        ] = _thingsInfo.contractAddress;

        ownerThingList[marketorContractAddress][
            thingMaxNo[marketorContractAddress]
        ] = _thingsInfo.contractAddress;
        ownerThingNo[marketorContractAddress][
            _thingsInfo.contractAddress
        ] = thingMaxNo[marketorContractAddress];
        ThingsList[_thingsInfo.contractAddress] = _thingsInfo;
    }

    function lockThingbyMarketor(
        address _internalThingsAddress
    ) external onlyMarketor {
        ThingsList[_internalThingsAddress].marketunlock = false;
    }

    function unlockThingbyMarketor(
        address _internalThingsAddress
    ) external onlyMarketor {
        ThingsList[_internalThingsAddress].marketunlock = true;
    }

    function updateThingbyMarketor(
        LThing.Info memory _thingsInfo
    ) external onlyMarketor {
        require(
            ownerThingNo[marketorContractAddress][
                _thingsInfo.contractAddress
            ] >= 0,
            "the coin don't exist in the market"
        );
        _thingsInfo.marketunlock = true;
        _thingsInfo.gateunlock = false;
        _thingsInfo.isUsed = true;
        _thingsInfo.creator = ThingsList[_thingsInfo.contractAddress].creator;
        ThingsList[_thingsInfo.contractAddress] = _thingsInfo;
    }

    function delMarketThingbyMarketor(
        address _contractaddress
    ) external onlyMarketor {
        require(
            ownerThingNo[marketorContractAddress][_contractaddress] >= 1,
            "the coin is not exists"
        );

        delete ownerThingList[marketorContractAddress][
            ownerThingNo[marketorContractAddress][_contractaddress]
        ];
        delete ownerThingNo[marketorContractAddress][_contractaddress];
    }

    function delMarketThingbyMarketor(uint128 _thingNo) external onlyMarketor {
        require(
            ownerThingList[marketorContractAddress][_thingNo] != address(0),
            "the coin is not exists"
        );

        delete ownerThingNo[marketorContractAddress][
            ownerThingList[marketorContractAddress][_thingNo]
        ];
        delete ownerThingList[marketorContractAddress][_thingNo];
    }

    /////////////////////////物品设置-门户/////////////////////
    /////////////////////////things Manage/////////////////////

    function unlockThingbyGator(
        address _internalThingsAddress
    ) external onlyGator {
        require(
            ThingsList[_internalThingsAddress].addfromgator == msg.sender,
            "you have not the right"
        );
        ThingsList[_internalThingsAddress].gateunlock = true;
    }

    function lockThingbyGator(
        address _internalThingsAddress
    ) external onlyGator {
        require(
            ThingsList[_internalThingsAddress].addfromgator == msg.sender,
            "you have not the right"
        );
        ThingsList[_internalThingsAddress].gateunlock = false;
    }

    function updateThingbyGator(
        LThing.Info memory _ThingsInfo
    ) external onlyGator {
        require(
            ThingsList[_ThingsInfo.contractAddress].addfromgator == msg.sender,
            "you have not the right"
        );

        _ThingsInfo.marketunlock = false;
        _ThingsInfo.gateunlock = false;
        _ThingsInfo.isUsed = true;
        _ThingsInfo.addfromgator = msg.sender;
        ThingsList[_ThingsInfo.contractAddress] = _ThingsInfo;
    }

    /////////////////////////物品设置-创建者/////////////////////
    /////////////////////////things Manage/////////////////////
    function lockGateThingbyCreater(address _internalThingsAddress) external {
        require(
            ThingsList[_internalThingsAddress].creator == msg.sender,
            "you have not the privileges of this"
        );
        ThingsList[_internalThingsAddress].createrunlock = false;
    }

    function unlockGateThingbyCreater(address _internalThingsAddress) external {
        require(
            ThingsList[_internalThingsAddress].creator == msg.sender,
            "you have not the privileges of this"
        );
        ThingsList[_internalThingsAddress].createrunlock = true;
    }

    function addGateThingbyCreator(
        LThing.Info memory _thingsInfo,
        address _gateaddress
    ) external {
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
    }

    function updateGateThingbyCreator(
        LThing.Info memory _ThingsInfo,
        address _gateaddress
    ) external {
        require(
            ThingsList[_ThingsInfo.contractAddress].isUsed != true,
            "you have not the right"
        );

        _ThingsInfo.marketunlock = false;
        _ThingsInfo.gateunlock = true;
        _ThingsInfo.createrunlock = false;
        _ThingsInfo.isUsed = true;
        _ThingsInfo.addfromgator = _gateaddress;
        _ThingsInfo.creator = msg.sender;
        ThingsList[_ThingsInfo.contractAddress] = _ThingsInfo;
    }

    function getThingInfo(
        address _contractaddress
    ) external view returns (LThing.Info memory) {
        require(
            ThingsList[_contractaddress].isUsed == true,
            "the Things is not exists"
        );

        return ThingsList[_contractaddress];
    }

    function isValidThing(address _thing) external view returns (bool) {
        return ThingsList[_thing].marketunlock;
    }
}
