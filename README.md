# Trial task for SHIFT

It was decided to consider best practices and split the task into 2 contracts:
- On a vault that defines the owner and address of the strategy. It will store USDC, invest it in the strategy, exit the strategy and withdraw USDC. This is done to make the process of strategy replacement cheaper.
- On the strategy itself, which performs all the required functionality:

1. Deposit USDC as collateral into the lending protocol Moonwell.
2. Borrow DAI against the collateral of USDC with an LTV of 70%. 3.
3. Swap borrowed DAI to USDC on any DEX. 4.
4. Deposit the received USDC into the Moonwell protocol as collateral.
To run the script, execute:

```shell
npm install
npx hardhat run ./test/ShiftTest.js
```