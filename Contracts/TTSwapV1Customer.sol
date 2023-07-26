// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./libraries/base/LCustomer.sol";
import "./interfaces/Gator/IGatorV1State.sol";
import "./interfaces/Marketor/IMarketorV1State.sol";
import "./interfaces/ITTSwapV1Customer.sol";

contract TTSwapV1Customer is ITTSwapV1Customer {
    /////////////////////////用户管理-市场////////////////////////////
    /////////////////////////user Manage/////////////////////

    //客户地址=>客户信息
    //customeraddress =>customer detail info
    mapping(address => LCustomer.Info) public customerList;

    //下一位用户号的编号
    uint128 public customerUniNextKey; //用户下个编号
    //平台用户号->用户信息
    mapping(uint128 => address) public customerUniKey; //用户号

    //推荐人->被推荐人的序号
    mapping(address => uint128) public recommander_MaxCustomerNo;
    //推荐人->被推荐人的序号->推荐人的用户地址
    mapping(address => mapping(uint128 => address))
        public recommender_CustomerList;

    //门户地址->下一个门户用户的序号
    mapping(address => uint128) public gateMaxCustomerNo;
    //门户地址->门户用户序号->用户地址
    mapping(address => mapping(uint128 => address)) public gateCustomerList;
    //门户地址->门户用户序号->用户地址
    mapping(address => mapping(address => uint128)) public gateCustomerNo;

    //门户合约地址
    address public gatorContractAddress;
    //平台合约地址
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

    function setCustomerEnv(
        address _marketorContractAddress,
        address _gatorContractAddress,
        address _marketCreator
    ) external onlyMarketCreator {
        marketorContractAddress = _marketorContractAddress;
        gatorContractAddress = _gatorContractAddress;
        marketCreator = _marketCreator;
    }

    function lockCustomerbyMarketor(
        address _CustomerAddress
    ) external override onlyMarketor {
        require(
            customerList[_CustomerAddress].isUsed != true,
            "customer is not exists"
        );
        customerList[_CustomerAddress].unlock = false;
        emit e_lockCustomerbyMarketor(_CustomerAddress);
    }

    function unlockCustomerbyMarketor(
        address _CustomerAddress
    ) external override onlyMarketor {
        require(
            customerList[_CustomerAddress].isUsed != true,
            "customer is not exists"
        );
        customerList[_CustomerAddress].unlock = true;
        emit e_unlockCustomerbyMarketor(_CustomerAddress);
    }

    //推荐者提供码,用户进行扫码或者输入推荐者的信息
    function addRelation(uint128 _recommanderUnikey) external override {
        require(
            customerList[msg.sender].recommender != address(0),
            "the customer recommender exists"
        );
        address recom_address = customerUniKey[_recommanderUnikey];
        uint128 temp_maxNO = recommander_MaxCustomerNo[recom_address];
        if (temp_maxNO >= 1 && temp_maxNO + 1 > temp_maxNO) {
            temp_maxNO += 1;
        } else {
            temp_maxNO = 1;
        }
        recommander_MaxCustomerNo[recom_address] = temp_maxNO;
        recommender_CustomerList[recom_address][temp_maxNO] = msg.sender;
        customerList[msg.sender].recommender = recom_address;
        emit e_addRelation(msg.sender, _recommanderUnikey);
    }

    function updateCustomerNeckName(bytes32 _newname) external override {
        require(
            customerList[msg.sender].isUsed =
                true &&
                customerList[msg.sender].contractAddress == msg.sender,
            "customer is not exists"
        );
        customerList[msg.sender].neckname = _newname;
        emit e_updateCustomerNeckName(msg.sender, _newname);
    }

    function getCustomer(
        address _CustomerAddress
    ) external view override returns (LCustomer.Info memory) {
        require(
            customerList[_CustomerAddress].isUsed == true,
            " Customer is not exists"
        );
        return customerList[_CustomerAddress];
    }

    function isValidCustomer(
        address _CustomerAddress
    ) external view override returns (bool) {
        return customerList[_CustomerAddress].isUsed;
    }

    function getCustomerRecommander(
        address _customer
    ) external view override returns (address) {
        require(
            customerList[_customer].isUsed == true,
            " Customer is not exists"
        );
        return customerList[_customer].recommender;
    }

    function getCustomerNumbyRecommander(
        address _recommander
    ) external view override returns (uint128) {
        require(_recommander != address(0), "customer address is null");
        return recommander_MaxCustomerNo[_recommander];
    }

    function getCustomerInfobyRecommander(
        address _recommander,
        uint128 _cumstomerindex
    ) external view override returns (LCustomer.Info memory) {
        require(_recommander != address(0), "customer address is null");
        return
            customerList[
                recommender_CustomerList[_recommander][_cumstomerindex]
            ];
    }

    function addCustomer(
        LCustomer.Info memory _customer,
        address _gator
    ) external {
        require(
            customerList[_customer.contractAddress].isUsed != true &&
                _customer.contractAddress == msg.sender,
            "customer is exists"
        );
        uint128 tmp_gateMaxNO = gateMaxCustomerNo[_gator];
        if (tmp_gateMaxNO >= 1 && tmp_gateMaxNO + 1 > tmp_gateMaxNO) {
            tmp_gateMaxNO += 1;
        } else tmp_gateMaxNO = 1;

        _customer.Gater = _gator;
        _customer.GaterKey = tmp_gateMaxNO;
        customerUniNextKey += 1;
        customerUniKey[customerUniNextKey] = msg.sender;
        _customer.customerKey = customerUniNextKey;
        customerList[_customer.contractAddress] = _customer;

        gateCustomerNo[_gator][_customer.contractAddress] = tmp_gateMaxNO;
        gateCustomerList[_gator][tmp_gateMaxNO] = _customer.contractAddress;
        emit e_addCustomer(_customer, _gator);
    }
}
