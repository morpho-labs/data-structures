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
        uint256 rdm = randomUint256(type(uint96).max);
        if (rdm == 0) revert("Random gave back 0.");

        heap.update(id, 0, rdm, maxSortedUsers);
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

        uint256 rdm = formerValue + randomUint256(type(uint96).max - formerValue);
        if (rdm == 0) revert("Random gave back 0.");

        heap.update(ids[index], formerValue, rdm, maxSortedUsers);
    }

    function decrease() public {
        uint256 index = randomUint256(ids.length);
        address toUpdate = ids[index];
        uint256 formerValue = heap.getValueOf(toUpdate);

        uint256 rdm = randomUint256(formerValue);
        if (rdm == 0) revert("Random gave back 0.");

        heap.update(ids[index], formerValue, rdm, maxSortedUsers);
    }

    function removeHead() public returns (uint256 value) {
        address head = heap.getHead();
        if (head == address(0)) return 0;
        else {
            value = heap.getValueOf(head);
            heap.update(head, value, 0, maxSortedUsers);
        }
    }

    // Should give elements in decreasing order if maxSortedUsers is +infinity.
    function testFullHeapSort() public {
        maxSortedUsers = n;
        for (uint256 i; i < n; i++) {
            if (ids.length == 0) insert();
            else {
                uint256 r = randomUint256(5);
                if (r < 2) insert();
                else if (r == 2) remove();
                else if (r == 3) increase();
                else decrease();
            }
        }

        uint256 lastValue = type(uint256).max;
        uint256 newValue;
        while ((newValue = removeHead()) != 0) {
            require(newValue <= lastValue, "Elements are not given back in a decreasing order.");
            lastValue = newValue;
        }
    }
}
