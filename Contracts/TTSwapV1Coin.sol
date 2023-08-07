// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./libraries/base/LCoin.sol";
import "./interfaces/ITTSwapV1Coin.sol";
import "./interfaces/Marketor/IMarketorV1State.sol";
import "./interfaces/Gator/IGatorV1State.sol";

contract TTSwapV1Coin is ITTSwapV1Coin {
    //owneraddress => coinMaxNo
    mapping(address => uint128) public coinMaxNo;
    //门户币种信息
    //币种地址 => 币种信息
    //owneraddress => coinNo => coinaddress
    mapping(address => mapping(uint128 => address)) public ownerCoinList;
    //owneraddress => coinaddress=>coinNo
    mapping(address => mapping(address => uint128)) public ownerCoinNo;

    //币种信息
    //币种地址 => 币种信息
    //coinaddress => coinInfo
    mapping(address => LCoin.Info) public coinList;
    mapping(address => LCoin.DetailInfo) public coinDetailList;

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

    function setCoinEnv(
        address _marketorContractAddress,
        address _gatorContractAddress,
        address _marketCreator
    ) external onlyMarketCreator {
        marketorContractAddress = _marketorContractAddress;
        gatorContractAddress = _gatorContractAddress;
        marketCreator = _marketCreator;
    }

    /////////////////////////币种设置-市场/////////////////////
    /////////////////////////Coin Manage/////////////////////

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function addCoinbyMarketor(
        LCoin.Info memory _coinInfo
    ) external override onlyMarketor {
        require(
            coinList[_coinInfo.contractAddress].isUsed != true,
            "the coin exist"
        );
        _coinInfo.creator = msg.sender;
        _coinInfo.marketunlock = false;
        _coinInfo.gateunlock = true;
        _coinInfo.isUsed = true;
        uint128 coin_MaxNo = coinMaxNo[marketorContractAddress];
        if (coin_MaxNo >= 1 && coin_MaxNo + 1 >= coin_MaxNo) {
            coin_MaxNo += 1;
        } else {
            coin_MaxNo = 1;
        }
        coinMaxNo[marketorContractAddress] = coin_MaxNo;

        ownerCoinList[marketorContractAddress][coin_MaxNo] = _coinInfo
            .contractAddress;
        ownerCoinNo[marketorContractAddress][
            _coinInfo.contractAddress
        ] = coin_MaxNo;

        coinList[_coinInfo.contractAddress] = _coinInfo;
        emit e_addCoinbyMarketor(_coinInfo);
    }

    function addCoinDetailInfobyMarketor(
        LCoin.DetailInfo memory _coinDetailInfo
    ) external override onlyMarketor {
        coinDetailList[_coinDetailInfo.contractAddress] = _coinDetailInfo;
        emit e_addCoinDetailbyGator(_coinDetailInfo.contractAddress);
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function addCoinFullinfobyMarketor(
        LCoin.Info memory _coinInfo,
        LCoin.DetailInfo memory _coinDetailInfo
    ) external override onlyMarketor {
        require(
            coinList[_coinInfo.contractAddress].isUsed != true,
            "the coin exist"
        );
        _coinInfo.creator = msg.sender;
        _coinInfo.marketunlock = false;
        _coinInfo.gateunlock = true;
        _coinInfo.isUsed = true;
        uint128 coin_MaxNo = coinMaxNo[marketorContractAddress];
        if (coin_MaxNo >= 1 && coin_MaxNo + 1 >= coin_MaxNo) {
            coin_MaxNo += 1;
        } else {
            coin_MaxNo = 1;
        }
        coinMaxNo[marketorContractAddress] = coin_MaxNo;

        ownerCoinList[marketorContractAddress][coin_MaxNo] = _coinInfo
            .contractAddress;
        ownerCoinNo[marketorContractAddress][
            _coinInfo.contractAddress
        ] = coin_MaxNo;

        coinList[_coinInfo.contractAddress] = _coinInfo;
        emit e_addCoinbyMarketor(_coinInfo);
        coinDetailList[_coinDetailInfo.contractAddress] = _coinDetailInfo;
        emit e_addCoinDetailbyGator(_coinDetailInfo.contractAddress);
    }

    function lockCoinbyMarketor(
        address _CoinAddress
    ) external override onlyMarketor {
        coinList[_CoinAddress].marketunlock = false;
        emit e_lockCoinbyMarketor(_CoinAddress);
    }

    function unlockCoinbyMarketor(
        address _CoinAddress
    ) external override onlyMarketor {
        coinList[_CoinAddress].marketunlock = true;
        emit e_unlockCoinbyMarketor(_CoinAddress);
    }

    function updateCoinbyMarketor(
        LCoin.Info memory _coinInfo
    ) external override onlyMarketor {
        require(
            ownerCoinNo[marketorContractAddress][_coinInfo.contractAddress] >=
                0,
            "the coin don't exist in the market"
        );
        _coinInfo.marketunlock = true;
        _coinInfo.gateunlock = false;
        _coinInfo.isUsed = true;
        _coinInfo.creator = coinList[_coinInfo.contractAddress].creator;
        coinList[_coinInfo.contractAddress] = _coinInfo;
        emit e_updateCoinbyMarketor(_coinInfo);
    }

    function impoveGateCoinbyMarketor(
        address _contractaddress
    ) external override onlyMarketor {
        require(
            coinList[_contractaddress].isUsed = true,
            "the coin is not exists"
        );
        require(
            ownerCoinNo[marketorContractAddress][_contractaddress] > 0,
            "the coin is  exists in market"
        );
        uint128 coin_MaxNo = coinMaxNo[marketorContractAddress];
        if (coin_MaxNo >= 1 && coin_MaxNo + 1 >= coin_MaxNo) {
            coin_MaxNo += 1;
        } else {
            coin_MaxNo = 1;
        }
        coinMaxNo[marketorContractAddress] = coin_MaxNo;
        ownerCoinList[marketorContractAddress][coin_MaxNo] = _contractaddress;
        ownerCoinNo[marketorContractAddress][_contractaddress] = coin_MaxNo;
        emit e_impoveGateCoinbyMarketor(_contractaddress);
    }

    function delCoinbyMarketor(
        address _contractaddress
    ) external override onlyMarketor {
        require(
            ownerCoinNo[marketorContractAddress][_contractaddress] >= 1,
            "the coin is not exists"
        );

        delete ownerCoinList[marketorContractAddress][
            ownerCoinNo[marketorContractAddress][_contractaddress]
        ];
        delete ownerCoinNo[marketorContractAddress][_contractaddress];

        emit e_delCoinbyMarketor(_contractaddress);
    }

    function delCoinbyMarketor(uint128 _coinNo) external override onlyMarketor {
        require(
            ownerCoinList[marketorContractAddress][_coinNo] != address(0),
            "the coin is not exists"
        );

        delete ownerCoinNo[marketorContractAddress][
            ownerCoinList[marketorContractAddress][_coinNo]
        ];
        delete ownerCoinList[marketorContractAddress][_coinNo];
        emit e_delCoinbyMarketor(_coinNo);
    }

    /////////////////////////币种设置-门户/////////////////////
    /////////////////////////Coin Manage/////////////////////
    function addCoinbyGator(
        LCoin.Info memory _coinInfo
    ) external override onlyGator {
        require(
            coinList[_coinInfo.contractAddress].isUsed != true,
            "the coin is  exist"
        );
        _coinInfo.creator = msg.sender;
        _coinInfo.marketunlock = false;
        _coinInfo.gateunlock = false;
        _coinInfo.isUsed = true;
        if (
            coinMaxNo[msg.sender] >= 1 &&
            coinMaxNo[msg.sender] + 1 >= coinMaxNo[msg.sender]
        ) {
            coinMaxNo[msg.sender] += 1;
        } else {
            coinMaxNo[msg.sender] = 1;
        }
        ownerCoinList[msg.sender][coinMaxNo[msg.sender]] = _coinInfo
            .contractAddress;
        ownerCoinNo[msg.sender][_coinInfo.contractAddress] = coinMaxNo[
            msg.sender
        ];
        coinList[_coinInfo.contractAddress] = _coinInfo;
        emit e_addCoinbyGator(msg.sender, _coinInfo);
    }

    function addCoinDetailInfobyGator(
        LCoin.DetailInfo memory _coinDetailInfo
    ) external override onlyGator {
        require(
            coinList[_coinDetailInfo.contractAddress].creator == msg.sender,
            "you is not the thing creater"
        );
        coinDetailList[_coinDetailInfo.contractAddress] = _coinDetailInfo;
        emit e_addCoinDetailbyGator(_coinDetailInfo.contractAddress);
    }

    function addCoinFullinfobyGator(
        LCoin.Info memory _coinInfo,
        LCoin.DetailInfo memory _coinDetailInfo
    ) external override onlyGator {
        require(
            coinList[_coinInfo.contractAddress].isUsed != true,
            "the coin is  exist"
        );
        _coinInfo.creator = msg.sender;
        _coinInfo.marketunlock = false;
        _coinInfo.gateunlock = false;
        _coinInfo.isUsed = true;
        if (
            coinMaxNo[msg.sender] >= 1 &&
            coinMaxNo[msg.sender] + 1 >= coinMaxNo[msg.sender]
        ) {
            coinMaxNo[msg.sender] += 1;
        } else {
            coinMaxNo[msg.sender] = 1;
        }
        ownerCoinList[msg.sender][coinMaxNo[msg.sender]] = _coinInfo
            .contractAddress;
        ownerCoinNo[msg.sender][_coinInfo.contractAddress] = coinMaxNo[
            msg.sender
        ];
        coinList[_coinInfo.contractAddress] = _coinInfo;
        emit e_addCoinbyGator(msg.sender, _coinInfo);
        require(
            coinList[_coinDetailInfo.contractAddress].creator == msg.sender,
            "you is not the thing creater"
        );
        coinDetailList[_coinDetailInfo.contractAddress] = _coinDetailInfo;
        emit e_addCoinDetailbyGator(_coinDetailInfo.contractAddress);
    }

    function unlockCoinbyGator(
        address _internalCoinAddress
    ) external override onlyGator {
        require(
            coinList[_internalCoinAddress].creator == msg.sender,
            "you have not the right"
        );
        coinList[_internalCoinAddress].gateunlock = true;

        emit e_unlockCoinbyGator(msg.sender, _internalCoinAddress);
    }

    function lockCoinbyGator(
        address _internalCoinAddress
    ) external override onlyGator {
        require(
            coinList[_internalCoinAddress].creator == msg.sender,
            "you have not the right"
        );
        coinList[_internalCoinAddress].gateunlock = false;

        emit e_lockCoinbyGator(msg.sender, _internalCoinAddress);
    }

    function updateCoinbyGator(
        bytes32 coinFullName, //代币全称
        bytes32 symbol, //币种简称
        bytes32 typecode, //币种类型代码
        uint8 decimals, //精度
        uint256 maxSupply, //流通量
        uint256 totalSupply, //发行量
        address contractAddress //合约地址
    ) external override onlyGator {
        require(
            coinList[contractAddress].creator == msg.sender,
            "you have not the right"
        );
        coinList[contractAddress].coinFullName = coinFullName;
        coinList[contractAddress].symbol = symbol;
        coinList[contractAddress].typecode = typecode;
        coinList[contractAddress].decimals = decimals;
        coinList[contractAddress].maxSupply = maxSupply;
        coinList[contractAddress].decimals = decimals;
        coinList[contractAddress].totalSupply = totalSupply;

        emit e_updateCoinbyGator(msg.sender, coinList[contractAddress]);
    }

    function delCoinbyGator(
        address _contractaddress
    ) external override onlyGator {
        require(
            ownerCoinNo[msg.sender][_contractaddress] >= 1,
            "the coin is not exists"
        );

        delete ownerCoinList[msg.sender][
            ownerCoinNo[msg.sender][_contractaddress]
        ];
        delete ownerCoinNo[msg.sender][_contractaddress];

        emit e_delCoinbyGator(msg.sender, _contractaddress);
    }

    function delCoinbyGator(uint128 _coinNo) external override onlyGator {
        require(
            ownerCoinList[msg.sender][_coinNo] != address(0),
            "the coin is not exists"
        );

        delete ownerCoinNo[msg.sender][ownerCoinList[msg.sender][_coinNo]];
        delete ownerCoinList[msg.sender][_coinNo];

        emit e_delCoinbyGator(msg.sender, _coinNo);
    }

    function getCoinInfoFromaddress(
        address _contractaddress
    ) external view override returns (LCoin.Info memory) {
        require(
            coinList[_contractaddress].isUsed == true,
            "the coin is not exists"
        );
        return coinList[_contractaddress];
    }

    function getCoinInfoFromOwnerCoinNo(
        address _owneraddress,
        uint128 _coinNo
    ) external view override returns (LCoin.Info memory) {
        require(
            coinList[_owneraddress].isUsed == true,
            "the coin is not exists"
        );
        return coinList[ownerCoinList[_owneraddress][_coinNo]];
    }

    function isValidCoin(
        address _coinAddress
    ) external view override returns (bool) {
        return coinList[_coinAddress].marketunlock;
    }

    function getCoinMaxNo(
        address _owneraddress
    ) external view override returns (uint128) {
        return coinMaxNo[_owneraddress];
    }
}
