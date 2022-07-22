// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeCast.sol";

library ThreeHeapOrdering {
    struct Account {
        address id; // The address of the account.
        uint96 value; // The value of the account.
    }

    struct HeapArray {
        Account[] accounts; // All the accounts.
        uint256 size; // The size of the heap portion of the structure, should be less than accounts length, the rest is an unordered array.
        mapping(address => uint256) indexes; // A mapping from an address to a index in accounts.
    }

    /// CONSTANTS ///

    uint256 private constant ROOT = 0;

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
        while (_size >= _maxSortedUsers) _size /= 3;
        return _size;
    }

    /// @notice Sets `_index` in the `_heap` to be `_account`.
    /// @dev The heap may lose its invariant about the order of the values stored.
    /// @dev Only call this function with an index within array's bounds.
    /// @param _heap The heap to modify.
    /// @param _index The index of the account in the heap to be set.
    /// @param _account The account to set the `_index` to.
    function setAccount(
        HeapArray storage _heap,
        uint256 _index,
        Account memory _account
    ) private {
        _heap.accounts[_index] = _account;
        _heap.indexes[_account.id] = _index;
    }

    /// @notice Moves an account up the heap until its value is smaller than the one of its parent.
    /// @dev This functions restores the invariant about the order of the values stored when the account to move is the only one with value greater than what it should be.
    /// @param _heap The heap to modify.
    /// @param _accountToShift The account to move.
    /// @param _index The index of the account to move.
    function shiftUp(
        HeapArray storage _heap,
        Account memory _accountToShift,
        uint256 _index
    ) private {
        Account memory parentAccount;
        uint256 parentIndex;
        while (
            _index > ROOT &&
            _accountToShift.value >
            (parentAccount = _heap.accounts[parentIndex = (_index - 1) / 3]).value
        ) {
            setAccount(_heap, _index, parentAccount);
            _index = parentIndex;
        }
        setAccount(_heap, _index, _accountToShift);
    }

    /// @notice Moves an account down the heap until its value is greater than the ones of its children.
    /// @dev This functions restores the invariant about the order of the values stored when the account to move is the only one with value smaller than what it should be.
    /// @param _heap The heap to modify.
    /// @param _accountToShift The account to move.
    /// @param _index The index of the account to move.
    function shiftDown(
        HeapArray storage _heap,
        Account memory _accountToShift,
        uint256 _index
    ) private {
        uint256 size = _heap.size;
        Account memory targetAccount = _accountToShift;
        uint256 targetIndex = _index;
        Account memory nextAccount;
        uint256 nextIndex = _index * 3;
        uint256 rightChildIndex;

        for (;;) {
            rightChildIndex = nextIndex + 3;
            while (++nextIndex <= rightChildIndex && nextIndex < size) {
                nextAccount = _heap.accounts[nextIndex];
                if (nextAccount.value > targetAccount.value) {
                    targetAccount = nextAccount;
                    targetIndex = nextIndex;
                }
            }

            if (targetIndex == _index) break;

            setAccount(_heap, _index, targetAccount);

            targetAccount = _accountToShift;
            _index = targetIndex;
            nextIndex = _index * 3;
        }
        setAccount(_heap, _index, _accountToShift);
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

        uint256 size = _heap.size;
        uint256 accountsLength = _heap.accounts.length;

        if (size < accountsLength) {
            Account memory firstAccountNotSorted = _heap.accounts[size];

            _heap.indexes[firstAccountNotSorted.id] = accountsLength;
            _heap.accounts.push(firstAccountNotSorted);
        } else _heap.accounts.push();

        shiftUp(_heap, Account(_id, _value), size);
        _heap.size = computeSize(size + 1, _maxSortedUsers);
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
        uint256 index = _heap.indexes[_id];

        if (index < (_heap.size - 1) / 3) shiftDown(_heap, Account(_id, _newValue), index);
        else _heap.accounts[index].value = _newValue;
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
        uint256 index = _heap.indexes[_id];
        _heap.accounts[index].value = _newValue;
        uint256 size = _heap.size;

        if (index < size) shiftUp(_heap, Account(_id, _newValue), index);
        else {
            Account memory firstAccountNotSorted = _heap.accounts[size];
            setAccount(_heap, index, firstAccountNotSorted);
            shiftUp(_heap, Account(_id, _newValue), size);
            _heap.size = computeSize(size + 1, _maxSortedUsers);
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
        uint256 index = _heap.indexes[_id];
        delete _heap.indexes[_id];
        uint256 accountsLength = _heap.accounts.length;

        if (_heap.size == accountsLength) _heap.size--;
        if (index == accountsLength - 1) {
            _heap.accounts.pop();
            return;
        }

        Account memory lastAccount = _heap.accounts[accountsLength - 1];
        _heap.accounts.pop();

        if (index < _heap.size) {
            if (_removedValue > lastAccount.value) shiftDown(_heap, lastAccount, index);
            else shiftUp(_heap, lastAccount, index);
        } else setAccount(_heap, index, lastAccount);
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
        uint256 index = _heap.indexes[_id];
        if (index >= _heap.accounts.length) return 0;
        Account memory account = _heap.accounts[index];
        if (account.id != _id) return 0;
        else return account.value;
    }

    /// @notice Returns the address at the head of the `_heap`.
    /// @param _heap The heap to get the head.
    /// @return The address of the head.
    function getHead(HeapArray storage _heap) internal view returns (address) {
        if (_heap.accounts.length > 0) return _heap.accounts[0].id;
        else return address(0);
    }

    /// @notice Returns the address at the tail of unsorted portion of the `_heap`.
    /// @param _heap The heap to get the tail.
    /// @return The address of the tail.
    function getTail(HeapArray storage _heap) internal view returns (address) {
        uint256 accountsLength = _heap.accounts.length;
        if (accountsLength > 0) return _heap.accounts[accountsLength - 1].id;
        else return address(0);
    }

    /// @notice Returns the address coming before `_id` in accounts.
    /// @dev The account associated to the returned address does not necessarily have a lower value than the one of the account associated to `_id`.
    /// @param _heap The heap to search in.
    /// @param _id The address of the account.
    /// @return The address of the previous account.
    function getPrev(HeapArray storage _heap, address _id) internal view returns (address) {
        uint256 index = _heap.indexes[_id];
        if (index > ROOT) return _heap.accounts[index - 1].id;
        else return address(0);
    }

    /// @notice Returns the address coming after `_id` in accounts.
    /// @dev The account associated to the returned address does not necessarily have a greater value than the one of the account associated to `_id`.
    /// @param _heap The heap to search in.
    /// @param _id The address of the account.
    /// @return The address of the next account.
    function getNext(HeapArray storage _heap, address _id) internal view returns (address) {
        uint256 index = _heap.indexes[_id];
        if (index + 1 >= _heap.accounts.length || _heap.accounts[index].id != _id)
            return address(0);
        else return _heap.accounts[index + 1].id;
    }
}
