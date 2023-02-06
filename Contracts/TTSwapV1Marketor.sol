// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./interfaces/ITTSwapV1Marketor.sol";

contract TTSwapV1Marketor is ITTSwapV1Marketor {
    //市场管理员
    //marketMarketors
    mapping(address => bool) public Marketors;

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
    function setMarketorByMarketCreator(address _owner)
        external
        override
        onlyMarketCreator
    {
        Marketors[_owner] = true;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function delMarketorByMarketCreator(address _owner)
        external
        override
        onlyMarketCreator
    {
        delete Marketors[_owner];
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function isValidMarketor() external view override returns (bool) {
        return Marketors[msg.sender];
    }
}
