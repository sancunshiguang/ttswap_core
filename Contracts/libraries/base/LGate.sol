// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

library LGate {
    struct Info {
        // the address of the Market
        // 记录market地址
        //Gate编号
        uint128 gateNo;
        // 门户地址
        address gateAddress;
        // 门户简称
        string name;
        //创建时间
        uint256 createtimestamp;
        // 如果门户违反行为准则,进行冻结限制
        bool marketunlock; //true 表示已解冻 false表示已冻结
        // config by the gater
        bool gateunlock; //true 表示已解冻 false表示已冻结
        bool isUsed;
    }

    //相应接口
    struct DetailInfo {
        string full_name; //全称
        string WhitePaperUrl; //白皮书地址
        string OfficalWebsite; //官网
        string blockExplorerUrl; //区块查询
        string twriterUrl; //区块查询
        string bbsUrl; //bbs论坛地址
    }
}
