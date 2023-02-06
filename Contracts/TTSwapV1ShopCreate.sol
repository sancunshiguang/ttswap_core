// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;
import "./interfaces/ITTSwapV1MarketShopCreate.sol";
import "./TTSwapV1Shop.sol";

contract TTSwapV1ShopCreate is ITTSwapV1MarketShopCreate {
    struct InputParas {
        address market;
        address coin;
        address thing;
        uint24 profit;
        int24 unitSpacing;
        LProfitShares.Info profitshares;
    }

    // @inheritdoc ITTSwapV1MarketShopCreate InputParas public override inputParas;
    InputParas public override inputParas;

    function deploy(
        address _market,
        address _coin,
        address _thing,
        uint24 _profit,
        int24 _unitSpacing,
        LProfitShares.Info memory _profitshares
    ) internal returns (address shop) {
        inputParas = InputParas({
            market: _market,
            coin: _coin,
            thing: _thing,
            profit: _profit,
            unitSpacing: _unitSpacing,
            profitshares: _profitshares
        });

        shop = address(
            new TTSwapV1Shop{salt: sha256(abi.encode(_coin, _thing))}()
        );

        delete inputParas;
    }
}
