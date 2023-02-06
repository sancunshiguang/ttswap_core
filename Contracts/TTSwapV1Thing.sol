// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;
import "./libraries/base/LThing.sol";
import "./interfaces/Marketor/IMarketorV1State.sol";
import "./interfaces/Gator/IGatorV1State.sol";
import "./interfaces/ITTSwapV1Thing.sol";

contract TTSwapV1Thing is ITTSwapV1Thing {
    //标准物品地址 => 标准物品信息
    //standardThingsaddress => standard Things detail info
    mapping(address => address) public marketThingsList;

    //门户标准物品地址 => 标准物品信息
    //gateaddress => standradThingsaddress => standradThingsaddress
    mapping(address => mapping(address => address)) public gateThingsList;

    //标准物品
    //标准物品地址 => 标准物品信息
    //coinaddress => coinInfo
    mapping(address => LThing.Info) public ThingsList;

    address public gateContractAddress;
    address public marketorContractAddress;

    constructor(address _gateContractAddress, address _marketorContractAddress)
    {
        gateContractAddress = _gateContractAddress;
        marketorContractAddress = _marketorContractAddress;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    modifier onlyGator() {
        require(IGatorV1State(gateContractAddress).isValidGator());
        _;
    }

    modifier onlyMarketor() {
        require(IMarketorV1State(marketorContractAddress).isValidMarketor());
        _;
    }

    /////////////////////////物品设置-市场/////////////////////
    /////////////////////////things Manage/////////////////////
    function addThingbyMarketor(LThing.Info memory _ThingsInfo)
        external
        onlyMarketor
    {
        if (ThingsList[_ThingsInfo.contractAddress].isUsed != true) {
            _ThingsInfo.addfromgator = msg.sender;
            _ThingsInfo.creator = msg.sender;
            _ThingsInfo.marketunlock = false;
            _ThingsInfo.unlock = false;
            _ThingsInfo.isUsed = true;
            ThingsList[_ThingsInfo.contractAddress] = _ThingsInfo;
            marketThingsList[_ThingsInfo.contractAddress] = _ThingsInfo
                .contractAddress;
        } else {
            require(
                marketThingsList[_ThingsInfo.contractAddress] == address(0),
                "the stgoods exists in the market"
            );
            marketThingsList[_ThingsInfo.contractAddress] = _ThingsInfo
                .contractAddress;
        }
    }

    function changeThingScopebyMarketor(
        address _internalThingsAddress,
        uint8 _scope
    ) external onlyMarketor {
        ThingsList[_internalThingsAddress].scope = _scope;
    }

    function lockThingbyMarketor(address _internalThingsAddress)
        external
        onlyMarketor
    {
        ThingsList[_internalThingsAddress].marketunlock = false;
    }

    function unlockThingbyMarketor(address _internalThingsAddress)
        external
        onlyMarketor
    {
        ThingsList[_internalThingsAddress].marketunlock = true;
    }

    function updateThingbyMarketor(LThing.Info memory _ThingsInfo)
        external
        onlyMarketor
    {
        require(marketThingsList[_ThingsInfo.contractAddress] != address(0));
        _ThingsInfo.marketunlock = false;
        _ThingsInfo.unlock = false;
        _ThingsInfo.isUsed = true;
        _ThingsInfo.creator = ThingsList[_ThingsInfo.contractAddress].creator;
        ThingsList[_ThingsInfo.contractAddress] = _ThingsInfo;
    }

    function impoveGateThingbyMarketor(
        address _contractaddress,
        address _gateaddress
    ) external onlyMarketor {
        require(
            gateThingsList[_gateaddress][_contractaddress] != address(0),
            "the Things is not exists"
        );
        require(
            marketThingsList[_contractaddress] == address(0),
            "the Things is  exists in market"
        );
        marketThingsList[_contractaddress] = gateThingsList[_gateaddress][
            _contractaddress
        ];

        delete gateThingsList[_gateaddress][_contractaddress];
    }

    function delMarketThingbyMarketor(LThing.Info memory _ThingsInfo)
        external
        onlyMarketor
    {
        require(
            marketThingsList[_ThingsInfo.contractAddress] == address(0),
            "the Things is not exists"
        );
        delete marketThingsList[_ThingsInfo.contractAddress];
    }

    function delGateThingbyMarketor(
        address _contractaddress,
        address _gateaddress
    ) external onlyMarketor {
        require(
            gateThingsList[_gateaddress][_contractaddress] == address(0),
            "the Things is not exists"
        );
        delete gateThingsList[_gateaddress][_contractaddress];
    }

    /////////////////////////物品设置-门户/////////////////////
    /////////////////////////things Manage/////////////////////

    function unlockThingbyGator(address _internalThingsAddress)
        external
        onlyGator
    {
        require(
            ThingsList[_internalThingsAddress].addfromgator == msg.sender,
            "you have not the right"
        );
        ThingsList[_internalThingsAddress].unlock = true;
    }

    function lockThingbyGator(address _internalThingsAddress)
        external
        onlyGator
    {
        require(
            ThingsList[_internalThingsAddress].addfromgator == msg.sender,
            "you have not the right"
        );
        ThingsList[_internalThingsAddress].unlock = false;
    }

    function updateThingbyGator(LThing.Info memory _ThingsInfo)
        external
        onlyGator
    {
        require(
            ThingsList[_ThingsInfo.contractAddress].addfromgator == msg.sender,
            "you have not the right"
        );
        require(_ThingsInfo.scope == 4, "the coin scope is not justified ");
        _ThingsInfo.marketunlock = false;
        _ThingsInfo.unlock = false;
        _ThingsInfo.isUsed = true;
        _ThingsInfo.addfromgator = msg.sender;
        ThingsList[_ThingsInfo.contractAddress] = _ThingsInfo;
    }

    /////////////////////////物品设置-创建者/////////////////////
    /////////////////////////things Manage/////////////////////
    function lockGateThingbyCreater(
        address _internalThingsAddress,
        address _gateaddress
    ) external {
        require(
            ThingsList[_internalThingsAddress].creator == msg.sender &&
                gateThingsList[_gateaddress][_internalThingsAddress] ==
                address(0),
            "you have not the privileges of this"
        );
        ThingsList[_internalThingsAddress].createrunlock = false;
    }

    function unlockGateThingbyCreater(
        address _internalThingsAddress,
        address _gateaddress
    ) external {
        require(
            ThingsList[_internalThingsAddress].creator == msg.sender &&
                gateThingsList[_gateaddress][_internalThingsAddress] ==
                address(0),
            "you have not the privileges of this"
        );
        ThingsList[_internalThingsAddress].createrunlock = true;
    }

    function addGateThingbyCreator(
        LThing.Info memory _ThingsInfo,
        address _gateaddress
    ) external {
        require(
            ThingsList[_ThingsInfo.contractAddress].isUsed != true &&
                gateThingsList[_gateaddress][_ThingsInfo.contractAddress] ==
                address(0),
            "you have not the right"
        );

        _ThingsInfo.marketunlock = false;
        _ThingsInfo.unlock = true;
        _ThingsInfo.createrunlock = false;
        _ThingsInfo.isUsed = true;
        _ThingsInfo.addfromgator = _gateaddress;
        _ThingsInfo.creator = msg.sender;
        ThingsList[_ThingsInfo.contractAddress] = _ThingsInfo;
        gateThingsList[_gateaddress][_ThingsInfo.contractAddress] = _ThingsInfo
            .contractAddress;
    }

    function updateGateThingbyCreator(
        LThing.Info memory _ThingsInfo,
        address _gateaddress
    ) external {
        require(
            ThingsList[_ThingsInfo.contractAddress].isUsed != true &&
                gateThingsList[_gateaddress][_ThingsInfo.contractAddress] ==
                address(0),
            "you have not the right"
        );

        _ThingsInfo.marketunlock = false;
        _ThingsInfo.unlock = true;
        _ThingsInfo.createrunlock = false;
        _ThingsInfo.isUsed = true;
        _ThingsInfo.addfromgator = _gateaddress;
        _ThingsInfo.creator = msg.sender;
        ThingsList[_ThingsInfo.contractAddress] = _ThingsInfo;
        gateThingsList[_gateaddress][_ThingsInfo.contractAddress] = _ThingsInfo
            .contractAddress;
    }

    function getThingInfo(address _contractaddress)
        external
        view
        returns (LThing.Info memory)
    {
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
