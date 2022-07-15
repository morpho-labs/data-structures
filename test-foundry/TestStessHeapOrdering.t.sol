// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.0;

import "ds-test/test.sol";

import "@contracts/HeapOrdering.sol";

contract HeapStorage {
    HeapOrdering.HeapArray internal heap;
    uint256 public TESTED_SIZE = 10000;
    uint256 public MAX_SORTED_USERS = TESTED_SIZE;
    uint256 public incrementAmount = 5;

    function setUp() public {
        for (uint256 i = 0; i < TESTED_SIZE; i++) {
            address id = address(uint160(i + 1));
            heap.indexes[id] = heap.accounts.length;
            heap.accounts.push(HeapOrdering.Account(id, uint96(TESTED_SIZE - i)));
            heap.size = MAX_SORTED_USERS;
        }
    }

    function update(
        address _id,
        uint256 _formerValue,
        uint256 _newValue
    ) public {
        HeapOrdering.update(heap, _id, _formerValue, _newValue, MAX_SORTED_USERS);
    }
}

contract TestStressHeapOrdering is DSTest {
    HeapStorage public hs = new HeapStorage();
    uint256 public ts;
    uint256 public im;

    function setUp() public {
        hs.setUp();
        ts = hs.TESTED_SIZE();
        im = hs.incrementAmount();
    }

    function testInsertOneTop() public {
        hs.update(address(this), 0, ts + 1);
    }

    function testInsertOneMiddle() public {
        hs.update(address(this), 0, ts / 2);
    }

    function testInsertOneBottom() public {
        hs.update(address(this), 0, 1);
    }

    function testRemoveOneTop() public {
        hs.update(address(uint160(1)), ts, 0);
    }

    function testRemoveOneMiddle() public {
        uint256 middle = ts / 2;
        hs.update(address(uint160(middle + 1)), ts - middle, 0);
    }

    function testRemoveOneBottom() public {
        uint256 end = ts - 2 * im;
        hs.update(address(uint160(end + 1)), ts - end, 0);
    }

    function testIncreaseOneTop() public {
        hs.update(address(uint160(1)), ts, ts + im);
    }

    function testIncreaseOneMiddle() public {
        uint256 middle = ts / 2;
        hs.update(address(uint160(middle + 1)), ts - middle, ts - middle + im);
    }

    function testIncreaseOneBottom() public {
        uint256 end = ts - 2 * im;
        hs.update(address(uint160(end + 1)), ts - end, ts - end + im);
    }

    function testDecreaseOneTop() public {
        hs.update(address(uint160(1)), ts, 1);
    }

    function testDecreaseOneMiddle() public {
        uint256 middle = ts / 2;
        hs.update(address(uint160(middle + 1)), ts - middle, 1);
    }

    function testDecreaseOneBottom() public {
        uint256 end = ts - 2 * im;
        hs.update(address(uint160(end + 1)), ts - end, ts - end - im);
    }
}
