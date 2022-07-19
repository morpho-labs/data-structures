// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.13;

import "./helpers/TestRandomHeap.sol";
import "./helpers/ConcreteHeapOrdering.sol";

contract TestRandomHeapOrdering is TestRandomHeap {
    constructor() {
        heap = new ConcreteHeapOrdering();
    }

    function verify2HeapStructure(uint256 size) internal view {
        uint256 firstChildIndex;
        uint256 secondChildIndex;
        uint256 initialValue;
        uint256 firstChildValue;
        uint256 secondChildValue;
        for (uint256 index = 1; index <= size / 2; index++) {
            initialValue = heap.accountsValue(index - 1);
            firstChildIndex = 2 * index;
            secondChildIndex = 2 * index + 1;
            if (firstChildIndex <= size) {
                firstChildValue = heap.accountsValue(firstChildIndex - 1);
                require(initialValue >= firstChildValue, "not heap");
            }
            if (secondChildIndex <= size) {
                secondChildValue = heap.accountsValue(secondChildIndex - 1);
                require(initialValue >= secondChildValue, "not heap");
            }
        }
    }

    function testHeapStructure() public {
        maxSortedUsers = 1000;
        for (uint256 i; i < n; ) {
            if (ids.length == 0) insert();
            else {
                uint256 r = randomUint256(5);
                if (r < 2) insert();
                else if (r == 2) remove();
                else if (r == 3) increase();
                else decrease();
            }
            unchecked {
                ++i;
            }
        }

        uint256 size = heap.size();
        require(maxSortedUsers / 2 <= size, "size too low");
        require(size < maxSortedUsers, "size too high");
        verify2HeapStructure(size);
    }
}
