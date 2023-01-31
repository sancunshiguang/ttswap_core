// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../libraries/base/LCoin.sol";
import "../../libraries/base/LSTThings.sol";
import "../../libraries/base/LGate.sol";
import "../../libraries/base/LCustomer.sol";

/// @title Pool state that can change
/// @notice These methods compose the pool's state, and can change with any frequency including multiple times
/// per transaction
interface IMoonV1MarketState {
    function ismarketManager() external view returns (bool);

    function getCustomerRecommander(address _customer)
        external
        view
        returns (address);

    function getCoinInfo(address _contractaddress)
        external
        view
        returns (LCoin.Info memory);

    function getSTThingsInfo(address _contractaddress)
        external
        view
        returns (LSTThings.Info memory);

    function addGater(LGate.Info memory _gater) external;

    function getCustomer(address _CustomerAddress)
        external
        view
        returns (LCustomer.Info memory);
}
