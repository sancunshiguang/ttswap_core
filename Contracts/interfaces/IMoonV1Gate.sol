// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.7;

interface IMoonV1Gate {
    function addGoods() external returns (bool);

    function delGoods() external returns (bool);

    function addNFTGoods() external returns (bool);

    function delNFTGoods() external returns (bool);

    /// @notice register my Organization
    /// @return register the organization sucess or failure
    function register() external view returns (address);

    /// @notice register my Organization
    /// @param  organ The account for which to look up the number of tokens it has, i.e. its balance
    /// @return The number of tokens held by the account
    function addAuthority(address organ) external view returns (uint256);

    function removeAuthority(uint256 _value) external view returns (bool);

    function Authorityof(address _organ) external view returns (uint24);

    function transforAuthor(address _to, int24 _value)
        external
        view
        returns (bool);

    function transforUser(address _to, address _cus)
        external
        view
        returns (bool);

    function transforUserAll(address _to) external view returns (bool);

    /// @notice Returns the balance of a token
    /// @return The number of tokens held by the account
    function name() external view returns (bytes31);

    /// @notice Event emitted when tokens are transferred from one address to another, either via `#transfer` or `#transferFrom`.
    /// @param from The account from which the tokens were sent, i.e. the balance decreased
    /// @param to The account to which the tokens were sent, i.e. the balance increased
    /// @param value The amount of tokens that were transferred
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @notice Event emitted when the approval amount for the spender of a given owner's tokens changes.
    /// @param owner The account that approved spending of its tokens
    /// @param spender The account for which the spending allowance was modified
    /// @param value The new allowance from the owner to the spender
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
