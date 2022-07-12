# Morpho Data Structures 🦋

This repository contains the data structures that can be used for the Morpho's matching engine 🦋.
The goal is to compare them in terms of security and gas consumption to find the best solution for the protocol and its users.

## Installation

Install foundry, you can find the instructions [here](https://book.getfoundry.sh/getting-started/installation.html).

Then, run `make`.

## Testing

Run `make test`.

For the `RedBlackBinaryTree`, you can run the tests with hardhat with `yarn test`.

# Data structures

The data structures we implement and modified are based on public works of amazing developers. We thank them for what they have done 🙏

You can refer to the following table for the complexity of some data structures.

![complexities](https://devopedia.org/images/article/17/7752.1513922040.jpg)

## Double Linked List

The current implementation of the double linked list is based on this [article](https://hackernoon.com/a-linked-list-implementation-for-ethereum-deep-dive-oy9432pa) written by Alberto Cuesta Cañada. You can find the repository [here](https://github.com/HQ20/contracts/tree/master/contracts/lists). Note that the code has been modified to meet our own needs and to allow us to sort the first accounts of the double linked list. Our implementation is not a generalised one.
What you can with it:

- Insert an address sorted by a value passed along this address.
- Insert (and its value) before an account.

## Red Black Binary Tree

A [Red Black Binary Tree](https://en.wikipedia.org/wiki/Red%E2%80%93black_tree) is a kind of binary tree that allows insertion / deletion / search in `O(log(n))`.
Our implementation is a modified version of the [OrderStatisticsTree repository](https://github.com/rob-Hitchens/OrderStatisticsTree) written by [Rob Hitechn](https://github.com/rob-Hitchens) which is also based on [BokkyPooBahsRedBlackTreeLibrary repository](https://github.com/bokkypoobah/BokkyPooBahsRedBlackTreeLibrary) written by [bokkypoobah](https://github.com/bokkypoobah).
Our modified version makes keys unique items instead of just (key, value) unique pairs.

In order to manipulate a binary tree and visualize how it manages to stay balanced, this [tool](https://www.cs.usfca.edu/~galles/visualization/RedBlack.html) is very useful. You can also find [here](http://ion.uwinnipeg.ca/~ychen2/advancedAD/Red-black%20Tree.pdf) the pseudo-code logic of the tree's function.

## HeapOrdering

This implementation is based on a heap data structure, and refines it by adding an unsorted portion after it. This gives us an approximation of a heap, and thus operations are performed in constant time. The main entry point is the `update` function, calling internally either `insert`, `increase`, `decrease` or `remove`.

## Other data structures

Other data structures may be explored in the future and we are open to any suggestions or optimisation of current implementations ⚡️

# Contributing

In this section, you will find some guidelines to read before contributing to the project.

## Creating issues and PRs

Guidelines for creating issues and PRs:

- Issues must be created and labelled with relevant labels (type of issues, high/medium/low priority, etc.).
- Nothing should be pushed directly to the `main` branch.
- Pull requests must be created before and branch names must follow this pattern: `feat/<feature-name>`, `test/<test-name>` or `fix/<fix-name>`. `docs`, `ci` can also be used. The goal is to have clear branches names and make easier their management.
- PRs must be labelled with the relevant labels.
- Issues must be linked to PRs so that once the PR is merged related issues are closed at the same time.
- Reviewers must be added to the PR.
- For commits, we use the bitmoji VS Code extension 🙃

## Before merging a PR

Before merging a PR:

- PR must have been reviewed by reviewers. The must deliver a complete report on the smart contracts (see the section below).
- Comments and requested changes must have been resolved.
- PR must have been approved by every reviewers.
- CI must pass.

## Code Formatting

We use prettier with the default configuration mentionned in the [Solidity Prettier Plugin](https://github.com/prettier-solidity/prettier-plugin-solidity).
We recommend developers using VS Code to set their local config as below:

```
{
	"editor.formatOnSave": true,
	"solidity.formatter": "prettier",
	"editor.defaultFormatter": "esbenp.prettier-vscode"
}
```

In doing so the code will be formatted on each save.

We use Husky hook to format code before being pushed to any remote branch to enforce coding style among all developers.

# Questions

For any question you can send an email to [merlin@mopho.best](mailto:merlin@morpho.best) 😊
