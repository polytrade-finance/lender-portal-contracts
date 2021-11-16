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

    struct Round {
        bool paidTrade;
        uint16 bonusAPY;
        uint256 amount;
        uint256 startPeriod;
        uint256 endPeriod;
    }

    mapping(address => uint256) private amountLent;
    mapping(address => uint256) private startPeriodPerUser;
    mapping(address => uint256) private stableRewardsToClaim;
    mapping(address => uint256) private bonusRewardsToClaim;

    mapping(address => mapping(uint256 => Round)) roundPerUser;
    mapping(address => uint256) roundCount;

    constructor(address tokenAddress_, uint16 stableAPY_) {
        tokenAddress = IERC20(tokenAddress_);
        stableAPY = stableAPY_;
    }

    function newRound(
        uint256 amount_,
        uint16 bonusAPY_,
        uint8 tenure_,
        bool paidTrade_
    ) external {
        require(amount_ >= minimumDeposit, "amount lower than minimumDeposit");

        Round memory round;
        round.bonusAPY = bonusAPY_;
        round.startPeriod = block.timestamp;
        round.endPeriod = block.timestamp + (tenure_ * 1 days);
        round.amount = amount_;
        round.paidTrade = paidTrade_;
        roundPerUser[_msgSender()][roundCount[_msgSender()]] = round;
        console.log("Count: %s", roundCount[_msgSender()]);
        roundCount[_msgSender()]++;
        tokenAddress.safeTransferFrom(_msgSender(), address(this), amount_);
    }

    function getRound(uint256 roundId, address user)
        external
        view
        returns (Round memory)
    {
        return roundPerUser[user][roundId];
    }

    function getNumberOfRounds(address user) external view returns (uint256) {
        return roundCount[user];
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

        bonusRewardsToClaim[_msgSender()] = _calculateBonusRewards(
            _msgSender()
        );

        startPeriodPerUser[_msgSender()] = block.timestamp;
    }

    function _calculateBonusRewards(address lender)
        private
        view
        returns (uint256)
    {
        uint16 bonusAPY = rewardSystem.getUserBonusAPY(lender);
        if (bonusAPY > 0) {
            return
                rewardSystem.getAmountOfTrade(
                    _calculateRewards(lender, bonusAPY)
                );
        }
        return 0;
    }

    function _calculateRewards(address lender, uint16 APY)
        private
        view
        returns (uint256)
    {
        uint256 timePassed;
        uint256 duration = lockupPeriod - startPeriod;

        timePassed = (block.timestamp >= lockupPeriod)
            ? lockupPeriod - startPeriodPerUser[lender]
            : block.timestamp - startPeriodPerUser[lender];

        uint256 percentagePassed = ((timePassed * 100) / (duration));
        uint256 rewards = ((amountLent[lender] * (APY * 100)) /
            (_precision * 100));
        return (rewards * (percentagePassed));
    }
}
