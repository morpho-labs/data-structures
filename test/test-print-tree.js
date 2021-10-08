const { utils, BigNumber } = require('ethers');
const { ethers } = require('hardhat');

describe('Test RedBlackBinaryTree Library', () => {
  let testRedBlackBinaryTree;
  let addresses = [];
  let addressesLength;
  const MAX = 10 * 30;

  for (let i = 0; i < 700; i++) {
    addresses.push(utils.solidityKeccak256(['uint256'], [i]).slice(0, 42));
  }
  addressesLength = addresses.length;

  const getRandomNumber = () => Math.floor(Math.random() * MAX + 1);

  beforeEach(async () => {
    const RedBlackBinaryTree = await ethers.getContractFactory('RedBlackBinaryTree');
    const redBlackBinaryTree = await RedBlackBinaryTree.deploy();
    await redBlackBinaryTree.deployed();

    const TestRedBlackBinaryTree = await ethers.getContractFactory('TestRedBlackBinaryTree', {
      libraries: {
        RedBlackBinaryTree: redBlackBinaryTree.address,
      },
    });
    testRedBlackBinaryTree = await TestRedBlackBinaryTree.deploy();
    await testRedBlackBinaryTree.deployed();
  });

  describe('Test', () => {
    it('Test insert many values', async () => {
      for (let i = 0; i < addressesLength; i++) {
        const address = addresses[i];
        await testRedBlackBinaryTree.insert(address, BigNumber.from(getRandomNumber()));
      }
      await printTreeStucture(testRedBlackBinaryTree);
    });
  });
});

async function testScenario(testFile) {
  let i;
  let step;
  let isDelete;
  let readableAction;
  let count = 0;
  let treeCount;
  let sorted = [];
  let before;
  let steps = await loadSteps(testFile);

  if (showProgress) console.log();
  if (showProgress) console.log('Scenario:', testFile);
  if (showProgress) console.log('Number of steps: ' + steps.length);
  if (showProgress) console.log('Steps:');

  for (i = 0; i < steps.length; i++) {
    if (showProgress) cconsole.log('Step:', i, steps[i]['amount']);
  }
  if (showProgress) cconsole.log('Step, action, value, expected count, reported count');

  for (i = 0; i < steps.length; i++) {
    isDelete = steps[i]['amount'] < 0;
    if (isDelete) {
      readableAction = 'delete';
      count--;
    } else {
      readableAction = 'insert';
      count++;
    }
    before = sorted;
    sorted = await applyStep(sorted, i);
    treeCount = await ost.valueKeyCount();
    if (verbose) console.log('step', i, readableAction, 'value:', steps[i]['amount'], count, treeCount.toString(10));
    if (verbose) await printTreeStucture(sorted);
    assert.equal(treeCount.toString(10), count, 'The count does not match the expected count.');
  }
  return;
}

async function printTreeStucture(tree) {
  let i = 0;
  let last;
  let temp;

  first = await tree.returnFirst();
  first = first.toNumber();
  next = await tree.returnNext(first);
  next = next.toNumber();
  // console.log("First %d Last %d Next %d", await first.toNumber(), last, next);

  console.log('****** Node %d ******', first);
  for (let j = 0; j < (await tree.returnGetNumberOfKeysAtValue(first)); j++) {
    console.log('At index', j, ' key: ', await tree.returnValueKeyAtIndex(first, j));
  }
  console.log("\n");

  while (next != 0) {

    temp = await tree.returnGetNumberOfKeysAtValue(next);

    console.log('****** Node %d ******', next);
    for (let j = 0; j < temp; j++) {
      console.log('At index', j, ' key: ', await tree.returnValueKeyAtIndex(next, j));
    }
    console.log("\n");

    next = await tree.returnNext(next);
    next = await next.toNumber()
  }

  return;
}
