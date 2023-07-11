// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

//import "./interfaces/ITTSwapV1Market.sol";
//import "./TTSwapV1ShopCreate.sol";

import "./NoDelegateCall.sol";
import "./libraries/base/LShop.sol";

import "./interfaces/Marketor/IMarketorV1State.sol";
import "./interfaces/Gator/IGatorV1State.sol";
import "./TTSwapV1Gator.sol";
import "./TTSwapV1Coin.sol";
import "./TTSwapV1Thing.sol";
import "./TTSwapV1Customer.sol";
import "./TTSwapV1Marketor.sol";
import "./TTSwapV1ShopCreate.sol";

contract TTSwapV1Market is TTSwapV1ShopCreate, NoDelegateCall {
    //市场门店信息
    //币种-物品-店铺地址
    //ShopAddress
    mapping(address => bool) public marketShopList;
    address public marketCreator;

    //门户门店信息
    //门户-币种-物品-店铺地址
    //gateaddress=>ShopAddress
    mapping(address => mapping(address => bool)) public gateShopList;

    //门户门店信息
    mapping(address => mapping(address => mapping(uint24 => address)))
        public shopaddress;

    mapping(address => LShop.Info) public shopList;

    mapping(uint24 => int24) public profitUnitSpacing;

    address public immutable gatorContractAddress;
    address public immutable marketContractAddress;
    address public immutable marketorContractAddress;
    address public immutable coinContractAddress;
    address public immutable thingContractAddress;
    address public immutable customerContractAddress;

    modifier onlyMarketCreator() {
        require(msg.sender == marketCreator);
        _;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    modifier onlyMarketor() {
        require(IMarketorV1State(marketContractAddress).isValidMarketor());
        _;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    modifier onlyGator() {
        require(IGatorV1State(gatorContractAddress).isValidGator());
        _;
    }

    //initial Market
    constructor() {
        marketCreator = msg.sender;
        marketContractAddress = address(this);
        marketorContractAddress = address(
            new TTSwapV1Marketor{
                salt: sha256(abi.encode(marketContractAddress))
            }(marketCreator)
        );

        gatorContractAddress = address(
            new TTSwapV1Gator{salt: sha256(abi.encode(marketContractAddress))}(
                marketorContractAddress,
                marketCreator
            )
        );

        coinContractAddress = address(
            new TTSwapV1Coin{salt: sha256(abi.encode(marketContractAddress))}(
                gatorContractAddress,
                marketorContractAddress
            )
        );

        thingContractAddress = address(
            new TTSwapV1Thing{salt: sha256(abi.encode(marketContractAddress))}(
                gatorContractAddress,
                marketorContractAddress
            )
        );

        customerContractAddress = address(
            new TTSwapV1Customer{
                salt: sha256(abi.encode(marketContractAddress))
            }(gatorContractAddress, marketorContractAddress)
        );

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
        profitUnitSpacing[500] = 10;
        profitUnitSpacing[3000] = 60;
        profitUnitSpacing[10000] = 200;
    }

    //记录手费费分配方式
    //config the default fee share'pay
    LProfitShares.Info public marketProfitshares =
        LProfitShares.Info({
            investshare: 20,
            marketshare: 20,
            gatorshare: 40,
            commandershare: 20,
            usershare: 20
        });

    /////////////////////////管理设置/////////////////////
    /////////////////////////manage config/////////////////////

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function setMarketProfitshareByMarketor(
        LProfitShares.Info memory _profitshare
    ) external onlyMarketCreator {
        marketProfitshares = _profitshare;
    }

    // @notice Explain to an end user what this does
    // @dev Explain to a developer any extra details
    // @param _coin the coin of the shop
    // @param _thing the things of the shop
    // @param _profit  交易手续费费率fee percentage of swap
    function createShopbyGator(
        address _coin,
        address _thing,
        uint24 _profit
    ) external noDelegateCall onlyGator returns (address shop) {
        require(_coin != _thing, "the coin is same as the thing ");

        bool token1_coin_true = TTSwapV1Coin(coinContractAddress).isValidCoin(
            _coin
        );

        bool token1_thing_true = TTSwapV1Coin(coinContractAddress).isValidCoin(
            _thing
        );

        bool token2_coin_true = TTSwapV1Thing(thingContractAddress)
            .isValidThing(_coin);

        bool token2_thing_true = TTSwapV1Thing(thingContractAddress)
            .isValidThing(_thing);

        if (
            shopaddress[_coin][_thing][_profit] == address(0) &&
            shopaddress[_thing][_coin][_profit] == address(0)
        ) {
            shop = deploy(
                marketContractAddress,
                _coin,
                _thing,
                _profit,
                profitUnitSpacing[_profit],
                marketProfitshares
            );

            shopaddress[_coin][_thing][_profit] = shop;
            shopaddress[_thing][_coin][_profit] = shop;

            shopList[shop].Market = marketContractAddress;
            shopList[shop].coin = _coin;
            shopList[shop].thing = _thing;
            shopList[shop].profit = _profit;
            shopList[shop].unitSpacing = profitUnitSpacing[_profit];
            gateShopList[msg.sender][shop] = true;
            delete shop;
        } else {}
    }

    function raiseShopLevelbyMarketor(address shop) external onlyMarketor {
        require(
            marketShopList[shop] = true && shopList[shop].isUsed == true,
            "the shop not exists in the gate"
        );
        marketShopList[shop] = true;
    }
}
