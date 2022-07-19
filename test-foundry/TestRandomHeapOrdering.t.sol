// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.13;

import "./helpers/TestRandomHeap.sol";
import "./helpers/ConcreteHeapOrdering.sol";

contract TestRandomHeapOrdering is TestRandomHeap {
    constructor() {
        heap = new ConcreteHeapOrdering();
    }

    function verify2HeapStructure(uint256 size) internal view {
        uint256 firstChildRank;
        uint256 secondChildRank;
        uint256 initialValue;
        uint256 firstChildValue;
        uint256 secondChildValue;
        for (uint256 rank = 1; rank <= size / 2; rank++) {
            initialValue = heap.accountsValue(rank - 1);
            firstChildRank = 2 * rank;
            secondChildRank = 2 * rank + 1;
            if (firstChildRank <= size) {
                firstChildValue = heap.accountsValue(firstChildRank - 1);
                require(initialValue >= firstChildRank, "not heap");
            }
            if (secondChildRank <= size) {
                secondChildValue = heap.accountsValue(secondChildRank - 1);
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
