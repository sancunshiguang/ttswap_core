// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

library LThing {
    struct Info {
        // 记录用户别名(长度小于32字节)
        bytes32 name; //名称
        bytes6 symbol; //符号
        uint256 typecode; // 所有经济活动的国际标准行业分类编码
        address contractAddress;
        // uint8 decimals; //精度
        // uint256 maxSupply; //流通量
        // uint256 totalSupply; //发行量
        uint256 boolcode; //marketunlock|gateunlock|createrunlock|isUsed
        bool marketunlock;
        bool gateunlock;
        bool createrunlock;
        bool isUsed;
        address addfromgator;
        address creator;
        uint8 internal_fee; //10000单位,1表示万分之一
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
