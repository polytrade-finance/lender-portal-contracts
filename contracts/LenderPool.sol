//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./RewardSystem.sol";

contract LenderPool is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public immutable tokenAddress;
    RewardSystem rewardSystem;

    uint16 stableAPY;

    uint256 _precision = 1E6;

    uint256 public minimumDeposit;

    uint256 public startPeriod;
    uint256 public lockupPeriod;

    mapping(address => uint256) private amountLent;
    mapping(address => uint256) private startPeriodPerUser;
    mapping(address => uint256) private stableRewardsToClaim;
    mapping(address => uint256) private bonusRewardsToClaim;

    constructor(
        address tokenAddress_,
        uint16 stableAPY_,
        uint256 lockupDurationInDays_
    ) {
        tokenAddress = IERC20(tokenAddress_);
        stableAPY = stableAPY_;
        lockupPeriod = (lockupDurationInDays_ * 1 days) + block.timestamp;
        startPeriod = block.timestamp;
    }

    function setRewardSystemContract(address _rewardSystem) external {
        rewardSystem = RewardSystem(_rewardSystem);
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
        stableRewardsToClaim[_msgSender()] = _calculateRewards(_msgSender(), stableAPY);
        //check for BONUS
        startPeriodPerUser[_msgSender()] = block.timestamp;
    }

    function getAmountLent(address lender) external view returns (uint256) {
        return amountLent[lender];
    }

    function rewardOf(address lender) external view returns (uint256) {
        return
            _calculateRewards(lender, stableAPY) + stableRewardsToClaim[lender];
    }

    function bonusRewardOf(address lender) external view returns (uint256) {
        return _calculateBonusRewards(lender) + bonusRewardsToClaim[lender];
    }

    function _putAsideRewards() private {
        stableRewardsToClaim[_msgSender()] = _calculateRewards(
            _msgSender(),
            stableAPY
        );

        return rewardSystem.getAmountOfTrade(_calculateRewards(lender, tradeAPY));
    }

    function _calculateRewards(address lender, uint16 APY) private view returns (uint256) {
        uint256 timePassed;
        uint256 duration = lockupPeriod - startPeriod;

        timePassed = (block.timestamp >= lockupPeriod)
            ? lockupPeriod - startPeriodPerUser[lender]
            : block.timestamp - startPeriodPerUser[lender];

        uint256 percentagePassed = ((timePassed * 100) / (duration));
//todo decimals usdt
        uint256 rewards = ((amountLent[lender] * (APY * 100)) /
            (_precision * 100));
        return (rewards * (percentagePassed));
    }
}
