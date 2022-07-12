// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.0;
import "ds-test/test.sol";
import "forge-std/console.sol";
import "@contracts/HeapOrdering.sol";

contract Random {
    uint256 private seed = 0;

    function randomBytes32() internal returns (bytes32) {
        return keccak256(abi.encodePacked(seed++));
    }

    function randomUint256(uint256 range) public returns (uint256) {
        return 1 + (uint256(randomBytes32()) % range);
    }

    function randomAddress(uint256 range) public returns (address) {
        return address(uint160((uint256(randomBytes32()) % range) + 1));
    }

    function randomAddress() public returns (address) {
        return randomAddress(type(uint256).max);
    }
}

contract Helper is Random {
    HeapOrdering.HeapArray[] internal heaps;

    function setUp() public {
        heaps.push();
    }

    function getCurrentHeap() private view returns (HeapOrdering.HeapArray storage) {
        return heaps[heaps.length - 1];
    }

    function clearHeap() public {
        // the next operations will be performed on a new empty heap
        heaps.push();
    }

    function updateHeap(
        address _id,
        uint256 _newValue,
        uint256 _max_sorted_users
    ) public {
        HeapOrdering.HeapArray storage heap = getCurrentHeap();
        uint256 formerValue = HeapOrdering.getValueOf(heap, _id);
        HeapOrdering.update(heap, _id, formerValue, _newValue, _max_sorted_users);
    }

    function getSize() private view returns (uint256) {
        HeapOrdering.HeapArray storage heap = getCurrentHeap();
        return heap.size;
    }

    function checkOrdering() public view {
        // Check that for the parent value (at rank i) is always greater than the ones of his children
        // (at rank 2i, 2i + 1), for ranks <= head size
        HeapOrdering.HeapArray storage heap = getCurrentHeap();
        for (uint256 rank = 1; rank < getSize(); rank++) {
            HeapOrdering.Account memory user = heap.accounts[rank - 1];
            // child = 0 (left) or child = 1 (right)
            for (uint256 child; child <= 1; child++) {
                uint256 childRank = rank * 2 + child;
                if (childRank <= getSize()) {
                    HeapOrdering.Account memory childUser = heap.accounts[childRank - 1];
                    require(
                        user.value >= childUser.value,
                        "Error: The heap is not correctly ordered."
                    );
                }
            }
        }
    }
}

contract TestHeapRandomHeapOrdering is DSTest {
    Helper public helper = new Helper();

    function setUp() public {
        helper.setUp();
    }

    function _stressTest(uint256 n) public {
        uint256 N_USERS = n;
        uint256 RANGE_VALUES = 2 * n;
        uint256 N_ITERS = 3 * n;
        uint256 max_sorted_users = helper.randomUint256(N_USERS);
        for (uint256 iter; iter < N_ITERS; iter++) {
            address user = helper.randomAddress(N_USERS);
            uint256 newValue;
            if (helper.randomUint256(100) <= 75) {
                // 25 % chance of deletion
                newValue = helper.randomUint256(RANGE_VALUES);
            }
            if (helper.randomUint256(N_ITERS) <= 3) {
                // change max users approximately 3 times per test
                max_sorted_users = helper.randomUint256(N_USERS);
            }
            helper.updateHeap(user, newValue, max_sorted_users);
        }
        helper.checkOrdering();
        helper.clearHeap();
    }

    function testMain() public {
        for (uint256 n = 0; n <= 4; n++) {
            _stressTest(10**n);
        }
    }
}
