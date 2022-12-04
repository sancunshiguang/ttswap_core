// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;
import "./libraries/base/LSTThings.sol";
import "./MoonV1Manager.sol";
import "./MoonV1Gater.sol";

contract MoonV1Thing {
    address public immutable marketCreator;

    //标准物品地址 => 标准物品信息
    //standardThingsaddress => standard Things detail info
    mapping(address => address) public marketSTThingsList;

    //门户标准物品地址 => 标准物品信息
    //gateaddress => standradThingsaddress => standradThingsaddress
    mapping(address => mapping(address => address)) public gateSTThingsList;

    //标准物品
    //标准物品地址 => 标准物品信息
    //coinaddress => coinInfo
    mapping(address => LSTThings.Info) public STThingsList;

    constructor(address _marketCreator) {
        marketCreator = _marketCreator;
    }

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
        require(
            MoonV1Gater(marketCreator).gateList[msg.sender].marketunlock == true
        );
        _;
    }

    /////////////////////////物品设置-市场/////////////////////
    /////////////////////////things Manage/////////////////////
    function addSTThingsbyMarketor(LSTThings.Info memory _STThingsInfo)
        external
        override
        onlyMarketManager
    {
        if (STThingsList[_STThingsInfo.contractAddress].isUsed != true) {
            _STThingsInfo.addfromgater = msg.sender;
            _STThingsInfo.creator = msg.sender;
            _STThingsInfo.marketunlock = false;
            _STThingsInfo.unlock = false;
            _STThingsInfo.isUsed = true;
            STThingsList[_STThingsInfo.contractAddress] = _STThingsInfo;
            marketSTThingsList[_STThingsInfo.contractAddress] = _STThingsInfo
                .contractAddress;
        } else {
            require(
                marketSTThingsList[_STThingsInfo.contractAddress] == address(0),
                "the stgoods exists in the market"
            );
            marketSTThingsList[_STThingsInfo.contractAddress] = _STThingsInfo
                .contractAddress;
        }
    }

    function changeSTThingsScopebyMarketor(
        address _internalSTThingsAddress,
        uint8 _scope
    ) external override onlyMarketManager {
        STThingsList[_internalSTThingsAddress].scope = _scope;
    }

    function lockSTThingsbyMarketor(address _internalSTThingsAddress)
        external
        override
        onlyMarketManager
    {
        STThingsList[_internalSTThingsAddress].marketunlock = false;
    }

    function unlockSTThingsbyMarketor(address _internalSTThingsAddress)
        external
        override
        onlyMarketManager
    {
        STThingsList[_internalSTThingsAddress].marketunlock = true;
    }

    function updateSTThingsbyMarketor(LSTThings.Info memory _STThingsInfo)
        external
        override
        onlyMarketManager
    {
        require(
            marketSTThingsList[_STThingsInfo.contractAddress] != address(0)
        );
        _STThingsInfo.marketunlock = false;
        _STThingsInfo.unlock = false;
        _STThingsInfo.isUsed = true;
        _STThingsInfo.creator = STThingsList[_STThingsInfo.contractAddress]
            .creator;
        STThingsList[_STThingsInfo.contractAddress] = _STThingsInfo;
    }

    function impoveGateSTThingsbyMarketor(
        address _contractaddress,
        address _gateaddress
    ) external override onlyMarketManager {
        require(
            gateSTThingsList[_gateaddress][_contractaddress] != address(0),
            "the STThings is not exists"
        );
        require(
            marketSTThingsList[_contractaddress] == address(0),
            "the STThings is  exists in market"
        );
        marketSTThingsList[_contractaddress] = gateSTThingsList[_gateaddress][
            _contractaddress
        ];

        delete gateSTThingsList[_gateaddress][_contractaddress];
    }

    function delSTThingsbyMarketor(LSTThings.Info memory _STThingsInfo)
        external
        override
        onlyMarketManager
    {
        require(
            marketSTThingsList[_STThingsInfo.contractAddress] == address(0),
            "the STThings is not exists"
        );
        delete marketSTThingsList[_STThingsInfo.contractAddress];
    }

    function delGateSTThingsbyMarketor(
        address _contractaddress,
        address _gateaddress
    ) external override onlyMarketManager {
        require(
            gateSTThingsList[_gateaddress][_contractaddress] == address(0),
            "the STThings is not exists"
        );
        delete gateSTThingsList[_gateaddress][_contractaddress];
    }

    /////////////////////////物品设置-门户/////////////////////
    /////////////////////////things Manage/////////////////////

    function unlockSTThingsbyGator(address _internalSTThingsAddress)
        external
        override
        onlyGator
    {
        require(
            STThingsList[_internalSTThingsAddress].addfromgater == msg.sender,
            "you have not the right"
        );
        STThingsList[_internalSTThingsAddress].unlock = true;
    }

    function lockSTThingsbyGator(address _internalSTThingsAddress)
        external
        override
        onlyGator
    {
        require(
            STThingsList[_internalSTThingsAddress].addfromgater == msg.sender,
            "you have not the right"
        );
        STThingsList[_internalSTThingsAddress].unlock = false;
    }

    function updateSTThingsbyGator(LSTThings.Info memory _STThingsInfo)
        external
        override
        onlyGator
    {
        require(
            STThingsList[_STThingsInfo.contractAddress].addfromgater ==
                msg.sender,
            "you have not the right"
        );
        require(_STThingsInfo.scope == 4, "the coin scope is not justified ");
        _STThingsInfo.marketunlock = false;
        _STThingsInfo.unlock = false;
        _STThingsInfo.isUsed = true;
        _STThingsInfo.addfromgater = msg.sender;
        STThingsList[_STThingsInfo.contractAddress] = _STThingsInfo;
    }

    /////////////////////////物品设置-创建者/////////////////////
    /////////////////////////things Manage/////////////////////
    function lockGateSTThingsbyCreater(
        address _internalSTThingsAddress,
        address _gateaddress
    ) external override {
        require(
            STThingsList[_internalSTThingsAddress].creator == msg.sender &&
                gateSTThingsList[_gateaddress][_internalSTThingsAddress] ==
                address(0),
            "you have not the privileges of this"
        );
        STThingsList[_internalSTThingsAddress].createrunlock = false;
    }

    function unlockGateSTThingsbyCreater(
        address _internalSTThingsAddress,
        address _gateaddress
    ) external override {
        require(
            STThingsList[_internalSTThingsAddress].creator == msg.sender &&
                gateSTThingsList[_gateaddress][_internalSTThingsAddress] ==
                address(0),
            "you have not the privileges of this"
        );
        STThingsList[_internalSTThingsAddress].createrunlock = true;
    }

    function addGateSTThingsbyCreator(
        LSTThings.Info memory _STThingsInfo,
        address _gateaddress
    ) external override {
        require(
            STThingsList[_STThingsInfo.contractAddress].isUsed != true &&
                gateSTThingsList[_gateaddress][_STThingsInfo.contractAddress] ==
                address(0),
            "you have not the right"
        );

        _STThingsInfo.marketunlock = false;
        _STThingsInfo.unlock = true;
        _STThingsInfo.createrunlock = false;
        _STThingsInfo.isUsed = true;
        _STThingsInfo.addfromgater = _gateaddress;
        _STThingsInfo.creator = msg.sender;
        STThingsList[_STThingsInfo.contractAddress] = _STThingsInfo;
        gateSTThingsList[_gateaddress][
            _STThingsInfo.contractAddress
        ] = _STThingsInfo.contractAddress;
    }

    function updateGateSTThingsbyCreator(
        LSTThings.Info memory _STThingsInfo,
        address _gateaddress
    ) external override {
        require(
            STThingsList[_STThingsInfo.contractAddress].isUsed != true &&
                gateSTThingsList[_gateaddress][_STThingsInfo.contractAddress] ==
                address(0),
            "you have not the right"
        );

        _STThingsInfo.marketunlock = false;
        _STThingsInfo.unlock = true;
        _STThingsInfo.createrunlock = false;
        _STThingsInfo.isUsed = true;
        _STThingsInfo.addfromgater = _gateaddress;
        _STThingsInfo.creator = msg.sender;
        STThingsList[_STThingsInfo.contractAddress] = _STThingsInfo;
        gateSTThingsList[_gateaddress][
            _STThingsInfo.contractAddress
        ] = _STThingsInfo.contractAddress;
    }

    function getSTThingsInfo(address _contractaddress)
        external
        view
        override
        returns (LSTThings.Info memory)
    {
        require(
            STThingsList[_contractaddress].isUsed == true,
            "the STThings is not exists"
        );

        return STThingsList[_contractaddress];
    }
}
