// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.0;

import "ds-test/test.sol";
import "forge-std/Vm.sol";

import "@contracts/Heap.sol";

contract TestHeap is DSTest {
    using BasicHeap for BasicHeap.Heap;

    Vm public hevm = Vm(HEVM_ADDRESS);

    uint256 public TESTED_SIZE = 50;
    address[] public accounts;
    address public ADDR_ZERO = address(0);

    BasicHeap.Heap internal heap;

    function setUp() public {
        accounts = new address[](TESTED_SIZE);
        accounts[0] = address(this);
        for (uint256 i = 1; i < TESTED_SIZE; i++) {
            accounts[i] = address(uint160(accounts[i - 1]) + 1);
        }
    }

    function testInsertOneSingleAccount() public {
        heap.insert(accounts[0], 1);

        assertEq(heap.getSize(), 1);
        assertEq(heap.getValueOf(accounts[0]), 1);
        assertEq(heap.getRoot(), accounts[0]);
        assertEq(heap.getLeftChild(accounts[0]), ADDR_ZERO);
        assertEq(heap.getRightChild(accounts[0]), ADDR_ZERO);
    }

    function testShouldNotInsertAccountWithZeroValue() public {
        hevm.expectRevert(abi.encodeWithSignature("WrongValue()"));
        heap.insert(accounts[0], 0);

        assertEq(heap.getSize(), 0);
    }

    function testShouldNotInsertZeroAddress() public {
        hevm.expectRevert(abi.encodeWithSignature("AddressIsZero()"));
        heap.insert(address(0), 10);
    }

    function testShouldInsertSeveralTimesTheSameAccount() public {
        heap.insert(accounts[0], 1);
        hevm.expectRevert(abi.encodeWithSignature("AccountAlreadyInserted()"));
        heap.insert(accounts[0], 2);
    }

    function testShouldNotRemoveAccountThatDoesNotExist() public {
        hevm.expectRevert(abi.encodeWithSignature("AccountDoesNotExist()"));
        heap.remove(accounts[0]);
    }

    function testShouldHaveTheRightOrder() public {
        heap.insert(accounts[0], 20);
        heap.insert(accounts[1], 40);
        address root = heap.getRoot();
        address leftChild = heap.getLeftChild(root);
        assertEq(root, accounts[1]);
        assertEq(leftChild, accounts[0]);
    }

    function testShouldRemoveOneSingleAccount() public {
        heap.insert(accounts[0], 1);
        heap.remove(accounts[0]);

        assertEq(heap.getSize(), 0);
        assertEq(heap.getRoot(), ADDR_ZERO);
        assertEq(heap.getValueOf(accounts[0]), 0);
        assertEq(heap.getLeftChild(accounts[0]), ADDR_ZERO);
        assertEq(heap.getRightChild(accounts[0]), ADDR_ZERO);
    }

    function testShouldInsertTwoAccounts() public {
        heap.insert(accounts[0], 2);
        heap.insert(accounts[1], 1);

        address root = heap.getRoot();
        address leftChild = heap.getLeftChild(root);
        address rightChild = heap.getRightChild(root);

        assertEq(heap.getSize(), 2);
        assertEq(root, accounts[0]);
        assertEq(leftChild, accounts[1]);
        assertEq(rightChild, ADDR_ZERO);
        assertEq(heap.getParent(leftChild), root);
        assertEq(heap.getParent(rightChild), ADDR_ZERO);
        assertEq(heap.getValueOf(accounts[0]), 2);
        assertEq(heap.getValueOf(accounts[1]), 1);
    }

    function testShouldInsertThreeAccounts() public {
        heap.insert(accounts[0], 3);
        heap.insert(accounts[1], 2);
        heap.insert(accounts[2], 1);

        address root = heap.getRoot();
        address leftChild = heap.getLeftChild(root);
        address rightChild = heap.getRightChild(root);

        assertEq(heap.getSize(), 3);
        assertEq(root, accounts[0]);
        assertEq(leftChild, accounts[1]);
        assertEq(rightChild, accounts[2]);
        assertEq(heap.getParent(leftChild), root);
        assertEq(heap.getParent(rightChild), root);
        assertEq(heap.getValueOf(accounts[0]), 3);
        assertEq(heap.getValueOf(accounts[1]), 2);
        assertEq(heap.getValueOf(accounts[2]), 1);
    }

    function testShouldRemoveOneAccountOverTwo() public {
        heap.insert(accounts[0], 2);
        heap.insert(accounts[1], 1);
        heap.remove(accounts[0]);

        address root = heap.getRoot();

        assertEq(heap.getSize(), 1);
        assertEq(root, accounts[1]);
        assertEq(heap.getValueOf(accounts[0]), 0);
        assertEq(heap.getValueOf(accounts[1]), 1);
        assertEq(heap.getParent(root), ADDR_ZERO);
        assertEq(heap.getRightChild(root), ADDR_ZERO);
        assertEq(heap.getLeftChild(root), ADDR_ZERO);
    }

    function testShouldRemoveBothAccounts() public {
        heap.insert(accounts[0], 2);
        heap.insert(accounts[1], 1);
        heap.remove(accounts[0]);
        heap.remove(accounts[1]);

        assertEq(heap.getRoot(), ADDR_ZERO);
        assertEq(heap.getSize(), 0);
    }

    function testShouldInsertThreeAccountsAndRemoveThem() public {
        heap.insert(accounts[0], 3);
        heap.insert(accounts[1], 2);
        heap.insert(accounts[2], 1);

        address root = heap.getRoot();

        assertEq(heap.getSize(), 3);
        assertEq(root, accounts[0]);
        assertEq(heap.getLeftChild(root), accounts[1]);
        assertEq(heap.getRightChild(root), accounts[2]);

        // Remove account 0.
        heap.remove(accounts[0]);

        root = heap.getRoot();

        assertEq(heap.getSize(), 2);
        assertEq(root, accounts[1]);
        assertEq(heap.getLeftChild(root), accounts[2]);
        assertEq(heap.getRightChild(root), ADDR_ZERO);

        // Remove account 1.
        heap.remove(accounts[1]);

        root = heap.getRoot();

        assertEq(heap.getSize(), 1);
        assertEq(root, accounts[2]);
        assertEq(heap.getLeftChild(root), ADDR_ZERO);
        assertEq(heap.getRightChild(root), ADDR_ZERO);

        // Remove account 2.
        heap.remove(accounts[2]);

        assertEq(heap.getSize(), 0);
        assertEq(heap.getRoot(), ADDR_ZERO);
    }

    function testShouldInsertAccountsAllSorted() public {
        for (uint256 i = 0; i < accounts.length; i++) {
            heap.insert(accounts[i], TESTED_SIZE - i);
        }

        assertEq(heap.getRoot(), accounts[0]);

        for (uint256 i = 0; i < accounts.length; i++) {
            assertEq(heap.accounts[i].id, accounts[i]);
        }
    }

    function testShouldRemoveAllSortedAccount() public {
        for (uint256 i = 0; i < accounts.length; i++) {
            heap.insert(accounts[i], TESTED_SIZE - i);
        }

        for (uint256 i = 0; i < accounts.length; i++) {
            heap.remove(accounts[i]);
        }

        assertEq(heap.getSize(), 0);
        assertEq(heap.getRoot(), ADDR_ZERO);
    }

    function testShouldInsertAccountSortedAtTheBeginning() public {
        uint256 value = 50;

        // Add first 10 accounts with decreasing value.
        for (uint256 i = 0; i < 10; i++) {
            heap.insert(accounts[i], value - i);
        }

        // Add last 10 accounts at the same value.
        for (uint256 i = TESTED_SIZE - 10; i < TESTED_SIZE; i++) {
            heap.insert(accounts[i], 10);
        }

        assertEq(heap.getRoot(), accounts[0], "root not expected");

        for (uint256 i = 0; i < 10; i++) {
            assertEq(heap.accounts[i].id, accounts[i], "order not expected, 1");
        }

        for (uint256 i = 0; i < 10; i++) {
            assertEq(
                heap.accounts[10 + i].id,
                accounts[TESTED_SIZE - 10 + i],
                "order not expected, 2"
            );
        }
    }

    function testDecreaseOrder1() public {
        heap.insert(accounts[0], 4);
        heap.insert(accounts[1], 3);
        heap.insert(accounts[2], 2);
        heap.decrease(accounts[0], 1);

        assertEq(heap.accounts[0].value, 3);
        assertEq(heap.accounts[1].value, 1);
        assertEq(heap.accounts[2].value, 2);
    }

    function testDecreaseOrder2() public {
        heap.insert(accounts[0], 4);
        heap.insert(accounts[1], 2);
        heap.insert(accounts[2], 3);
        heap.decrease(accounts[0], 1);

        assertEq(heap.accounts[0].value, 3);
        assertEq(heap.accounts[1].value, 2);
        assertEq(heap.accounts[2].value, 1);
    }

    function testIncreaseOrder() public {
        heap.insert(accounts[0], 4);
        heap.insert(accounts[1], 3);
        heap.insert(accounts[2], 2);
        heap.increase(accounts[2], 5);

        assertEq(heap.accounts[0].value, 5);
        assertEq(heap.accounts[1].value, 3);
        assertEq(heap.accounts[2].value, 4);
    }

    function testRemoveShiftDown() public {
        heap.insert(accounts[0], 10);
        heap.insert(accounts[1], 9);
        heap.insert(accounts[2], 3);
        heap.insert(accounts[3], 8);
        heap.insert(accounts[4], 7);
        heap.insert(accounts[5], 2);
        heap.insert(accounts[6], 1);

        assertEq(heap.accounts[0].value, 10);
        assertEq(heap.accounts[1].value, 9);
        assertEq(heap.accounts[2].value, 3);
        assertEq(heap.accounts[3].value, 8);
        assertEq(heap.accounts[4].value, 7);
        assertEq(heap.accounts[5].value, 2);
        assertEq(heap.accounts[6].value, 1);

        heap.remove(accounts[1]);

        assertEq(heap.accounts[0].value, 10);
        assertEq(heap.accounts[1].value, 8);
        assertEq(heap.accounts[2].value, 3);
        assertEq(heap.accounts[3].value, 1);
        assertEq(heap.accounts[4].value, 7);
        assertEq(heap.accounts[5].value, 2);
    }

    function testRemoveShiftUp() public {
        heap.insert(accounts[0], 10);
        heap.insert(accounts[1], 3);
        heap.insert(accounts[2], 9);
        heap.insert(accounts[3], 2);
        heap.insert(accounts[4], 1);
        heap.insert(accounts[5], 8);
        heap.insert(accounts[6], 7);

        assertEq(heap.accounts[0].value, 10);
        assertEq(heap.accounts[1].value, 3);
        assertEq(heap.accounts[2].value, 9);
        assertEq(heap.accounts[3].value, 2);
        assertEq(heap.accounts[4].value, 1);
        assertEq(heap.accounts[5].value, 8);
        assertEq(heap.accounts[6].value, 7);

        heap.remove(accounts[4]);

        assertEq(heap.accounts[0].value, 10);
        assertEq(heap.accounts[1].value, 7);
        assertEq(heap.accounts[2].value, 9);
        assertEq(heap.accounts[3].value, 2);
        assertEq(heap.accounts[4].value, 3);
        assertEq(heap.accounts[5].value, 8);
    }
}
