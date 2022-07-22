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

    function verifyStructure() external view {
        uint256 firstChildIndex;
        uint256 secondChildIndex;
        uint256 thidChildIndex;
        uint256 initialValue;
        uint256 firstChildValue;
        uint256 secondChildValue;
        uint256 thirdChildValue;

        uint256 heapSize = heap.size;

        for (uint256 index; index <= heapSize / 3; index++) {
            initialValue = heap.accounts[index].value;
            firstChildIndex = 3 * index + 1;
            secondChildIndex = 3 * index + 2;
            thidChildIndex = 3 * index + 3;
            if (firstChildIndex < heapSize) {
                firstChildValue = heap.accounts[firstChildIndex].value;
                require(initialValue >= firstChildValue, "3-heap structure is not verified.");
            }
            if (secondChildIndex < heapSize) {
                secondChildValue = heap.accounts[secondChildIndex].value;
                require(initialValue >= secondChildValue, "3-heap structure is not verified.");
            }
            if (thidChildIndex < heapSize) {
                thirdChildValue = heap.accounts[thidChildIndex].value;
                require(initialValue >= thirdChildValue, "3-heap structure is not verified.");
            }
        }
    }
}
