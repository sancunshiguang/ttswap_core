// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./libraries/base/LCoin.sol";
import "./interfaces/ITTSwapV1Coin.sol";
import "./interfaces/Marketor/IMarketorV1State.sol";
import "./interfaces/Gator/IGatorV1State.sol";

abstract contract TTSwapV1Coin is ITTSwapV1Coin {
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

    address public immutable gatorContractAddress;
    address public immutable marketorContractAddress;

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

    /////////////////////////币种设置-市场/////////////////////
    /////////////////////////Coin Manage/////////////////////

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function addCoinbyMarketor(
        LCoin.Info memory _coinInfo
    ) external onlyMarketor {
        require(
            coinList[_coinInfo.contractAddress].isUsed != true,
            "the coin exist"
        );
        _coinInfo.creator = msg.sender;
        _coinInfo.marketunlock = false;
        _coinInfo.gateunlock = true;
        _coinInfo.isUsed = true;
        if (
            coinMaxNo[marketorContractAddress] >= 1 &&
            coinMaxNo[marketorContractAddress] + 1 >=
            coinMaxNo[marketorContractAddress]
        ) {
            coinMaxNo[marketorContractAddress] += 1;
        } else {
            coinMaxNo[marketorContractAddress] = 1;
        }
        ownerCoinList[marketorContractAddress][
            coinMaxNo[marketorContractAddress]
        ] = _coinInfo.contractAddress;

        coinList[_coinInfo.contractAddress] = _coinInfo;
        ownerCoinList[marketorContractAddress][
            coinMaxNo[marketorContractAddress]
        ] = _coinInfo.contractAddress;
        ownerCoinNo[marketorContractAddress][
            _coinInfo.contractAddress
        ] = coinMaxNo[marketorContractAddress];
    }

    function lockCoinbyMarketor(
        address _internalCoinAddress
    ) external onlyMarketor {
        coinList[_internalCoinAddress].marketunlock = false;
    }

    function unlockCoinbyMarketor(
        address _internalCoinAddress
    ) external onlyMarketor {
        coinList[_internalCoinAddress].marketunlock = true;
    }

    function updateCoinbyMarketor(
        LCoin.Info memory _coinInfo
    ) external onlyMarketor {
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
    }

    function impoveGateCoinbyMarketor(
        address _contractaddress
    ) external onlyMarketor {
        require(
            coinList[_contractaddress].isUsed = true,
            "the coin is not exists"
        );
        require(
            ownerCoinNo[marketorContractAddress][_contractaddress] > 0,
            "the coin is  exists in market"
        );

        if (
            coinMaxNo[marketorContractAddress] >= 1 &&
            coinMaxNo[marketorContractAddress] + 1 >=
            coinMaxNo[marketorContractAddress]
        ) {
            coinMaxNo[marketorContractAddress] += 1;
        } else {
            coinMaxNo[marketorContractAddress] = 1;
        }
        ownerCoinList[marketorContractAddress][
            coinMaxNo[marketorContractAddress]
        ] = _contractaddress;

        ownerCoinNo[marketorContractAddress][_contractaddress] = coinMaxNo[
            marketorContractAddress
        ];
    }

    function delCoinbyMarketor(address _contractaddress) external onlyMarketor {
        require(
            ownerCoinNo[marketorContractAddress][_contractaddress] >= 1,
            "the coin is not exists"
        );

        delete ownerCoinList[marketorContractAddress][
            ownerCoinNo[marketorContractAddress][_contractaddress]
        ];
        delete ownerCoinNo[marketorContractAddress][_contractaddress];
    }

    function delCoinbyMarketor(uint128 _coinNo) external onlyMarketor {
        require(
            ownerCoinList[marketorContractAddress][_coinNo] != address(0),
            "the coin is not exists"
        );

        delete ownerCoinNo[marketorContractAddress][
            ownerCoinList[marketorContractAddress][_coinNo]
        ];
        delete ownerCoinList[marketorContractAddress][_coinNo];
    }

    /////////////////////////币种设置-门户/////////////////////
    /////////////////////////Coin Manage/////////////////////
    function addCoinbyGator(LCoin.Info memory _coinInfo) external onlyGator {
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
    }

    function unlockCoinbyGator(
        address _internalCoinAddress
    ) external onlyGator {
        require(
            coinList[_internalCoinAddress].creator == msg.sender,
            "you have not the right"
        );
        coinList[_internalCoinAddress].gateunlock = true;
    }

    function lockCoinbyGator(address _internalCoinAddress) external onlyGator {
        require(
            coinList[_internalCoinAddress].creator == msg.sender,
            "you have not the right"
        );
        coinList[_internalCoinAddress].gateunlock = false;
    }

    function updateCoinbyGator(LCoin.Info memory _coinInfo) external onlyGator {
        require(
            coinList[_coinInfo.contractAddress].creator == msg.sender,
            "you have not the right"
        );

        _coinInfo.marketunlock = false;
        _coinInfo.gateunlock = false;
        _coinInfo.isUsed = true;
        _coinInfo.creator = msg.sender;
        coinList[_coinInfo.contractAddress] = _coinInfo;
    }

    function getCoinInfo(
        address _contractaddress
    ) external view returns (LCoin.Info memory) {
        require(
            coinList[_contractaddress].isUsed == true,
            "the coin is not exists"
        );
        return coinList[_contractaddress];
    }

    function getCoinInfo(
        address _owneraddress,
        uint128 _coinNo
    ) external view returns (LCoin.Info memory) {
        require(
            coinList[_owneraddress].isUsed == true,
            "the coin is not exists"
        );
        return coinList[ownerCoinList[_owneraddress][_coinNo]];
    }

    function isValidCoin(address _coinAddress) public view returns (bool) {
        return coinList[_coinAddress].marketunlock;
    }

    function getcoinMaxNo(address _owneraddress) public view returns (uint128) {
        return coinMaxNo[_owneraddress];
    }
}
