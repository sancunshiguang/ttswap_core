// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./MoonV1Gater.sol";
import "./MoonV1Manager.sol";

import "./libraries/base/LCoin.sol";
import "./interfaces/IMoonV1Coin.sol";

contract MoonV1Coin is IMoonV1Coin {
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

    address public immutable gateContractAddress;
    address public immutable marketorContractAddress;

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
        require(MoonV1Gater(gateContractAddress).isValidGater());
        _;
    }

    modifier onlyMarketManager() {
        require(MoonV1Manager(marketorContractAddress).ismarketManager());
        _;
    }

    /////////////////////////币种设置-市场/////////////////////
    /////////////////////////Coin Manage/////////////////////

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function addCoinbyMarketor(LCoin.Info memory _coinInfo)
        external
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
    ) external onlyMarketManager {
        require(
            gateCoinList[_gateaddress][_contractaddress] == address(0),
            "the coin is not exists"
        );
        delete gateCoinList[_gateaddress][_contractaddress];
    }

    /////////////////////////币种设置-门户/////////////////////
    /////////////////////////Coin Manage/////////////////////
    function addCoinbyGator(LCoin.Info memory _coinInfo) external onlyGator {
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
        onlyGator
    {
        require(
            coinList[_internalCoinAddress].creator == msg.sender,
            "you have not the right"
        );
        coinList[_internalCoinAddress].unlock = true;
    }

    function lockCoinbyGator(address _internalCoinAddress) external onlyGator {
        require(
            coinList[_internalCoinAddress].creator == msg.sender,
            "you have not the right"
        );
        coinList[_internalCoinAddress].unlock = false;
    }

    function updateCoinbyGator(LCoin.Info memory _coinInfo) external onlyGator {
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
        returns (LCoin.Info memory)
    {
        require(
            coinList[_contractaddress].isUsed == true,
            "the coin is not exists"
        );
        return coinList[_contractaddress];
    }

    function isValidCoin(address _coinAddress) public view returns (bool) {
        return coinList[_coinAddress].marketunlock;
    }
}
