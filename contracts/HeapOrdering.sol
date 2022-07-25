// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeCast.sol";

library HeapOrdering {
    struct Account {
        address id; // The address of the account.
        uint96 value; // The value of the account.
    }

    struct HeapArray {
        Account[] accounts; // All the accounts.
        uint256 size; // The size of the heap portion of the structure, should be less than accounts length, the rest is an unordered array.
        mapping(address => uint256) ranks; // A mapping from an address to a rank in accounts. Beware: ranks are shifted by one compared to indexes, so the first rank is 1 and not 0.
    }

    /// CONSTANTS ///

    uint256 private constant ROOT = 1;

    /// ERRORS ///

    /// @notice Thrown when the address is zero at insertion.
    error AddressIsZero();

    /// INTERNAL ///

    /// @notice Updates an account in the `_heap`.
    /// @dev Only call this function when `_id` is in the `_heap` with value `_formerValue` or when `_id` is not in the `_heap` with `_formerValue` equal to 0.
    /// @param _heap The heap to modify.
    /// @param _id The address of the account to update.
    /// @param _formerValue The former value of the account to update.
    /// @param _newValue The new value of the account to update.
    /// @param _maxSortedUsers The maximum size of the heap.
    function update(
        HeapArray storage _heap,
        address _id,
        uint256 _formerValue,
        uint256 _newValue,
        uint256 _maxSortedUsers
    ) internal {
        uint96 formerValue = SafeCast.toUint96(_formerValue);
        uint96 newValue = SafeCast.toUint96(_newValue);

        uint256 size = _heap.size;
        uint256 newSize = computeSize(size, _maxSortedUsers);
        if (size != newSize) _heap.size = newSize;

        if (formerValue != newValue) {
            if (newValue == 0) remove(_heap, _id, formerValue);
            else if (formerValue == 0) insert(_heap, _id, newValue, _maxSortedUsers);
            else if (formerValue < newValue) increase(_heap, _id, newValue, _maxSortedUsers);
            else decrease(_heap, _id, newValue);
        }
    }

    /// PRIVATE ///

    /// @notice Computes a new suitable size from `_size` that is smaller than `_maxSortedUsers`.
    /// @dev We use division by 2 to remove the leaves of the heap.
    /// @param _size The old size of the heap.
    /// @param _maxSortedUsers The maximum size of the heap.
    /// @return The new size computed.
    function computeSize(uint256 _size, uint256 _maxSortedUsers) private pure returns (uint256) {
        while (_size >= _maxSortedUsers) _size >>= 1;
        return _size;
    }

    /// @notice Returns the account of rank `_rank`.
    /// @dev The first rank is 1 and the last one is length of the array.
    /// @dev Only call this function with positive numbers.
    /// @param _heap The heap to search in.
    /// @param _rank The rank of the account.
    /// @return The account of rank `_rank`.
    function getAccount(HeapArray storage _heap, uint256 _rank)
        private
        view
        returns (Account storage)
    {
        return _heap.accounts[_rank - 1];
    }

    /// @notice Sets the value at `_rank` in the `_heap` to be `_newValue`.
    /// @dev The heap may lose its invariant about the order of the values stored.
    /// @dev Only call this function with a rank within array's bounds.
    /// @param _heap The heap to modify.
    /// @param _rank The rank of the account in the heap to be set.
    /// @param _newValue The new value to set the `_rank` to.
    function setAccountValue(
        HeapArray storage _heap,
        uint256 _rank,
        uint96 _newValue
    ) private {
        _heap.accounts[_rank - 1].value = _newValue;
    }

    /// @notice Sets `_rank` in the `_heap` to be `_account`.
    /// @dev The heap may lose its invariant about the order of the values stored.
    /// @dev Only call this function with a rank within array's bounds.
    /// @param _heap The heap to modify.
    /// @param _rank The rank of the account in the heap to be set.
    /// @param _account The account to set the `_rank` to.
    function setAccount(
        HeapArray storage _heap,
        uint256 _rank,
        Account memory _account
    ) private {
        _heap.accounts[_rank - 1] = _account;
        _heap.ranks[_account.id] = _rank;
    }

    /// @notice Swaps two accounts in the `_heap`.
    /// @dev The heap may lose its invariant about the order of the values stored.
    /// @dev Only call this function with ranks within array's bounds.
    /// @param _heap The heap to modify.
    /// @param _rank1 The rank of the first account in the heap.
    /// @param _rank2 The rank of the second account in the heap.
    function swap(
        HeapArray storage _heap,
        uint256 _rank1,
        uint256 _rank2
    ) private {
        if (_rank1 == _rank2) return;
        Account memory accountOldRank1 = getAccount(_heap, _rank1);
        Account memory accountOldRank2 = getAccount(_heap, _rank2);
        setAccount(_heap, _rank1, accountOldRank2);
        setAccount(_heap, _rank2, accountOldRank1);
    }

    /// @notice Moves an account up the heap until its value is smaller than the one of its parent.
    /// @dev This functions restores the invariant about the order of the values stored when the account at `_rank` is the only one with value greater than what it should be.
    /// @param _heap The heap to modify.
    /// @param _rank The rank of the account to move.
    function shiftUp(HeapArray storage _heap, uint256 _rank) private {
        Account memory accountToShift = getAccount(_heap, _rank);
        uint256 valueToShift = accountToShift.value;
        Account memory parentAccount;
        while (
            _rank > ROOT && valueToShift > (parentAccount = getAccount(_heap, _rank >> 1)).value
        ) {
            setAccount(_heap, _rank, parentAccount);
            _rank >>= 1;
        }
        setAccount(_heap, _rank, accountToShift);
    }

    /// @notice Moves an account down the heap until its value is greater than the ones of its children.
    /// @dev This functions restores the invariant about the order of the values stored when the account at `_rank` is the only one with value smaller than what it should be.
    /// @param _heap The heap to modify.
    /// @param _rank The rank of the account to move.
    function shiftDown(HeapArray storage _heap, uint256 _rank) private {
        uint256 size = _heap.size;
        Account memory accountToShift = getAccount(_heap, _rank);
        uint256 valueToShift = accountToShift.value;
        uint256 childRank = _rank << 1;
        // At this point, childRank (resp. childRank+1) is the rank of the left (resp. right) child.

        while (childRank <= size) {
            Account memory childToSwap = getAccount(_heap, childRank);

            // Find the child with largest value.
            if (childRank < size) {
                Account memory rightChild = getAccount(_heap, childRank + 1);
                if (rightChild.value > childToSwap.value) {
                    unchecked {
                        ++childRank; // This cannot overflow because childRank < size.
                    }
                    childToSwap = rightChild;
                }
            }

            if (childToSwap.value > valueToShift) {
                setAccount(_heap, _rank, childToSwap);
                _rank = childRank;
                childRank <<= 1;
            } else break;
        }
        setAccount(_heap, _rank, accountToShift);
    }

    /// @notice Inserts an account in the `_heap`.
    /// @dev Only call this function when `_id` is not in the `_heap`.
    /// @dev Reverts with AddressIsZero if `_value` is 0.
    /// @param _heap The heap to modify.
    /// @param _id The address of the account to insert.
    /// @param _value The value of the account to insert.
    /// @param _maxSortedUsers The maximum size of the heap.
    function insert(
        HeapArray storage _heap,
        address _id,
        uint96 _value,
        uint256 _maxSortedUsers
    ) private {
        // `_heap` cannot contain the 0 address.
        if (_id == address(0)) revert AddressIsZero();

        // Put the account at the end of accounts.
        _heap.accounts.push(Account(_id, _value));
        uint256 accountsLength = _heap.accounts.length;
        _heap.ranks[_id] = accountsLength;

        // Move the account at the end of the heap and restore the invariant.
        uint256 newSize = _heap.size + 1;
        swap(_heap, newSize, accountsLength);
        shiftUp(_heap, newSize);
        _heap.size = computeSize(newSize, _maxSortedUsers);
    }

    /// @notice Decreases the amount of an account in the `_heap`.
    /// @dev Only call this function when `_id` is in the `_heap` with a value greater than `_newValue`.
    /// @param _heap The heap to modify.
    /// @param _id The address of the account to decrease the amount.
    /// @param _newValue The new value of the account.
    function decrease(
        HeapArray storage _heap,
        address _id,
        uint96 _newValue
    ) private {
        uint256 rank = _heap.ranks[_id];
        setAccountValue(_heap, rank, _newValue);

        // We only need to restore the invariant if the account is a node in the heap
        if (rank <= _heap.size >> 1) shiftDown(_heap, rank);
    }

    /// @notice Increases the amount of an account in the `_heap`.
    /// @dev Only call this function when `_id` is in the `_heap` with a smaller value than `_newValue`.
    /// @param _heap The heap to modify.
    /// @param _id The address of the account to increase the amount.
    /// @param _newValue The new value of the account.
    /// @param _maxSortedUsers The maximum size of the heap.
    function increase(
        HeapArray storage _heap,
        address _id,
        uint96 _newValue,
        uint256 _maxSortedUsers
    ) private {
        uint256 rank = _heap.ranks[_id];
        setAccountValue(_heap, rank, _newValue);
        uint256 nextSize = _heap.size + 1;

        if (rank < nextSize) shiftUp(_heap, rank);
        else {
            swap(_heap, nextSize, rank);
            shiftUp(_heap, nextSize);
            _heap.size = computeSize(nextSize, _maxSortedUsers);
        }
    }

    /// @notice Removes an account in the `_heap`.
    /// @dev Only call when this function `_id` is in the `_heap` with value `_removedValue`.
    /// @param _heap The heap to modify.
    /// @param _id The address of the account to remove.
    /// @param _removedValue The value of the account to remove.
    function remove(
        HeapArray storage _heap,
        address _id,
        uint96 _removedValue
    ) private {
        uint256 rank = _heap.ranks[_id];
        uint256 accountsLength = _heap.accounts.length;

        // Swap the last account and the account to remove, then pop it.
        swap(_heap, rank, accountsLength);
        if (_heap.size == accountsLength) _heap.size--;
        _heap.accounts.pop();
        delete _heap.ranks[_id];

        // If the swapped account is in the heap, restore the invariant: its value can be smaller or larger than the removed value.
        if (rank <= _heap.size) {
            if (_removedValue > getAccount(_heap, rank).value) shiftDown(_heap, rank);
            else shiftUp(_heap, rank);
        }
    }

    /// GETTERS ///

    /// @notice Returns the number of users in the `_heap`.
    /// @param _heap The heap parameter.
    /// @return The length of the heap.
    function length(HeapArray storage _heap) internal view returns (uint256) {
        return _heap.accounts.length;
    }

    /// @notice Returns the value of the account linked to `_id`.
    /// @param _heap The heap to search in.
    /// @param _id The address of the account.
    /// @return The value of the account.
    function getValueOf(HeapArray storage _heap, address _id) internal view returns (uint256) {
        uint256 rank = _heap.ranks[_id];
        if (rank == 0) return 0;
        else return getAccount(_heap, rank).value;
    }

    /// @notice Returns the address at the head of the `_heap`.
    /// @param _heap The heap to get the head.
    /// @return The address of the head.
    function getHead(HeapArray storage _heap) internal view returns (address) {
        if (_heap.accounts.length > 0) return getAccount(_heap, ROOT).id;
        else return address(0);
    }

    /// @notice Returns the address at the tail of unsorted portion of the `_heap`.
    /// @param _heap The heap to get the tail.
    /// @return The address of the tail.
    function getTail(HeapArray storage _heap) internal view returns (address) {
        if (_heap.accounts.length > 0) return getAccount(_heap, _heap.accounts.length).id;
        else return address(0);
    }

    /// @notice Returns the address coming before `_id` in accounts.
    /// @dev The account associated to the returned address does not necessarily have a lower value than the one of the account associated to `_id`.
    /// @param _heap The heap to search in.
    /// @param _id The address of the account.
    /// @return The address of the previous account.
    function getPrev(HeapArray storage _heap, address _id) internal view returns (address) {
        uint256 rank = _heap.ranks[_id];
        if (rank > ROOT) return getAccount(_heap, rank - 1).id;
        else return address(0);
    }

    /// @notice Returns the address coming after `_id` in accounts.
    /// @dev The account associated to the returned address does not necessarily have a greater value than the one of the account associated to `_id`.
    /// @param _heap The heap to search in.
    /// @param _id The address of the account.
    /// @return The address of the next account.
    function getNext(HeapArray storage _heap, address _id) internal view returns (address) {
        uint256 rank = _heap.ranks[_id];
        if (rank < _heap.accounts.length) return getAccount(_heap, rank + 1).id;
        else return address(0);
    }
}
