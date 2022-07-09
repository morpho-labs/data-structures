// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.0;

import "ds-test/test.sol";

import "@contracts/Heap.sol";

contract HeapStorage {
    BasicHeap.Heap internal heap;
    uint256 public TESTED_SIZE = 10000;
    uint256 public incrementAmount = 5;

    function setUp() public {
        for (uint256 i = 0; i < TESTED_SIZE; i++) {
            address id = address(uint160(i + 1));
            heap.accounts.push(BasicHeap.Account(id, TESTED_SIZE - i));
            heap.ranks[id] = heap.accounts.length;
        }
    }

    function insert(address _id, uint256 _value) public {
        BasicHeap.insert(heap, _id, _value);
    }

    function decrease(address _id, uint256 _newValue) public {
        BasicHeap.decrease(heap, _id, _newValue);
    }

    function increase(address _id, uint256 _newValue) public {
        BasicHeap.increase(heap, _id, _newValue);
    }

    function remove(address _id) public {
        BasicHeap.remove(heap, _id);
    }
}

contract TestStressHeap is DSTest {
    HeapStorage public hs = new HeapStorage();
    uint256 public ts;
    uint256 public im;

    function setUp() public {
        hs.setUp();
        ts = hs.TESTED_SIZE();
        im = hs.incrementAmount();
    }

    function testInsertOneTop() public {
        hs.insert(address(this), ts + 1);
    }

    function testInsertOneMiddle() public {
        hs.insert(address(this), ts / 2);
    }

    function testInsertOneBottom() public {
        hs.insert(address(this), 1);
    }

    function testRemoveOneTop() public {
        hs.remove(address(uint160(1)));
    }

    function testRemoveOneMiddle() public {
        uint256 middle = ts / 2;
        hs.remove(address(uint160(middle + 1)));
    }

    function testRemoveOneBottom() public {
        uint256 end = ts - 2 * im;
        hs.remove(address(uint160(end + 1)));
    }

    function testIncreaseOneTop() public {
        hs.increase(address(uint160(1)), ts + im);
    }

    function testIncreaseOneMiddle() public {
        uint256 middle = ts / 2;
        hs.increase(address(uint160(middle + 1)), ts - middle + im);
    }

    function testIncreaseOneBottom() public {
        uint256 end = ts - 2 * im;
        hs.increase(address(uint160(end + 1)), ts - end + im);
    }

    function testDecreaseOneTop() public {
        hs.decrease(address(uint160(1)), 1);
    }

    function testDecreaseOneMiddle() public {
        uint256 middle = ts / 2;
        hs.decrease(address(uint160(middle + 1)), 1);
    }

    function testDecreaseOneBottom() public {
        uint256 end = ts - 2 * im;
        hs.decrease(address(uint160(end + 1)), ts - end - im);
    }
}
