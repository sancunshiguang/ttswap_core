// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./interfaces/IMoonV1Manager.sol";

contract MoonV1Manager is IMoonV1Manager {
    //市场管理员
    //marketManagers
    mapping(address => bool) public marketManagers;

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
    modifier onlyMarketManager() {
        require(marketManagers[msg.sender] == true);
        _;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function setMarketManager(address _owner)
        external
        override
        onlyMarketCreator
    {
        marketManagers[_owner] = true;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function delMarketManager(address _owner)
        external
        override
        onlyMarketCreator
    {
        delete marketManagers[_owner];
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function ismarketManager() external view override returns (bool) {
        return marketManagers[msg.sender];
    }
}
