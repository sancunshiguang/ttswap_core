// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

library LThing {
    struct Info {
        // recode the neckname (Not Real Name) of customer(length<32)
        // 记录用户别名(长度小于32字节)
        bytes32 name;
        // recode which organization the customer belong.
        // 记录所有者组织
        address ownerAddress;
        // 1:lawCoin,2:organCoin,3:marketCoin,4:gateCoin
        bytes32 LSTThingsFullName;
        //symbol
        bytes6 symbol;
        uint8 scope; //1:货币式加密货币 2:应用型加密货币 3:平台型加密货币
        //合约地址
        address contractAddress;
        bool marketunlock;
        bool unlock;
        bool createrunlock;
        bool isUsed;
        address addfromgator;
        address creator;
    }
}
