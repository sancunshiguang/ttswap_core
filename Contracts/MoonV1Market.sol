// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./interfaces/IMoonV1Market.sol";
import "./MoonV1ShopCreate.sol";

import "./NoDelegateCall.sol";
import "./libraries/base/LCustomer.sol";
import "./libraries/base/LShop.sol";

contract MoonV1Market is IMoonV1Market, MoonV1ShopCreate, NoDelegateCall {
    //市场拥有者
    //marketCreator
    address public immutable override marketCreator;

    //费用标准
    //profit standard
    int256 public immutable profitStandard = 100;

    //市场管理员
    //marketManagers
    mapping(address => bool) public marketManagers;

    //门户信息
    //Gate Parameter
    mapping(address => LGate.Info) public gateList;

    //市场门店信息
    //币种-物品-店铺地址
    //ShopAddress
    mapping(address => bool) public marketShopList;

    //门户门店信息
    //门户-币种-物品-店铺地址
    //gateaddress=>ShopAddress
    mapping(address => mapping(address => bool)) public gateShopList;

    //门户门店信息
    mapping(address => mapping(address => address)) public shopaddress;

    mapping(address => LShop.Info) public shopList;

    //市场币种信息
    //币种地址 => 币种信息
    //coinaddress => coin detail info
    mapping(address => address) public marketCoinList;

    //门户币种信息
    //币种地址 => 币种信息
    //gateaddress => coinaddress => coin detail info
    mapping(address => mapping(address => address)) public gateCoinList;

    //币种信息
    //币种地址 => 币种信息
    //coinaddress => coinInfo
    mapping(address => LCoin.Info) public coinList;

    //标准物品地址 => 标准物品信息
    //standardGoodsaddress => standard Goods detail info
    mapping(address => address) public marketSTGoodsList;

    //门户标准物品地址 => 标准物品信息
    //gateaddress => standradGoodsaddress => standradGoodsaddress
    mapping(address => mapping(address => address)) public gateSTGoodsList;

    //标准物品
    //标准物品地址 => 标准物品信息
    //coinaddress => coinInfo
    mapping(address => LSTGoods.Info) public STGoodsList;

    //客户地址=>客户信息
    //customeraddress =>customer detail info
    mapping(address => LCustomer.Info) public customerList;

    mapping(uint24 => int24) public profitUnitSpacing;

    //记录手费费分配方式
    //config the default fee share'pay
    LProfitShares.Info public marketProfitshares =
        LProfitShares.Info({
            marketshare: 20,
            gatershare: 40,
            commandershare: 20,
            usershare: 20
        });

    //initial Market
    constructor() {
        marketCreator = msg.sender;
        profitUnitSpacing[50] = 10;
        profitUnitSpacing[100] = 20;
        profitUnitSpacing[150] = 30;
        profitUnitSpacing[200] = 40;
        profitUnitSpacing[250] = 50;
        profitUnitSpacing[300] = 60;
        profitUnitSpacing[500] = 100;
        profitUnitSpacing[1000] = 200;
        profitUnitSpacing[2000] = 400;
        profitUnitSpacing[3000] = 600;
        //profitUnitSpacing[500] = 10;
        //profitUnitSpacing[3000] = 60;
        //profitUnitSpacing[10000] = 200;
        customerUniNextKey = 10000000;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    modifier onlyMarketCreator() {
        require(msg.sender == marketCreator);
        _;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    modifier onlyMarketManager() {
        require(marketManagers[msg.sender] == true);
        _;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    modifier onlyGator() {
        require(gateList[msg.sender].marketunlock == true);
        _;
    }

    /////////////////////////管理设置/////////////////////
    /////////////////////////manage config/////////////////////

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function setMarketProfitshare(LProfitShares.Info memory _profitshare)
        external
        override
        onlyMarketCreator
    {
        marketProfitshares = _profitshare;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function setMarketManager(address _owner)
        external
        override
        onlyMarketCreator
    {
        marketManagers[_owner] = true;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function delMarketManager(address _owner)
        external
        override
        onlyMarketCreator
    {
        delete marketManagers[_owner];
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function ismarketManager() external view override returns (bool) {
        return marketManagers[msg.sender];
    }

    /////////////////////////币种设置-市场/////////////////////
    /////////////////////////Coin Manage/////////////////////

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function addCoinbyMarketor(LCoin.Info memory _coinInfo)
        external
        override
        onlyMarketManager
    {
        if (coinList[_coinInfo.contractAddress].isUsed != true) {
            _coinInfo.creator = msg.sender;
            _coinInfo.marketunlock = false;
            _coinInfo.unlock = false;
            _coinInfo.isUsed = true;
            coinList[_coinInfo.contractAddress] = _coinInfo;
            marketCoinList[_coinInfo.contractAddress] = _coinInfo
                .contractAddress;
        } else {
            require(
                marketCoinList[_coinInfo.contractAddress] == address(0),
                "the coin exists in the market"
            );
            marketCoinList[_coinInfo.contractAddress] = _coinInfo
                .contractAddress;
        }
    }

    function changeCoinScopebyMarketor(
        address _internalCoinAddress,
        uint8 _scope
    ) external onlyMarketManager {
        coinList[_internalCoinAddress].scope = _scope;
    }

    function lockCoinbyMarketor(address _internalCoinAddress)
        external
        onlyMarketManager
    {
        coinList[_internalCoinAddress].marketunlock = false;
    }

    function unlockCoinbyMarketor(address _internalCoinAddress)
        external
        onlyMarketManager
    {
        coinList[_internalCoinAddress].marketunlock = true;
    }

    function updateCoinbyMarketor(LCoin.Info memory _coinInfo)
        external
        onlyMarketManager
    {
        require(marketCoinList[_coinInfo.contractAddress] != address(0));
        _coinInfo.marketunlock = false;
        _coinInfo.unlock = false;
        _coinInfo.isUsed = true;
        _coinInfo.creator = coinList[_coinInfo.contractAddress].creator;
        coinList[_coinInfo.contractAddress] = _coinInfo;
    }

    function impoveGateCoinbyMarketor(
        address _contractaddress,
        address _gateaddress
    ) external onlyMarketManager {
        require(
            gateCoinList[_gateaddress][_contractaddress] != address(0),
            "the coin is not exists"
        );
        require(
            marketCoinList[_contractaddress] == address(0),
            "the coin is  exists in market"
        );
        marketCoinList[_contractaddress] = gateCoinList[_gateaddress][
            _contractaddress
        ];

        delete gateCoinList[_gateaddress][_contractaddress];
    }

    function delCoinbyMarketor(address _contractaddress)
        external
        override
        onlyMarketManager
    {
        require(
            marketCoinList[_contractaddress] == address(0),
            "the coin is not exists"
        );
        delete marketCoinList[_contractaddress];
    }

    function delGateCoinbyMarketor(
        address _contractaddress,
        address _gateaddress
    ) external override onlyMarketManager {
        require(
            gateCoinList[_gateaddress][_contractaddress] == address(0),
            "the coin is not exists"
        );
        delete gateCoinList[_gateaddress][_contractaddress];
    }

    /////////////////////////币种设置-门户/////////////////////
    /////////////////////////Coin Manage/////////////////////
    function addCoinbyGator(LCoin.Info memory _coinInfo)
        external
        override
        onlyGator
    {
        if (coinList[_coinInfo.contractAddress].isUsed != true) {
            _coinInfo.creator = msg.sender;
            _coinInfo.marketunlock = false;
            _coinInfo.unlock = false;
            _coinInfo.isUsed = true;
            coinList[_coinInfo.contractAddress] = _coinInfo;
            gateCoinList[msg.sender][_coinInfo.contractAddress] = _coinInfo
                .contractAddress;
        } else {
            require(
                marketCoinList[_coinInfo.contractAddress] == address(0),
                "the coin exists in the market"
            );
            require(
                gateCoinList[msg.sender][_coinInfo.contractAddress] ==
                    address(0),
                "the coin exists in the gate"
            );
            gateCoinList[msg.sender][_coinInfo.contractAddress] = _coinInfo
                .contractAddress;
        }
    }

    function unlockCoinbyGator(address _internalCoinAddress)
        external
        override
        onlyGator
    {
        require(
            coinList[_internalCoinAddress].creator == msg.sender,
            "you have not the right"
        );
        coinList[_internalCoinAddress].unlock = true;
    }

    function lockCoinbyGator(address _internalCoinAddress)
        external
        override
        onlyGator
    {
        require(
            coinList[_internalCoinAddress].creator == msg.sender,
            "you have not the right"
        );
        coinList[_internalCoinAddress].unlock = false;
    }

    function updateCoinbyGator(LCoin.Info memory _coinInfo)
        external
        override
        onlyGator
    {
        require(
            coinList[_coinInfo.contractAddress].creator == msg.sender,
            "you have not the right"
        );
        require(_coinInfo.scope == 4, "the coin scope is not justified ");
        _coinInfo.marketunlock = false;
        _coinInfo.unlock = false;
        _coinInfo.isUsed = true;
        _coinInfo.creator = msg.sender;
        coinList[_coinInfo.contractAddress] = _coinInfo;
    }

    function getCoinInfo(address _contractaddress)
        external
        view
        override
        returns (LCoin.Info memory)
    {
        require(
            coinList[_contractaddress].isUsed == true,
            "the coin is not exists"
        );
        return coinList[_contractaddress];
    }

    /////////////////////////物品设置-市场/////////////////////
    /////////////////////////things Manage/////////////////////
    function addSTGoodsbyMarketor(LSTGoods.Info memory _STGoodsInfo)
        external
        override
        onlyMarketManager
    {
        if (STGoodsList[_STGoodsInfo.contractAddress].isUsed != true) {
            _STGoodsInfo.addfromgater = msg.sender;
            _STGoodsInfo.creator = msg.sender;
            _STGoodsInfo.marketunlock = false;
            _STGoodsInfo.unlock = false;
            _STGoodsInfo.isUsed = true;
            STGoodsList[_STGoodsInfo.contractAddress] = _STGoodsInfo;
            marketSTGoodsList[_STGoodsInfo.contractAddress] = _STGoodsInfo
                .contractAddress;
        } else {
            require(
                marketSTGoodsList[_STGoodsInfo.contractAddress] == address(0),
                "the stgoods exists in the market"
            );
            marketSTGoodsList[_STGoodsInfo.contractAddress] = _STGoodsInfo
                .contractAddress;
        }
    }

    function changeSTGoodsScopebyMarketor(
        address _internalSTGoodsAddress,
        uint8 _scope
    ) external onlyMarketManager {
        STGoodsList[_internalSTGoodsAddress].scope = _scope;
    }

    function lockSTGoodsbyMarketor(address _internalSTGoodsAddress)
        external
        onlyMarketManager
    {
        STGoodsList[_internalSTGoodsAddress].marketunlock = false;
    }

    function unlockSTGoodsbyMarketor(address _internalSTGoodsAddress)
        external
        override
        onlyMarketManager
    {
        STGoodsList[_internalSTGoodsAddress].marketunlock = true;
    }

    function updateSTGoodsbyMarketor(LSTGoods.Info memory _STGoodsInfo)
        external
        override
        onlyMarketManager
    {
        require(marketSTGoodsList[_STGoodsInfo.contractAddress] != address(0));
        _STGoodsInfo.marketunlock = false;
        _STGoodsInfo.unlock = false;
        _STGoodsInfo.isUsed = true;
        _STGoodsInfo.creator = STGoodsList[_STGoodsInfo.contractAddress]
            .creator;
        STGoodsList[_STGoodsInfo.contractAddress] = _STGoodsInfo;
    }

    function impoveGateSTGoodsbyMarketor(
        address _contractaddress,
        address _gateaddress
    ) external override onlyMarketManager {
        require(
            gateSTGoodsList[_gateaddress][_contractaddress] != address(0),
            "the STGoods is not exists"
        );
        require(
            marketSTGoodsList[_contractaddress] == address(0),
            "the STGoods is  exists in market"
        );
        marketSTGoodsList[_contractaddress] = gateSTGoodsList[_gateaddress][
            _contractaddress
        ];

        delete gateSTGoodsList[_gateaddress][_contractaddress];
    }

    function delSTGoodsbyMarketor(LSTGoods.Info memory _STGoodsInfo)
        external
        override
        onlyMarketManager
    {
        require(
            marketSTGoodsList[_STGoodsInfo.contractAddress] == address(0),
            "the STGoods is not exists"
        );
        delete marketSTGoodsList[_STGoodsInfo.contractAddress];
    }

    function delGateSTGoodsbyMarketor(
        address _contractaddress,
        address _gateaddress
    ) external override onlyMarketManager {
        require(
            gateSTGoodsList[_gateaddress][_contractaddress] == address(0),
            "the STGoods is not exists"
        );
        delete gateSTGoodsList[_gateaddress][_contractaddress];
    }

    /////////////////////////物品设置-门户/////////////////////
    /////////////////////////things Manage/////////////////////

    function unlockSTGoodsbyGator(address _internalSTGoodsAddress)
        external
        override
        onlyGator
    {
        require(
            STGoodsList[_internalSTGoodsAddress].addfromgater == msg.sender,
            "you have not the right"
        );
        STGoodsList[_internalSTGoodsAddress].unlock = true;
    }

    function lockSTGoodsbyGator(address _internalSTGoodsAddress)
        external
        override
        onlyGator
    {
        require(
            STGoodsList[_internalSTGoodsAddress].addfromgater == msg.sender,
            "you have not the right"
        );
        STGoodsList[_internalSTGoodsAddress].unlock = false;
    }

    function updateSTGoodsbyGator(LSTGoods.Info memory _STGoodsInfo)
        external
        override
        onlyGator
    {
        require(
            STGoodsList[_STGoodsInfo.contractAddress].addfromgater ==
                msg.sender,
            "you have not the right"
        );
        require(_STGoodsInfo.scope == 4, "the coin scope is not justified ");
        _STGoodsInfo.marketunlock = false;
        _STGoodsInfo.unlock = false;
        _STGoodsInfo.isUsed = true;
        _STGoodsInfo.addfromgater = msg.sender;
        STGoodsList[_STGoodsInfo.contractAddress] = _STGoodsInfo;
    }

    /////////////////////////物品设置-创建者/////////////////////
    /////////////////////////things Manage/////////////////////
    function lockGateSTGoodsbyCreater(
        address _internalSTGoodsAddress,
        address _gateaddress
    ) external override {
        require(
            STGoodsList[_internalSTGoodsAddress].creator == msg.sender &&
                gateSTGoodsList[_gateaddress][_internalSTGoodsAddress] ==
                address(0),
            "you have not the privileges of this"
        );
        STGoodsList[_internalSTGoodsAddress].createrunlock = false;
    }

    function unlockGateSTGoodsbyCreater(
        address _internalSTGoodsAddress,
        address _gateaddress
    ) external override {
        require(
            STGoodsList[_internalSTGoodsAddress].creator == msg.sender &&
                gateSTGoodsList[_gateaddress][_internalSTGoodsAddress] ==
                address(0),
            "you have not the privileges of this"
        );
        STGoodsList[_internalSTGoodsAddress].createrunlock = true;
    }

    function addGateSTGoodsbyCreator(
        LSTGoods.Info memory _STGoodsInfo,
        address _gateaddress
    ) external override {
        require(
            STGoodsList[_STGoodsInfo.contractAddress].isUsed != true &&
                gateSTGoodsList[_gateaddress][_STGoodsInfo.contractAddress] ==
                address(0),
            "you have not the right"
        );

        _STGoodsInfo.marketunlock = false;
        _STGoodsInfo.unlock = true;
        _STGoodsInfo.createrunlock = false;
        _STGoodsInfo.isUsed = true;
        _STGoodsInfo.addfromgater = _gateaddress;
        _STGoodsInfo.creator = msg.sender;
        STGoodsList[_STGoodsInfo.contractAddress] = _STGoodsInfo;
        gateSTGoodsList[_gateaddress][
            _STGoodsInfo.contractAddress
        ] = _STGoodsInfo.contractAddress;
    }

    function updateGateSTGoodsbyCreator(
        LSTGoods.Info memory _STGoodsInfo,
        address _gateaddress
    ) external override {
        require(
            STGoodsList[_STGoodsInfo.contractAddress].isUsed != true &&
                gateSTGoodsList[_gateaddress][_STGoodsInfo.contractAddress] ==
                address(0),
            "you have not the right"
        );

        _STGoodsInfo.marketunlock = false;
        _STGoodsInfo.unlock = true;
        _STGoodsInfo.createrunlock = false;
        _STGoodsInfo.isUsed = true;
        _STGoodsInfo.addfromgater = _gateaddress;
        _STGoodsInfo.creator = msg.sender;
        STGoodsList[_STGoodsInfo.contractAddress] = _STGoodsInfo;
        gateSTGoodsList[_gateaddress][
            _STGoodsInfo.contractAddress
        ] = _STGoodsInfo.contractAddress;
    }

    function getSTGoodsInfo(address _contractaddress)
        external
        view
        override
        returns (LSTGoods.Info memory)
    {
        require(
            STGoodsList[_contractaddress].isUsed == true,
            "the STGoods is not exists"
        );

        return STGoodsList[_contractaddress];
    }

    /////////////////////////用户管理-市场////////////////////////////
    /////////////////////////user Manage/////////////////////
    function lockCustomerbyMarketor(address _CustomerAddress)
        external
        override
        onlyMarketManager
    {
        require(
            customerList[_CustomerAddress].isUsed != true,
            "customer is not exists"
        );
        customerList[_CustomerAddress].unlock = false;
    }

    function unlockCustomerbyMarketor(address _CustomerAddress)
        external
        override
        onlyMarketManager
    {
        require(
            customerList[_CustomerAddress].isUsed != true,
            "customer is not exists"
        );
        customerList[_CustomerAddress].unlock = true;
    }

    /////////////////////////用户管理////////////////////////////
    /////////////////////////user Manage///////////////////////////

    mapping(address => uint32) public gateCustomerNextKey;
    mapping(address => mapping(uint32 => address)) public gatecustomerList;

    mapping(uint40 => address) public customerUniKey; //用户号
    uint40 public customerUniNextKey; //用户下个编号
    mapping(address => uint32) public recommenderraltionkey;
    mapping(address => mapping(uint32 => address))
        public recommenderraltionlist;

    //推荐者提供码,用户进行扫码或者输入推荐者的信息
    function addRelation(uint40 _recommanderUnikey) external {
        require(
            customerList[msg.sender].recommender == address(0),
            "the customer recommender exists"
        );
        address recom_address = customerUniKey[_recommanderUnikey];
        if (recommenderraltionkey[recom_address] >= 1) {
            recommenderraltionkey[recom_address] += 1;
        } else {
            recommenderraltionkey[recom_address] = 1;
        }
        recommenderraltionlist[recom_address][
            recommenderraltionkey[recom_address]
        ] = msg.sender;
        customerList[msg.sender].recommender = recom_address;
    }

    //用户增加
    function addCustomer(LCustomer.Info memory _customer, address _gater)
        external
    {
        require(
            customerList[_customer.contractAddress].isUsed != true &&
                _customer.contractAddress == msg.sender,
            "customer is exists"
        );
        if (gateCustomerNextKey[_gater] >= 1) {
            gateCustomerNextKey[_gater] += 1;
        } else gateCustomerNextKey[_gater] = 1;

        customerUniNextKey += 1;
        customerUniKey[customerUniNextKey] = msg.sender;
        _customer.customerKey = customerUniNextKey;
        _customer.Gater = _gater;
        _customer.GaterKey = gateCustomerNextKey[_gater];
        customerList[_customer.contractAddress] = _customer;
        gatecustomerList[_gater][gateCustomerNextKey[_gater]] = msg.sender;
    }

    function updateCustomerNeckName(bytes32 _newname) external {
        require(
            customerList[msg.sender].isUsed =
                true &&
                customerList[msg.sender].contractAddress == msg.sender,
            "customer is not exists"
        );
        customerList[msg.sender].neckname = _newname;
    }

    function getCustomer(address _CustomerAddress)
        external
        view
        override
        returns (LCustomer.Info memory)
    {
        require(
            customerList[_CustomerAddress].isUsed == true,
            " Customer is not exists"
        );
        return customerList[_CustomerAddress];
    }

    function getCustomerRecommander(address _customer)
        external
        view
        override
        returns (address)
    {
        require(
            customerList[_customer].isUsed == true,
            " Customer is not exists"
        );
        return customerList[_customer].recommender;
    }

    function getCustomerNumbyRecommander(address _recommander)
        external
        view
        returns (uint32)
    {
        require(_recommander != address(0), "customer address is null");
        return recommenderraltionkey[_recommander];
    }

    function getCustomerInfobyRecommander(
        address _recommander,
        uint32 _cumstomerindex
    ) external view returns (address) {
        require(_recommander != address(0), "customer address is null");
        return recommenderraltionlist[_recommander][_cumstomerindex];
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

    function delGatebyMarketor(address _gater) external onlyMarketManager {
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
    function updateGatebyGator(LGate.Info memory _gater) external onlyGator {
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

    function addGater(LGate.Info memory _gater) external {
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

    //更新门户内容

    //法币  :0
    //原生币 :1
    //市场币 :2
    //门户币 :3
    //标准商品:4
    //非标准商品:5

    /*
    profitStandard[0][0][0]=50;
    profitStandard[0][1][0]=100;
    profitStandard[0][2][0]=150;
    profitStandard[0][3][0]=200;
    profitStandard[0][4][1]=300;
    profitStandard[0][4][2]=1000;
    profitStandard[0][5][0]=300;
    profitStandard[0][5][1]=1000;
    profitStandard[0][5][2]=3000;
    profitStandard[1][0][0]=50;
    profitStandard[1][1][0]=100;
    profitStandard[1][2][0]=150;
    profitStandard[1][3][0]=200;
    profitStandard[1][4][0]=300;
    profitStandard[1][4][0]=1000;
    profitStandard[1][5][0]=300;
    profitStandard[1][5][1]=1000;
    profitStandard[1][5][2]=3000;
    profitStandard[2][0][0]=150;
    profitStandard[2][1][0]=150;
    profitStandard[2][2][0]=150;
    profitStandard[2][3][0]=200;
    profitStandard[2][4][0]=300;
    profitStandard[2][4][1]=1000;
    profitStandard[2][5][0]=300;
    profitStandard[2][5][1]=1000;
    profitStandard[2][5][2]=3000;
    profitStandard[3][0][0]=200;
    profitStandard[3][1][0]=200;
    profitStandard[3][2][0]=200;
    profitStandard[3][3][0]=200;
    profitStandard[3][4][0]=300;
    profitStandard[3][4][1]=1000;
    profitStandard[3][4][2]=3000;
    profitStandard[3][5][0]=300;
    profitStandard[3][5][1]=1000;
    profitStandard[3][5][2]=3000;
*/

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param _coin the coin of the shop
    /// @param _thing the things of the shop
    /// @param _profit  交易手续费费率fee percentage of swap
    function createShopbyMarketor(
        address _coin,
        address _thing,
        uint24 _profit
    )
        external
        override
        noDelegateCall
        onlyMarketManager
        returns (address shop)
    {
        require(_coin != _thing, "the coin is same as the thing ");
        require(coinList[_coin].isUsed == true, "the coin  have not config ");
        require(
            STGoodsList[_thing].isUsed == true,
            "the thing have not config "
        );
        require(
            marketCoinList[_coin] != address(0),
            "the coin is not a marketCoin"
        );

        require(
            marketSTGoodsList[_thing] != address(0),
            "the coin is not a marketCoin"
        );
        require(
            coinList[_coin].marketunlock == true &&
                coinList[_coin].unlock == true,
            "_coin is locked"
        );
        require(
            STGoodsList[_thing].marketunlock == true &&
                STGoodsList[_thing].unlock == true &&
                STGoodsList[_thing].createrunlock == true,
            "_thing is invalid"
        );

        if (
            shopaddress[_coin][_thing] == address(0) &&
            shopaddress[_thing][_coin] == address(0)
        ) {
            shop = deploy(
                marketCreator,
                _coin,
                _thing,
                _profit,
                profitUnitSpacing[_profit],
                marketProfitshares
            );

            shopaddress[_coin][_thing] = shop;
            shopaddress[_thing][_coin] = shop;
            shopList[shop].Market = marketCreator;
            shopList[shop].coin = _coin;
            shopList[shop].thing = _thing;
            shopList[shop].profit = _profit;
            shopList[shop].unitSpacing = profitUnitSpacing[_profit];
            gateShopList[msg.sender][shop] = true;
            delete shop;
        } else {
            require(
                gateShopList[msg.sender][shopaddress[_coin][_thing]] == true,
                "the shop exists"
            );
            gateShopList[msg.sender][shopaddress[_coin][_thing]] = true;
        }
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param _coin the coin of the shop
    /// @param _thing the things of the shop
    /// @param _profit  交易手续费费率fee percentage of swap

    function createShopbyGator(
        address _coin,
        address _thing,
        uint24 _profit
    ) external override noDelegateCall onlyGator returns (address shop) {
        require(_coin != _thing, "the coin is same as the thing ");
        require(coinList[_coin].isUsed == true, "the coin  have not config ");
        require(
            STGoodsList[_thing].isUsed == true,
            "the thing have not config "
        );
        require(
            marketCoinList[_coin] != address(0) ||
                gateCoinList[msg.sender][_coin] != address(0),
            "the coin is not a marketCoin"
        );

        require(
            marketSTGoodsList[_thing] != address(0) ||
                gateSTGoodsList[msg.sender][_thing] != address(0),
            "the thing is not a valid thing "
        );
        require(
            coinList[_coin].marketunlock == true &&
                coinList[_coin].unlock == true,
            "_coin is locked"
        );
        require(
            STGoodsList[_thing].marketunlock == true &&
                STGoodsList[_thing].unlock == true &&
                STGoodsList[_thing].createrunlock == true,
            "_thing is invalid"
        );

        if (
            shopaddress[_coin][_thing] == address(0) &&
            shopaddress[_thing][_coin] == address(0)
        ) {
            shop = deploy(
                msg.sender,
                _coin,
                _thing,
                _profit,
                profitUnitSpacing[_profit],
                marketProfitshares
            );

            shopaddress[_coin][_thing] = shop;
            shopaddress[_thing][_coin] = shop;
            shopList[shop].Market = marketCreator;
            shopList[shop].coin = _coin;
            shopList[shop].thing = _thing;
            shopList[shop].profit = _profit;
            shopList[shop].unitSpacing = profitUnitSpacing[_profit];
            marketShopList[shop] = true;
            delete shop;
        } else {
            require(
                marketShopList[shopaddress[_coin][_thing]] == true,
                "the shop exists"
            );
            marketShopList[shopaddress[_coin][_thing]] = true;
        }
    }

    function raiseShopLevelbyMarketor(address shop)
        external
        override
        onlyMarketManager
    {
        require(
            marketShopList[shop] = true && shopList[shop].isUsed == true,
            "the shop not exists in the gate"
        );
        marketShopList[shop] = true;
    }
}
