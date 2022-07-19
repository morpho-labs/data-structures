// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.13;

import "./helpers/TestRandomHeap.sol";
import "./helpers/ConcreteHeapOrdering.sol";

contract TestRandomHeapOrdering is TestRandomHeap {
    constructor() {
        heap = new ConcreteHeapOrdering();
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
        heap.verifyStructure();
    }
}
