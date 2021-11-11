//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract LenderPool is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public immutable tokenAddress;

    uint16 stableAPY;
    uint16 tradeAPY;

    uint256 _precision = 1E6;

    uint256 public minimumDeposit;

    uint256 public startPeriod;
    uint256 public lockupPeriod;

    mapping(address => uint256) private amountLent;
    mapping(address => uint256) private startPeriodPerUser;
    mapping(address => uint256) private stableRewardsToClaim;

    constructor(
        address tokenAddress_,
        uint16 stableAPY_,
        uint16 tradeAPY_,
        uint256 lockupDurationInDays_
    ) {
        tokenAddress = IERC20(tokenAddress_);
        stableAPY = stableAPY_;
        tradeAPY = tradeAPY_;
        lockupPeriod = (lockupDurationInDays_ * 1 days) + block.timestamp;
        startPeriod = block.timestamp;
    }

    function setMinimumDeposit(uint256 _minimumDeposit) external {
        minimumDeposit = _minimumDeposit;
    }

    function deposit(uint256 amount) external {
        require(amount >= minimumDeposit, "amount lower than minimumDeposit");
        _putAsideRewards();
        amountLent[_msgSender()] += amount;
        //        startPeriodPerUser[_msgSender()] = block.timestamp;
        tokenAddress.safeTransferFrom(_msgSender(), address(this), amount);
    }

    function _putAsideRewards() private {
        stableRewardsToClaim[_msgSender()] = _calculateRewards(_msgSender());
        startPeriodPerUser[_msgSender()] = block.timestamp;
    }

    function getAmountLent(address lender) external view returns (uint256) {
        return amountLent[lender];
    }

    function rewardOf(address lender) external view returns (uint256) {
        return _calculateRewards(lender) + stableRewardsToClaim[lender];
    }

    function _calculateRewards(address lender) private view returns (uint256) {
        uint256 timePassed;
        uint256 duration = lockupPeriod - startPeriod;

        timePassed = (block.timestamp >= lockupPeriod)
            ? lockupPeriod - startPeriodPerUser[lender]
            : block.timestamp - startPeriodPerUser[lender];

        uint256 percentagePassed = ((timePassed * 100) / (duration));

        uint256 rewards = ((amountLent[lender] * (stableAPY * 100)) /
            (_precision * 100));
        return (rewards * (percentagePassed));
    }
}
