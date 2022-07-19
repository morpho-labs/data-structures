// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";

import "@contracts/HeapOrdering.sol";
import "./ICommonHeapOrdering.sol";

abstract contract CommonHeapOrdering is Test {
    ICommonHeapOrdering internal heap;

    Vm public hevm = Vm(HEVM_ADDRESS);

    address[] public accounts;
    uint256 public NB_ACCOUNTS = 50;
    uint256 public MAX_SORTED_USERS = 50;
    address public ADDR_ZERO = address(0);

    function update(
        address _id,
        uint256 _formerValue,
        uint256 _newValue
    ) public {
        heap.update(_id, _formerValue, _newValue, MAX_SORTED_USERS);
    }

    function setUp() public {
        accounts = new address[](NB_ACCOUNTS);
        accounts[0] = address(this);
        for (uint256 i = 1; i < NB_ACCOUNTS; i++) {
            accounts[i] = address(uint160(accounts[i - 1]) + 1);
        }
    }

    function testEmpty() public {
        assertEq(heap.size(), 0);
        assertEq(heap.length(), 0);
        assertEq(heap.getValueOf(accounts[0]), 0);
        assertEq(heap.getHead(), ADDR_ZERO);
        assertEq(heap.getTail(), ADDR_ZERO);
        assertEq(heap.getPrev(accounts[0]), ADDR_ZERO);
        assertEq(heap.getNext(accounts[0]), ADDR_ZERO);
    }

    function testInsertOneSingleAccount() public {
        update(accounts[0], 0, 1);

        assertEq(heap.size(), 1);
        assertEq(heap.length(), 1);
        assertEq(heap.getValueOf(accounts[0]), 1);
        assertEq(heap.getHead(), accounts[0]);
        assertEq(heap.getTail(), accounts[0]);
        assertEq(heap.getPrev(accounts[0]), ADDR_ZERO);
        assertEq(heap.getNext(accounts[0]), ADDR_ZERO);

        assertEq(heap.getValueOf(accounts[1]), 0);
    }

    function testShouldNotInsertAccountWithZeroValue() public {
        update(accounts[0], 0, 0);
        assertEq(heap.size(), 0);
        assertEq(heap.length(), 0);
    }

    function testShouldNotInsertZeroAddress() public {
        hevm.expectRevert(abi.encodeWithSignature("AddressIsZero()"));
        update(address(0), 0, 10);
    }

    function testShouldInsertSeveralTimesTheSameAccount() public {
        update(accounts[0], 0, 1);
        update(accounts[0], 1, 2);
        assertEq(heap.size(), 1);
        assertEq(heap.length(), 1);
        assertEq(heap.getValueOf(accounts[0]), 2);
        assertEq(heap.getHead(), accounts[0]);
        assertEq(heap.getTail(), accounts[0]);
        assertEq(heap.getPrev(accounts[0]), ADDR_ZERO);
        assertEq(heap.getNext(accounts[0]), ADDR_ZERO);
    }

    function testShouldHaveTheRightOrder() public {
        update(accounts[0], 0, 20);
        update(accounts[1], 0, 40);
        assertEq(heap.size(), 2);
        assertEq(heap.length(), 2);
        assertEq(heap.getHead(), accounts[1]);
        assertEq(heap.getTail(), accounts[0]);
        assertEq(heap.getPrev(accounts[0]), accounts[1]);
        assertEq(heap.getNext(accounts[1]), accounts[0]);
    }

    function testShouldRemoveOneSingleAccount() public {
        update(accounts[0], 0, 1);
        update(accounts[0], 1, 0);

        assertEq(heap.size(), 0);
        assertEq(heap.length(), 0);
        assertEq(heap.getHead(), ADDR_ZERO);
        assertEq(heap.getTail(), ADDR_ZERO);
        assertEq(heap.getValueOf(accounts[0]), 0);
        assertEq(heap.getPrev(accounts[0]), ADDR_ZERO);
        assertEq(heap.getNext(accounts[0]), ADDR_ZERO);
    }

    function testShouldInsertTwoAccounts() public {
        update(accounts[0], 0, 2);
        update(accounts[1], 0, 1);

        assertEq(heap.size(), 2);
        assertEq(heap.length(), 2);
        assertEq(heap.getHead(), accounts[0]);
        assertEq(heap.getTail(), accounts[1]);
        assertEq(heap.getValueOf(accounts[0]), 2);
        assertEq(heap.getValueOf(accounts[1]), 1);
        assertEq(heap.getPrev(accounts[0]), ADDR_ZERO);
        assertEq(heap.getNext(accounts[0]), accounts[1]);
        assertEq(heap.getPrev(accounts[1]), accounts[0]);
        assertEq(heap.getNext(accounts[1]), ADDR_ZERO);

        assertEq(heap.getNext(accounts[2]), ADDR_ZERO);
        assertEq(heap.getPrev(accounts[2]), ADDR_ZERO);
    }

    function testShouldInsertThreeAccounts() public {
        update(accounts[0], 0, 3);
        update(accounts[1], 0, 2);
        update(accounts[2], 0, 1);

        assertEq(heap.getHead(), accounts[0]);
        assertEq(heap.getTail(), accounts[2]);
        assertEq(heap.getValueOf(accounts[0]), 3);
        assertEq(heap.getValueOf(accounts[1]), 2);
        assertEq(heap.getValueOf(accounts[2]), 1);
        assertEq(heap.getPrev(accounts[0]), ADDR_ZERO);
        assertEq(heap.getNext(accounts[0]), accounts[1]);
        assertEq(heap.getPrev(accounts[1]), accounts[0]);
        assertEq(heap.getNext(accounts[1]), accounts[2]);
        assertEq(heap.getPrev(accounts[2]), accounts[1]);
        assertEq(heap.getNext(accounts[2]), ADDR_ZERO);
    }

    function testShouldRemoveOneAccountOverTwo() public {
        update(accounts[0], 0, 2);
        update(accounts[1], 0, 1);
        update(accounts[0], 2, 0);

        assertEq(heap.size(), 1);
        assertEq(heap.length(), 1);
        assertEq(heap.getHead(), accounts[1]);
        assertEq(heap.getTail(), accounts[1]);
        assertEq(heap.getValueOf(accounts[0]), 0);
        assertEq(heap.getValueOf(accounts[1]), 1);
        assertEq(heap.getPrev(accounts[1]), ADDR_ZERO);
        assertEq(heap.getNext(accounts[1]), ADDR_ZERO);
    }

    function testShouldRemoveBothAccounts() public {
        update(accounts[0], 0, 2);
        update(accounts[1], 0, 1);
        update(accounts[0], 2, 0);
        update(accounts[1], 1, 0);

        assertEq(heap.size(), 0);
        assertEq(heap.length(), 0);
        assertEq(heap.getHead(), ADDR_ZERO);
        assertEq(heap.getTail(), ADDR_ZERO);
    }

    function testShouldInsertThreeAccountsAndRemoveThem() public {
        update(accounts[0], 0, 3);
        update(accounts[1], 0, 2);
        update(accounts[2], 0, 1);

        assertEq(heap.getHead(), accounts[0]);
        assertEq(heap.getTail(), accounts[2]);

        // Remove account 0.
        update(accounts[0], 3, 0);
        assertEq(heap.getHead(), accounts[1]);
        assertEq(heap.getTail(), accounts[2]);
        assertEq(heap.getPrev(accounts[1]), ADDR_ZERO);
        assertEq(heap.getNext(accounts[1]), accounts[2]);

        assertEq(heap.getPrev(accounts[2]), accounts[1]);
        assertEq(heap.getNext(accounts[2]), ADDR_ZERO);

        // Remove account 1.
        update(accounts[1], 2, 0);
        assertEq(heap.getHead(), accounts[2]);
        assertEq(heap.getTail(), accounts[2]);
        assertEq(heap.getPrev(accounts[2]), ADDR_ZERO);
        assertEq(heap.getNext(accounts[2]), ADDR_ZERO);

        // Remove account 2.
        update(accounts[2], 1, 0);
        assertEq(heap.getHead(), ADDR_ZERO);
        assertEq(heap.getTail(), ADDR_ZERO);
    }

    function testShouldRemoveAllSortedAccount() public {
        for (uint256 i = 0; i < accounts.length; i++) {
            update(accounts[i], 0, NB_ACCOUNTS - i);
        }

        for (uint256 i = 0; i < accounts.length; i++) {
            update(accounts[i], NB_ACCOUNTS - i, 0);
        }

        assertEq(heap.getHead(), ADDR_ZERO);
        assertEq(heap.getTail(), ADDR_ZERO);
    }

    function testShouldInsertAccountSortedAtTheBeginningUntilNDS() public {
        uint256 value = 50;

        // Add first 10 accounts with decreasing value.
        for (uint256 i = 0; i < 10; i++) {
            update(accounts[i], 0, value - i);
        }

        assertEq(heap.getHead(), accounts[0]);
        assertEq(heap.getTail(), accounts[9]);

        address nextAccount = accounts[0];
        for (uint256 i = 0; i < 9; i++) {
            nextAccount = heap.getNext(nextAccount);
            assertEq(nextAccount, accounts[i + 1]);
        }

        address prevAccount = accounts[9];
        for (uint256 i = 0; i < 9; i++) {
            prevAccount = heap.getPrev(prevAccount);
            assertEq(prevAccount, accounts[10 - i - 2]);
        }

        // Add last 10 accounts at the same value.
        for (uint256 i = NB_ACCOUNTS - 10; i < NB_ACCOUNTS; i++) {
            update(accounts[i], 0, 10);
        }

        assertEq(heap.getHead(), accounts[0]);
        assertEq(heap.getTail(), accounts[accounts.length - 1]);

        nextAccount = accounts[0];
        for (uint256 i = 0; i < 9; i++) {
            nextAccount = heap.getNext(nextAccount);
            assertEq(nextAccount, accounts[i + 1]);
        }

        prevAccount = accounts[9];
        for (uint256 i = 0; i < 9; i++) {
            prevAccount = heap.getPrev(prevAccount);
            assertEq(prevAccount, accounts[10 - i - 2]);
        }
    }

    function testRemoveLast() public {
        update(accounts[0], 0, 4);
        update(accounts[1], 0, 2);
        update(accounts[2], 0, 3);

        uint256 sizeBefore = heap.size();

        update(accounts[2], 3, 0);

        uint256 sizeAfter = heap.size();

        assertLt(sizeAfter, sizeBefore);
        assertEq(heap.length(), 2);
    }

    function testShouldInsertAccountsAllSorted() public {
        for (uint256 i = 0; i < accounts.length; i++) {
            update(accounts[i], 0, NB_ACCOUNTS - i);
        }

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

    function testDecreaseRankChanges() public {
        for (uint256 i = 0; i < 16; i++) update(accounts[i], 0, 20 - i);

        uint256 index0Before = heap.indexes(accounts[0]);

        update(accounts[0], 20, 2);

        uint256 index0After = heap.indexes(accounts[0]);

        assertGt(index0After, index0Before);
    }

    function testIncreaseRankChanges() public {
        for (uint256 i = 0; i < 20; i++) update(accounts[i], 0, 20 - i);

        uint256 index17Before = heap.indexes(accounts[17]);

        update(accounts[17], 20 - 17, 21);

        uint256 index17After = heap.indexes(accounts[17]);

        assertLt(index17After, index17Before);
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
}
