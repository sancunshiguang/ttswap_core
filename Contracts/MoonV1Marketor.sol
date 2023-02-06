// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./interfaces/IMoonV1Marketor.sol";

contract MoonV1Marketor is IMoonV1Marketor {
    //市场管理员
    //marketMarketors
    mapping(address => bool) public marketMarketors;

    address public marketCreator;

    constructor(address _marketCreator) {
        marketCreator = _marketCreator;
    }

    modifier onlyMarketCreator() {
        require(msg.sender == marketCreator);
        _;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function setMarketMarketor(address _owner)
        external
        override
        onlyMarketCreator
    {
        marketMarketors[_owner] = true;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function delMarketMarketor(address _owner)
        external
        override
        onlyMarketCreator
    {
        delete marketMarketors[_owner];
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function ismarketMarketor() external view override returns (bool) {
        return marketMarketors[msg.sender];
    }
}
