// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../libraries/LProfitShares.sol";

interface IMoonV1MarketShopCreate {
    function inputParas()
        external
        view
        returns (
            address market,
            address coin,
            address thing,
            uint24 profit,
            int24 unitSpacing,
            LProfitShares.Info memory profitshares
        );
}
