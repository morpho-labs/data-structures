// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.0;

interface ICommonHeapOrdering {
    function update(
        address _id,
        uint256 _formerValue,
        uint256 _newValue,
        uint256 _maxSortedUsers
    ) external;

    function accountsValue(uint256 _index) external view returns (uint256);

    function indexes(address _id) external view returns (uint256);

    function length() external view returns (uint256);

    function size() external view returns (uint256);

    function getValueOf(address) external view returns (uint256);

    function getHead() external view returns (address);

    function getTail() external view returns (address);

    function getPrev(address) external view returns (address);

    function getNext(address) external view returns (address);

    function verifyStructure() external view;
}
