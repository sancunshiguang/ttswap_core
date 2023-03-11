// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

library LCoin {
    struct Info {
        bytes32 coinFullName; //币种全称
        bytes6 symbol; //币种简称
        uint8 scope; //类型  1:lawCoin 稳定币,2:organCoin 公链币,3:marketCoin 市场币,4:gateCoin 门户币
        uint8 decimals; //精度
        uint256 maxSupply; //流通量
        uint256 totalSupply; //发行量
        address contractAddress; //合约地址
       // bytes32 WhitePaperUrl; //白皮书地址
       // bytes32 OfficalWebsite; //官网
        //bytes32 blockExplorerUrl; //区块查询
        bool marketunlock; //市场锁
        bool unlock; //门户锁
        address creator; //添加人
        bool isUsed;
    }
}
