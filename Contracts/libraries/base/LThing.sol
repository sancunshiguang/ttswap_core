// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

library LThing {
    struct Info {
        // recode the neckname (Not Real Name) of customer(length<32)
        // 记录用户别名(长度小于32字节)
        bytes32 name;
        address ownerAddress;
        bytes6 symbol;
        uint8 typecode;
        address contractAddress;
        bool marketunlock;
        bool gatelock;
        bool createrunlock;
        bool isUsed;
        address addfromgator;
        address creator;
    }

    struct DetailInfo {
        address contractAddress; //合约地址
        bytes32 WhitePaperUrl; //白皮书地址
        bytes32 OfficalWebsite; //官网
        bytes32 blockExplorerUrl; //区块查询
        bytes32 twriterUrl; //区块查询
        bytes32 bbsUrl; //区块查询
    }
}
