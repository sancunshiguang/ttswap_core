// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

library LGate {
    struct Info {
        // the address of the Market
        // 记录market地址
        address market;
        //Gator地址
        address gateAddress;
        // the name of the Organization
        // 记录大门的名称
        uint160 authority;
        // the name of the Organization
        // 记录大门的名称
        string name;
        // the nation of the Organization
        // 记录公司与组织的国家
        // bytes32 website;
        // the website of the Organization
        // 记录公司与组织的服务ip
        // bytes32[10] webserverip;
        // the create timestamp of the Organization
        // 记录公司与组织的创建时间
        // uint32 createtimestamp;
        // 如果门户违反行为准则,进行冻结限制
        bool marketunlock;
        // config by the gater
        bool gateunlock;
        bool isUsed;
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
