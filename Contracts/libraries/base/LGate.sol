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
        bytes32 name;
        // the nation of the Organization
        // 记录公司与组织的国家
        bytes32 website;
        // the website of the Organization
        // 记录公司与组织的服务ip
        bytes32[10] webserverip;
        // the create timestamp of the Organization
        // 记录公司与组织的创建时间
        uint32 createtimestamp;
        // 如果门户违反行为准则,进行冻结限制
        bool marketunlock;
        // config by the gater
        bool unlock;
        bool isUsed;
    }
}
