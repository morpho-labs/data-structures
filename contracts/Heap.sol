// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.0;

library BasicHeap {
    struct Account {
        address id; // The address of the account.
        uint256 value; // The value of the account.
    }

    struct Heap {
        Account[] accounts; // All the accounts.
        mapping(address => uint256) ranks; // A mapping from an address to a rank in accounts. Beware: ranks are shifted by one compared to indexes, so the first rank is 1 and not 0.
    }

    /// ERRORS ///

    /// @notice Thrown when trying to modify an account with a wrong value.
    error WrongValue();

    /// @notice Thrown when the address is zero at insertion.
    error AddressIsZero();

    /// @notice Thrown when the account is already inserted in the heap.
    error AccountAlreadyInserted();

    /// @notice Thrown when the account to modify does not exist.
    error AccountDoesNotExist();

    /// INTERNAL ///

    /// @notice Inserts an account in the `_heap`.
    /// @param _heap The heap to modify.
    /// @param _id The address of the account to insert.
    /// @param _value The value of the account to insert.
    function insert(
        Heap storage _heap,
        address _id,
        uint256 _value
    ) internal {
        if (_value == 0) revert WrongValue();
        if (_id == address(0)) revert AddressIsZero();
        if (_heap.ranks[_id] != 0) revert AccountAlreadyInserted();

        // Put the account at the end of the heap.
        _heap.accounts.push(Account(_id, _value));
        uint256 size = getSize(_heap);
        _heap.ranks[_id] = size;

        // Restore the invariant.
        shiftUp(_heap, size);
    }

    /// @notice Decreases the amount of an account in the `_heap`.
    /// @param _heap The heap to modify.
    /// @param _id The address of the account to decrease the amount.
    /// @param _newValue The new value of the account.
    function decrease(
        Heap storage _heap,
        address _id,
        uint256 _newValue
    ) internal {
        uint256 rank = _heap.ranks[_id];
        if (rank == 0) revert AccountDoesNotExist();
        uint256 oldValue = getAccount(_heap, rank).value;
        if (_newValue >= oldValue || _newValue == 0) revert WrongValue();

        setAccountValue(_heap, rank, _newValue);
        shiftDown(_heap, rank);
    }

    /// @notice Increases the amount of an account in the `_heap`.
    /// @dev Only call this function when `_id` is in the `_heap` with a smaller value than `_newValue`.
    /// @param _heap The heap to modify.
    /// @param _id The address of the account to increase the amount.
    /// @param _newValue The new value of the account.
    function increase(
        Heap storage _heap,
        address _id,
        uint256 _newValue
    ) internal {
        uint256 rank = _heap.ranks[_id];
        if (rank == 0) revert AccountDoesNotExist();
        uint256 oldValue = getAccount(_heap, rank).value;
        if (_newValue <= oldValue) revert WrongValue();

        setAccountValue(_heap, rank, _newValue);
        shiftUp(_heap, rank);
    }

    /// @notice Removes an account in the `_heap`.
    /// @dev Only call when `_id` is in the `_heap`.
    /// @param _heap The heap to modify.
    /// @param _id The address of the account to remove.
    function remove(Heap storage _heap, address _id) internal {
        uint256 rank = _heap.ranks[_id];
        if (rank == 0) revert AccountDoesNotExist();
        uint256 removedValue = getAccount(_heap, rank).value;
        uint256 size = getSize(_heap);

        if (rank == size) {
            _heap.accounts.pop();
            delete _heap.ranks[_id];
        } else {
            swap(_heap, rank, size);
            _heap.accounts.pop();
            delete _heap.ranks[_id];
            if (getAccount(_heap, rank).value > removedValue) shiftUp(_heap, rank);
            else shiftDown(_heap, rank);
        }
    }

    /// PRIVATE ///

    /// @notice Returns the account of rank `_rank`.
    /// @dev The first rank is 1 and the last one is the size of the heap.
    /// @dev Only call this function with positive numbers.
    /// @param _heap The heap to search in.
    /// @param _rank The rank of the account.
    /// @return The account of rank `_rank`.
    function getAccount(Heap storage _heap, uint256 _rank) private view returns (Account storage) {
        return _heap.accounts[_rank - 1];
    }

    /// @notice Sets `_index` in the `_heap` to be `_account`.
    /// @dev The heap may lose its invariant about the order of the values stored.
    /// @dev Only call this function with a rank within array's bounds.
    /// @param _heap The heap to modify.
    /// @param _rank The rank of the account in the heap to be set.
    /// @param _account The account to set the `_rank` to.
    function setAccount(
        Heap storage _heap,
        uint256 _rank,
        Account memory _account
    ) private {
        _heap.accounts[_rank - 1] = _account;
        _heap.ranks[_account.id] = _rank;
    }

    /// @notice Sets the value at `_rank` in the `_heap` to be `_newValue`.
    /// @dev The heap may lose its invariant about the order of the values stored.
    /// @dev Only call this function with a rank within array's bounds.
    /// @param _heap The heap to modify.
    /// @param _rank The rank of the account in the heap to be set.
    /// @param _newValue The new value to set the `_rank` to.
    function setAccountValue(
        Heap storage _heap,
        uint256 _rank,
        uint256 _newValue
    ) private {
        _heap.accounts[_rank - 1].value = _newValue;
    }

    /// @notice Swaps two accounts in the `_heap`.
    /// @dev The heap may lose its invariant about the order of the values stored.
    /// @dev Only call this function with ranks within array's bounds.
    /// @param _heap The heap to modify.
    /// @param _rank1 The rank of the first account in the heap.
    /// @param _rank2 The rank of the second account in the heap.
    function swap(
        Heap storage _heap,
        uint256 _rank1,
        uint256 _rank2
    ) private {
        Account memory accountOldRank1 = getAccount(_heap, _rank1);
        Account memory accountOldRank2 = getAccount(_heap, _rank2);
        setAccount(_heap, _rank1, accountOldRank2);
        setAccount(_heap, _rank2, accountOldRank1);
    }

    /// @notice Moves an account up the heap until its value is smaller than the one of its parent.
    /// @dev This functions restores the invariant about the order of the values stored when the account at `_rank` is the only one with value greater than what it should be.
    /// @param _heap The heap to modify.
    /// @param _rank The index of the account to move.
    function shiftUp(Heap storage _heap, uint256 _rank) private {
        Account memory initialAccount = getAccount(_heap, _rank);
        uint256 initialValue = initialAccount.value;
        while (_rank > 1 && initialValue > getAccount(_heap, _rank / 2).value) {
            setAccount(_heap, _rank, getAccount(_heap, _rank / 2));
            _rank /= 2;
        }
        setAccount(_heap, _rank, initialAccount);
    }

    /// @notice Moves an account down the heap until its value is greater than the ones of its children.
    /// @dev This functions restores the invariant about the order of the values stored when the account at `_rank` is the only one with value smaller than what it should be.
    /// @param _heap The heap to modify.
    /// @param _rank The index of the account to move.
    function shiftDown(Heap storage _heap, uint256 _rank) private {
        uint256 size = getSize(_heap);
        Account memory initialAccount = getAccount(_heap, _rank);
        uint256 initialValue = initialAccount.value;
        Account memory childAccount;
        uint256 childRank = _rank * 2;
        // At this point, childRank (resp. childRank+1) is the rank of the left (resp. right) child.

        while (childRank <= size) {
            // Compute the rank of the child with largest value.
            if (
                childRank < size &&
                getAccount(_heap, childRank + 1).value > getAccount(_heap, childRank).value
            ) childRank++;

            childAccount = getAccount(_heap, childRank);

            if (childAccount.value > initialValue) {
                setAccount(_heap, _rank, childAccount);
                _rank = childRank;
                childRank *= 2;
            } else break;
        }
        setAccount(_heap, _rank, initialAccount);
    }

    /// VIEW ///

    /// @notice Returns the size of the `_heap`.
    /// @param _heap The heap parameter.
    /// @return The size of the heap.
    function getSize(Heap storage _heap) internal view returns (uint256) {
        return _heap.accounts.length;
    }

    /// @notice Returns the value of the account linked to `_id`, returns 0 if the account is not in the `_heap`.
    /// @param _heap The heap to search in.
    /// @param _id The address of the account.
    /// @return The value of the account.
    function getValueOf(Heap storage _heap, address _id) internal view returns (uint256) {
        uint256 rank = _heap.ranks[_id];
        if (rank == 0) return 0;
        else return getAccount(_heap, rank).value;
    }

    /// @notice Returns the address at the root of the `_heap`, returns the zero address if the `_heap` is empty.
    /// @param _heap The heap to get the root.
    /// @return The address of the root node.
    function getRoot(Heap storage _heap) internal view returns (address) {
        if (getSize(_heap) > 0) return getAccount(_heap, 1).id;
        else return address(0);
    }

    /// @notice Returns the address of the parent node of the given address in the `_heap`, returns the zero address if it's the root or if the address is not in the heap.
    /// @param _heap The heap in which to search for the parent.
    /// @param _id The address to get the parent.
    /// @return The address of the parent.
    function getParent(Heap storage _heap, address _id) internal view returns (address) {
        uint256 rank = _heap.ranks[_id] / 2;
        if (rank != 0) return getAccount(_heap, rank).id;
        else return address(0);
    }

    /// @notice Returns the address of the left child of the given address, returns the zero address if it's not in the heap or if it has no left child.
    /// @param _heap The heap in which to search for the left child.
    /// @param _id The address to get the left child.
    /// @return The address of the left child.
    function getLeftChild(Heap storage _heap, address _id) internal view returns (address) {
        uint256 rank = _heap.ranks[_id] * 2;
        if (rank != 0 && rank <= getSize(_heap)) return getAccount(_heap, rank).id;
        else return address(0);
    }

    /// @notice Returns the address of the right child of the given address, returns the zero address if it's not in the heap or if it has no right child.
    /// @param _heap The heap in which to search for the right child.
    /// @param _id The address to get the right child.
    /// @return The address of the right child.
    function getRightChild(Heap storage _heap, address _id) internal view returns (address) {
        uint256 rank = _heap.ranks[_id] * 2 + 1;
        if (rank != 1 && rank <= getSize(_heap)) return getAccount(_heap, rank).id;
        else return address(0);
    }
}
