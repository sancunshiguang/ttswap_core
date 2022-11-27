// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../LProfitShares.sol";

library LShop {
    struct Info {
        address Market;
        address coin;
        address thing;
        uint24 profit;
        int24 unitSpacing;
        LProfitShares.Info profitshares;
        address gater;
        bool isUsed;
    }
}
