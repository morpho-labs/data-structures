// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.13;

import "./Random.sol";
import "./ICommonHeapOrdering.sol";
import "forge-std/Test.sol";

abstract contract TestRandomHeap is Test, Random {
    ICommonHeapOrdering public heap;

    address[] public ids;

    uint256 public n = 50000;
    uint256 public maxSortedUsers;

    function insert() public {
        address id = randomAddress();
        ids.push(id);
        heap.update(id, 0, randomUint256(type(uint96).max), maxSortedUsers);
    }

    function remove() public {
        uint256 index = randomUint256(ids.length);
        address toRemove = ids[index];

        heap.update(toRemove, heap.getValueOf(toRemove), 0, maxSortedUsers);
        ids[index] = ids[ids.length - 1];
        ids.pop();
    }

    function increase() public {
        uint256 index = randomUint256(ids.length);
        address toUpdate = ids[index];
        uint256 formerValue = heap.getValueOf(toUpdate);

        heap.update(
            ids[index],
            formerValue,
            formerValue + randomUint256(type(uint96).max - formerValue),
            maxSortedUsers
        );
    }

    function decrease() public {
        uint256 index = randomUint256(ids.length);
        address toUpdate = ids[index];
        uint256 formerValue = heap.getValueOf(toUpdate);

        heap.update(ids[index], formerValue, randomUint256(formerValue), maxSortedUsers);
    }
}
