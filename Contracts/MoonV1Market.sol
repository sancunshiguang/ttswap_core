// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

//import "./interfaces/IMoonV1Market.sol";
//import "./MoonV1ShopCreate.sol";

import "./NoDelegateCall.sol";
import "./libraries/base/LShop.sol";

import "./MoonV1Marketor.sol";
import "./MoonV1Gater.sol";
import "./MoonV1Coin.sol";
import "./MoonV1Thing.sol";
import "./MoonV1Customer.sol";

contract MoonV1Market is NoDelegateCall {
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
    mapping(address => mapping(address => address)) public shopaddress;

    mapping(address => LShop.Info) public shopList;

    mapping(uint24 => int24) public profitUnitSpacing;

    address public marketContractAddress;
    address public gateContractAddress;
    address public marketorContractAddress;
    address public coinContractAddress;
    address public thingContractAddress;
    address public customerContractAddress;

    modifier onlyMarketCreator() {
        require(msg.sender == marketCreator);
        _;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    modifier onlyMarketor() {
        require(
            MoonV1Marketor(marketorContractAddress).ismarketMarketor() == true
        );
        _;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    modifier onlyGator() {
        require(MoonV1Gater(gateContractAddress).isValidGater());
        _;
    }

    //initial Market
    constructor() {
        marketCreator = msg.sender;
        marketContractAddress = address(this);
        marketorContractAddress = address(
            new MoonV1Marketor{salt: sha256(abi.encode(marketContractAddress))}(
                marketCreator
            )
        );

        gateContractAddress = address(
            new MoonV1Gater{salt: sha256(abi.encode(marketContractAddress))}(
                gateContractAddress,
                marketorContractAddress
            )
        );

        coinContractAddress = address(
            new MoonV1Coin{salt: sha256(abi.encode(marketContractAddress))}(
                gateContractAddress,
                marketorContractAddress
            )
        );

        thingContractAddress = address(
            new MoonV1Coin{salt: sha256(abi.encode(marketContractAddress))}(
                gateContractAddress,
                marketorContractAddress
            )
        );

        customerContractAddress = address(
            new MoonV1Customer{salt: sha256(abi.encode(marketContractAddress))}(
                gateContractAddress,
                marketorContractAddress
            )
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
        //profitUnitSpacing[500] = 10;
        //profitUnitSpacing[3000] = 60;
        //profitUnitSpacing[10000] = 200;
    }

    //记录手费费分配方式
    //config the default fee share'pay
    LProfitShares.Info public marketProfitshares =
        LProfitShares.Info({
            marketshare: 20,
            gatershare: 40,
            commandershare: 20,
            usershare: 20
        });

    /////////////////////////管理设置/////////////////////
    /////////////////////////manage config/////////////////////

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function setMarketProfitshare(LProfitShares.Info memory _profitshare)
        external
        onlyMarketCreator
    {
        marketProfitshares = _profitshare;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param _coin the coin of the shop
    /// @param _thing the things of the shop
    /// @param _profit  交易手续费费率fee percentage of swap
    function createShopbyMarketor(
        address _coin,
        address _thing,
        uint24 _profit
    ) external noDelegateCall onlyMarketor returns (address shop) {
        if (
            shopaddress[_coin][_thing] == address(0) &&
            shopaddress[_thing][_coin] == address(0)
        ) {
            /*   shop = deploy(
                marketCreator,
                _coin,
                _thing,
                _profit,
                profitUnitSpacing[_profit],
                marketProfitshares
            );
*/
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
    ) external noDelegateCall onlyGator returns (address shop) {
        require(_coin != _thing, "the coin is same as the thing ");
        require(
            MoonV1Coin(coinContractAddress).isValidCoin(_coin) == true &&
                MoonV1Thing(thingContractAddress).isValidThing(_thing) == true,
            "coin or thing is not valid"
        );

        if (
            shopaddress[_coin][_thing] == address(0) &&
            shopaddress[_thing][_coin] == address(0)
        ) {
            /*shop = deploy(
                msg.sender,
                _coin,
                _thing,
                _profit,
                profitUnitSpacing[_profit],
                marketProfitshares
            );*/

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

    function raiseShopLevelbyMarketor(address shop) external onlyMarketor {
        require(
            marketShopList[shop] = true && shopList[shop].isUsed == true,
            "the shop not exists in the gate"
        );
        marketShopList[shop] = true;
    }
}
