// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

library LCoin {
    struct Info {
        string coinFullName; //代币全称
        string symbol; //币种简称
        string typecode; //币种类型代码
        uint8 decimals; //精度
        uint256 maxSupply; //流通量
        uint256 totalSupply; //发行量
        address contractAddress; //合约地址
        bool marketunlock; //市场锁
        bool gateunlock; //门户锁
        bool isUsed;
        address creator; //添加人
    }
    struct DetailInfo {
        address contractAddress; //合约地址
        bytes32 WhitePaperUrl; //白皮书地址
        bytes32 OfficalWebsite; //官网
        bytes32 blockExplorerUrl; //区块查询
        bytes32 twriterUrl; //区块查询
        bytes32 bbsUrl; //bbs论坛地址
    }
}
