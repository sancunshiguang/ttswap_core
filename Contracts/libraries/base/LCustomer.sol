// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

library LCustomer {
    struct Info {
        // recode the neckname (Not Real Name) of customer(length<32)
        // 记录用户别名(长度小于32字节)
        bytes32 neckname;
        // recode the createtime of the customer
        // 记录用户的创建时间
        uint32 createtimestamp;
        // recode the recommendder of this customer
        // 记录用户的推荐人
        address recommender;
        // 记录用户的唯一号
        uint40 customerKey;
        // 记录用户的推荐人
        address Gater;
        uint32 GaterKey;
        // 客户地址
        address contractAddress;
        bool isUsed;
        bool unlock;
    }
}
