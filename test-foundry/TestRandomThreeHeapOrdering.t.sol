// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./helpers/TestRandomHeap.sol";
import "./helpers/ConcreteThreeHeapOrdering.sol";

contract TestRandomThreeHeapOrdering is TestRandomHeap {
    constructor() {
        heap = new ConcreteThreeHeapOrdering();
    }

    function verify3HeapStructure(uint256 size) internal view {
        uint256 firstChildIndex;
        uint256 secondChildIndex;
        uint256 thidChildIndex;
        uint256 initialValue;
        uint256 firstChildValue;
        uint256 secondChildValue;
        uint256 thirdChildValue;
        for (uint256 index; index < size / 3; index++) {
            initialValue = heap.accountsValue(index);
            firstChildIndex = 3 * index + 1;
            secondChildIndex = 3 * index + 2;
            thidChildIndex = 3 * index + 3;
            if (firstChildIndex < size) {
                firstChildValue = heap.accountsValue(firstChildIndex);
                require(initialValue >= firstChildValue, "not heap");
            }
            if (secondChildIndex < size) {
                secondChildValue = heap.accountsValue(secondChildIndex);
                require(initialValue >= secondChildValue, "not heap");
            }
            if (thidChildIndex < size) {
                thirdChildValue = heap.accountsValue(thidChildIndex);
                require(initialValue >= thirdChildValue, "not heap");
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
        require(maxSortedUsers / 3 <= size, "size too low");
        require(size < maxSortedUsers, "size too high");
        verify3HeapStructure(size);
    }
}
