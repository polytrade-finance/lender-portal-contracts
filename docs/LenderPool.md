## `LenderPool`






### `constructor(address stableAddress_, uint16 stableAPY_)` (public)





### `setMinimumDeposit(uint256 _minimumDeposit)` (external)

changes the minimum amount required for deposit (newRound)


update `minimumDeposit` with `_minimumDeposit`


### `newRound(address lender, uint256 amount, uint16 bonusAPY, uint8 tenure, bool paidTrade)` (external)

create new Round on behalf of the lender, each deposit has its own round


`lender` must approve the amount to be deposited first
only `Owner` can launch a new round
only function that can be `Paused`
add new round to `_lenderRounds`
`amount` will be transferred from `lender` to `address(this)`
emits Deposit event


### `withdrawAllFinishedRounds(address lender)` (external)

Withdraw all amounts lent and claim rewards for all finished rounds


`withdraw` function is called for each finished round
only `Owner` can withdrawAllFinishedRounds


### `getRound(address lender, uint256 roundId) → struct ILenderPool.Round` (external)

Returns all the information of a specific round for a specific lender


returns Round struct of the specific round for a specific lender


### `getNumberOfRounds(address lender) → uint256` (external)

Returns the number of rounds for the a specific lender




### `getAmountLent(address lender) → uint256` (external)

Returns the total amount lent for the lender on every round




### `getFinishedRounds(address lender) → uint256[]` (external)

Returns roundIds of every finished round




### `stableRewardOf(address lender, uint256 roundId) → uint256` (external)

Returns the amount of stable rewards for a specific lender on a specific roundId


run `_calculateRewards` with `_stableAPY` based on the amountLent


### `bonusRewardOf(address lender, uint256 roundId) → uint256` (external)

Returns the amount of bonus rewards for a specific lender on a specific roundId


run `_calculateRewards` with `_lenderRounds[lender][roundId].bonusAPY` based on the amountLent


### `totalRewardOf(address lender, uint256 roundId) → uint256` (external)

Returns the total amount of rewards for a specific lender on a specific roundId


calculate rewards for stable (stableAPY) and bonus (bonusAPY)


### `withdraw(address lender, uint256 roundId)` (public)

Withdraw the initial deposit of the specified lender for the specified roundId
claim rewards of the specified roundId for the specific lender


only `Owner` can withdraw
round must be finish (`block.timestamp` must be higher than `round.endPeriod`)
run `_claimRewards` and `_withdraw`





