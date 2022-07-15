// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.0;

interface ICommonHeapOrdering {
    function accountsValue(uint256 _index) external returns (uint256);

    function indexes(address _id) external returns (uint256);

    function update(
        address _id,
        uint256 _formerValue,
        uint256 _newValue,
        uint256 _maxSortedUsers
    ) external;

    function length() external returns (uint256);

    function size() external returns (uint256);

    function getValueOf(address) external returns (uint256);

    function getHead() external returns (address);

    function getTail() external returns (address);

    function getPrev(address) external returns (address);

    function getNext(address) external returns (address);
}
