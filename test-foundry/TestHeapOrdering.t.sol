// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.0;

import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";

import "./helpers/CommonHeapOrdering.sol";
import "./helpers/ConcreteHeapOrdering.sol";

contract TestHeapOrdering is CommonHeapOrdering {
    constructor() {
        heap = new ConcreteHeapOrdering();
    }

    function testComputeSizeSmall() public {
        update(accounts[0], 0, 10);
        update(accounts[1], 0, 20);
        update(accounts[2], 0, 30);
        update(accounts[3], 0, 40);
        update(accounts[4], 0, 50);
        update(accounts[5], 0, 60);

        MAX_SORTED_USERS = 3;

        update(accounts[5], 60, 25);
        assertEq(heap.size(), 1);
    }

    function testComputeSizeBig() public {
        MAX_SORTED_USERS = 30;

        for (uint256 i = 0; i < NB_ACCOUNTS; i++) {
            update(accounts[i], 0, i + 1);
        }
        // Test that the size has been increased to MAX_SORTED_USERS/2 and increased again.
        assertEq(heap.size(), 20);
    }

    function testShiftUpLeft() public {
        update(accounts[0], 0, 4);
        update(accounts[1], 0, 3);
        update(accounts[2], 0, 2);

        assertEq(heap.accountsValue(0), 4);
        assertEq(heap.accountsValue(1), 3);
        assertEq(heap.accountsValue(2), 2);

        update(accounts[2], 2, 10);

        assertEq(heap.accountsValue(0), 10);
        assertEq(heap.accountsValue(1), 3);
        assertEq(heap.accountsValue(2), 4);
    }

    function testShiftUpRight() public {
        update(accounts[0], 0, 4);
        update(accounts[1], 0, 3);
        update(accounts[2], 0, 2);

        update(accounts[1], 3, 10);

        assertEq(heap.accountsValue(0), 10);
        assertEq(heap.accountsValue(1), 4);
        assertEq(heap.accountsValue(2), 2);
    }

    function testShiftUpBig() public {
        update(accounts[0], 0, 20);
        update(accounts[1], 0, 15);
        update(accounts[2], 0, 18);
        update(accounts[3], 0, 11);
        update(accounts[4], 0, 12);
        update(accounts[5], 0, 17);
        update(accounts[6], 0, 16);

        assertEq(heap.accountsValue(0), 20);
        assertEq(heap.accountsValue(1), 15);
        assertEq(heap.accountsValue(2), 18);
        assertEq(heap.accountsValue(3), 11);
        assertEq(heap.accountsValue(4), 12);
        assertEq(heap.accountsValue(5), 17);
        assertEq(heap.accountsValue(6), 16);

        update(accounts[4], 12, 30);

        assertEq(heap.accountsValue(4), 15);
        assertEq(heap.accountsValue(1), 20);
        assertEq(heap.accountsValue(0), 30);
    }

    function testShiftDownRight() public {
        update(accounts[0], 0, 4);
        update(accounts[1], 0, 3);
        update(accounts[2], 0, 2);

        update(accounts[0], 4, 1);

        assertEq(heap.accountsValue(0), 3);
        assertEq(heap.accountsValue(1), 1);
        assertEq(heap.accountsValue(2), 2);
    }

    function testShiftDownLeft() public {
        update(accounts[0], 0, 4);
        update(accounts[1], 0, 2);
        update(accounts[2], 0, 3);

        update(accounts[0], 4, 1);

        assertEq(heap.accountsValue(0), 3);
        assertEq(heap.accountsValue(1), 2);
        assertEq(heap.accountsValue(2), 1);
    }

    function testShiftDownBig() public {
        update(accounts[0], 0, 20);
        update(accounts[1], 0, 15);
        update(accounts[2], 0, 18);
        update(accounts[3], 0, 11);
        update(accounts[4], 0, 12);
        update(accounts[5], 0, 17);
        update(accounts[6], 0, 16);

        update(accounts[0], 20, 10);

        assertEq(heap.accountsValue(0), 18);
        assertEq(heap.accountsValue(2), 17);
        assertEq(heap.accountsValue(5), 10);
    }

    function testInsertWrap() public {
        MAX_SORTED_USERS = 20;
        for (uint256 i = 0; i < 20; i++) update(accounts[i], 0, NB_ACCOUNTS - i);

        update(accounts[20], 0, 1);

        assertEq(heap.accountsValue(10), 1);
    }

    function testRemoveShiftDown() public {
        update(accounts[0], 0, 40);
        update(accounts[1], 0, 10);
        update(accounts[2], 0, 30);
        update(accounts[3], 0, 8);
        update(accounts[4], 0, 7);
        update(accounts[5], 0, 2);

        assertEq(heap.accountsValue(0), 40);
        assertEq(heap.accountsValue(1), 10);
        assertEq(heap.accountsValue(2), 30);
        assertEq(heap.accountsValue(3), 8);
        assertEq(heap.accountsValue(4), 7);
        assertEq(heap.accountsValue(5), 2);

        update(accounts[1], 10, 0);

        assertEq(heap.accountsValue(0), 40);
        assertEq(heap.accountsValue(1), 8);
        assertEq(heap.accountsValue(2), 30);
        assertEq(heap.accountsValue(3), 2);
        assertEq(heap.accountsValue(4), 7);
    }

    function testRemoveShiftUp() public {
        update(accounts[0], 0, 40);
        update(accounts[1], 0, 10);
        update(accounts[2], 0, 30);
        update(accounts[3], 0, 8);
        update(accounts[4], 0, 7);
        update(accounts[5], 0, 25);

        assertEq(heap.accountsValue(0), 40);
        assertEq(heap.accountsValue(1), 10);
        assertEq(heap.accountsValue(2), 30);
        assertEq(heap.accountsValue(3), 8);
        assertEq(heap.accountsValue(4), 7);
        assertEq(heap.accountsValue(5), 25);

        update(accounts[3], 8, 0);

        assertEq(heap.accountsValue(0), 40);
        assertEq(heap.accountsValue(1), 25);
        assertEq(heap.accountsValue(2), 30);
        assertEq(heap.accountsValue(3), 10);
        assertEq(heap.accountsValue(4), 7);
    }

    function testIncreaseAndRemoveNoSwap() public {
        MAX_SORTED_USERS = 4;
        update(accounts[0], 0, 60);
        update(accounts[1], 0, 50);
        update(accounts[2], 0, 40);
        update(accounts[3], 0, 30);

        // Increase does a swap with the same index.
        update(accounts[2], 40, 45);
        assertEq(heap.indexes(accounts[0]), 0);
        assertEq(heap.indexes(accounts[1]), 1);
        assertEq(heap.indexes(accounts[2]), 2);
        assertEq(heap.indexes(accounts[3]), 3);

        // Remove does a swap with the same index.
        update(accounts[3], 30, 0);
        assertEq(heap.indexes(accounts[0]), 0);
        assertEq(heap.indexes(accounts[1]), 1);
        assertEq(heap.indexes(accounts[2]), 2);
    }

    function testOverflowNewValue() public {
        hevm.expectRevert("SafeCast: value doesn't fit in 96 bits");
        update(accounts[0], 0, uint256(type(uint128).max));
    }

    function testOverflowFormerValue() public {
        hevm.expectRevert("SafeCast: value doesn't fit in 96 bits");
        update(accounts[0], uint256(type(uint128).max), 0);
    }
}
