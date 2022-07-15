// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.0;

import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";

import "@contracts/HeapOrdering.sol";
import "./helpers/CommonHeapOrdering.sol";
import "./helpers/ICommonHeapOrdering.sol";

contract ConcreteHeapOrdering is ICommonHeapOrdering {
    using HeapOrdering for HeapOrdering.HeapArray;

    HeapOrdering.HeapArray internal heap;

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

        MAX_SORTED_USERS = 2;

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

    function testSouldInsertSorted() public {
        update(accounts[0], 0, 1);
        update(accounts[1], 0, 2);
        update(accounts[2], 0, 3);
        update(accounts[3], 0, 4);
        update(accounts[4], 0, 5);
        update(accounts[5], 0, 6);
        update(accounts[6], 0, 7);

        assertEq(heap.accountsValue(0), 7);
        assertEq(heap.accountsValue(1), 4);
        assertEq(heap.accountsValue(2), 6);
        assertEq(heap.accountsValue(3), 1);
        assertEq(heap.accountsValue(4), 3);
        assertEq(heap.accountsValue(5), 2);
        assertEq(heap.accountsValue(6), 5);
    }

    function testShouldInsertAccountsAllSorted() public {
        for (uint256 i = 0; i < accounts.length; i++) {
            update(accounts[i], 0, NB_ACCOUNTS - i);
        }

        assertEq(heap.size(), NB_ACCOUNTS / 2);
        assertEq(heap.length(), NB_ACCOUNTS);
        assertEq(heap.getHead(), accounts[0]);
        assertEq(heap.getTail(), accounts[accounts.length - 1]);

        address nextAccount = accounts[0];
        for (uint256 i = 0; i < accounts.length - 1; i++) {
            nextAccount = heap.getNext(nextAccount);
            assertEq(nextAccount, accounts[i + 1]);
        }

        address prevAccount = accounts[accounts.length - 1];
        for (uint256 i = 0; i < accounts.length - 1; i++) {
            prevAccount = heap.getPrev(prevAccount);
            assertEq(prevAccount, accounts[accounts.length - i - 2]);
        }
    }

    function testInsertLast() public {
        for (uint256 i; i < 10; i++) update(accounts[i], 0, NB_ACCOUNTS - i);

        for (uint256 i = 10; i < 15; i++) update(accounts[i], 0, i - 9);

        for (uint256 i = 10; i < 15; i++) assertLe(heap.accountsValue(i), 10);
    }

    function testInsertWrap() public {
        MAX_SORTED_USERS = 20;
        for (uint256 i = 0; i < 20; i++) update(accounts[i], 0, NB_ACCOUNTS - i);

        update(accounts[20], 0, 1);

        assertEq(heap.accountsValue(10), 1);
    }

    function testDecreaseRankChanges() public {
        MAX_SORTED_USERS = 4;
        for (uint256 i = 0; i < 16; i++) update(accounts[i], 0, 20 - i);

        uint256 index5Before = heap.indexes(accounts[5]);
        uint256 index0Before = heap.indexes(accounts[0]);

        update(accounts[5], 15, 1);

        uint256 index5After = heap.indexes(accounts[5]);

        assertEq(index5Before, index5After);

        update(accounts[0], 20, 2);

        uint256 index0After = heap.indexes(accounts[0]);

        assertGt(index0After, index0Before);
    }

    function testIncreaseRankChange() public {
        for (uint256 i = 0; i < 20; i++) update(accounts[i], 0, 20 - i);

        MAX_SORTED_USERS = 10;

        update(accounts[17], 20 - 17, 5);

        uint256 index17After = heap.indexes(accounts[17]);

        assertEq(index17After, 5);
    }

    function testIncreaseRankChangeShiftUp() public {
        for (uint256 i = 0; i < 20; i++) update(accounts[i], 0, 20 - i);

        MAX_SORTED_USERS = 10;

        update(accounts[17], 20 - 17, 40);

        uint256 index17After = heap.indexes(accounts[17]);

        assertEq(index17After, 0);
    }

    function testRemoveShiftDown() public {
        for (uint256 i = 0; i < 20; i++) update(accounts[i], 0, NB_ACCOUNTS - i);

        update(accounts[5], NB_ACCOUNTS - 5, 0);

        assertEq(heap.accountsValue(5), NB_ACCOUNTS - 2 * (5 + 1) + 1);
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

        update(accounts[3], 10, 0);

        assertEq(heap.accountsValue(1), 25);
    }

    function testInsertNoSwap() public {
        update(accounts[0], 0, 40);
        update(accounts[1], 0, 30);
        update(accounts[2], 0, 20);

        // Insert does a swap with the same index.
        update(accounts[3], 0, 10);
        assertEq(heap.indexes(accounts[0]), 0);
        assertEq(heap.indexes(accounts[1]), 1);
        assertEq(heap.indexes(accounts[2]), 2);
        assertEq(heap.indexes(accounts[3]), 3);
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
