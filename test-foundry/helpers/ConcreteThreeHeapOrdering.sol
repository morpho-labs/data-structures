// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.0;

import "@contracts/ThreeHeapOrdering.sol";
import "./ICommonHeapOrdering.sol";

contract ConcreteThreeHeapOrdering is ICommonHeapOrdering {
    using ThreeHeapOrdering for ThreeHeapOrdering.HeapArray;

    ThreeHeapOrdering.HeapArray internal heap;

    function accountsValue(uint256 _index) external view returns (uint256) {
        return heap.accounts[_index].value;
    }

    function indexes(address _id) external view returns (uint256) {
        return heap.indexes[_id];
    }

    function update(
        address _id,
        uint256 _formerValue,
        uint256 _newValue,
        uint256 _maxSortedUsers
    ) external {
        heap.update(_id, _formerValue, _newValue, _maxSortedUsers);
    }

    function length() external view returns (uint256) {
        return heap.length();
    }

    function size() external view returns (uint256) {
        return heap.size;
    }

    function getValueOf(address _id) external view returns (uint256) {
        return heap.getValueOf(_id);
    }

    function getHead() external view returns (address) {
        return heap.getHead();
    }

    function getTail() external view returns (address) {
        return heap.getTail();
    }

    function getPrev(address _id) external view returns (address) {
        return heap.getPrev(_id);
    }

    function getNext(address _id) external view returns (address) {
        return heap.getNext(_id);
    }
}
