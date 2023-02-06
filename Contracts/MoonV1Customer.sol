// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./libraries/base/LCustomer.sol";
import "./MoonV1Gater.sol";
import "./MoonV1Marketor.sol";

contract MoonV1Customer {
    /////////////////////////用户管理-市场////////////////////////////
    /////////////////////////user Manage/////////////////////

    //客户地址=>客户信息
    //customeraddress =>customer detail info
    mapping(address => LCustomer.Info) public customerList;

    mapping(uint40 => address) public customerUniKey; //用户号
    uint40 public customerUniNextKey; //用户下个编号
    mapping(address => uint32) public recommenderraltionkey;
    mapping(address => mapping(uint32 => address))
        public recommenderraltionlist;

    mapping(address => uint32) public gateCustomerNextKey;
    mapping(address => mapping(uint32 => address)) public gateCustomerList;

    address public immutable gateContractAddress;
    address public immutable marketorContractAddress;

    constructor(address _gateContractAddress, address _marketorContractAddress)
    {
        gateContractAddress = _gateContractAddress;
        marketorContractAddress = _marketorContractAddress;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    modifier onlyGator() {
        require(MoonV1Gater(gateContractAddress).isValidGater());
        _;
    }

    modifier onlyMarketor() {
        require(
            MoonV1Marketor(marketorContractAddress).ismarketMarketor() == true
        );
        _;
    }

    /////////////////////////用户管理-市场////////////////////////////
    /////////////////////////user Manage/////////////////////
    function lockCustomerbyMarketor(address _CustomerAddress)
        external
        onlyMarketor
    {
        require(
            customerList[_CustomerAddress].isUsed != true,
            "customer is not exists"
        );
        customerList[_CustomerAddress].unlock = false;
    }

    function unlockCustomerbyMarketor(address _CustomerAddress)
        external
        onlyMarketor
    {
        require(
            customerList[_CustomerAddress].isUsed != true,
            "customer is not exists"
        );
        customerList[_CustomerAddress].unlock = true;
    }

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
    function addCustomer(LCustomer.Info memory _customer) external {
        require(
            customerList[_customer.contractAddress].isUsed != true &&
                _customer.contractAddress == msg.sender,
            "customer is exists"
        );

        customerUniNextKey += 1;
        customerUniKey[customerUniNextKey] = msg.sender;
        _customer.customerKey = customerUniNextKey;
        customerList[_customer.contractAddress] = _customer;
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
        returns (LCustomer.Info memory)
    {
        require(
            customerList[_CustomerAddress].isUsed == true,
            " Customer is not exists"
        );
        return customerList[_CustomerAddress];
    }

    function isValidCustomer(address _CustomerAddress)
        external
        view
        returns (bool)
    {
        return customerList[_CustomerAddress].isUsed;
    }

    function getCustomerRecommander(address _customer)
        external
        view
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
        _customer.Gater = _gater;
        _customer.GaterKey = gateCustomerNextKey[_gater];
        customerUniNextKey += 1;
        customerUniKey[customerUniNextKey] = msg.sender;
        _customer.customerKey = customerUniNextKey;
        customerList[_customer.contractAddress] = _customer;
        gateCustomerList[_gater][gateCustomerNextKey[_gater]] = msg.sender;
    }
}
