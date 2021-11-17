//SPDX-License-Identifier: MIT
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

    uint _precision = 1E6;

    uint public minimumDeposit;


    struct Round {
        bool paidTrade;
        uint16 bonusAPY;
        uint amount;
        uint startPeriod;
        uint endPeriod;
    }

    mapping(address => uint) private amountLent;

    mapping(address => mapping(uint => Round)) roundPerUser;
    mapping(address => uint) roundCount;

    constructor(address tokenAddress_, uint16 stableAPY_) {
        tokenAddress = IERC20(tokenAddress_);
        stableAPY = stableAPY_;
    }

    function newRound(
        uint amount_,
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
        roundCount[_msgSender()]++;
        tokenAddress.safeTransferFrom(_msgSender(), address(this), amount_);
    }

    function getRound(uint roundId, address user)
        external
        view
        returns (Round memory)
    {
        return roundPerUser[user][roundId];
    }

    function getNumberOfRounds(address user) external view returns (uint) {
        return roundCount[user];
    }

    function setRewardSystemContract(address _rewardSystem) external {
        rewardSystem = RewardSystem(_rewardSystem);
    }

    function setMinimumDeposit(uint _minimumDeposit) external {
        minimumDeposit = _minimumDeposit;
    }

    function getAmountLent(address lender) external view returns (uint) {
        return amountLent[lender];
    }

    function stableRewardOf(uint roundId, address lender)
        external
        view
        returns (uint256)
    {
        return _calculateRewards(roundId, lender, stableAPY);
    }

    function bonusRewardOf(uint roundId, address lender)
        external
        view
        returns (uint)
    {
        return
            _calculateRewards(
                roundId,
                lender,
                roundPerUser[lender][roundId].bonusAPY
            );
    }

    function tradeRewardOf(uint roundId, address lender)
        external
        view
        returns (uint)
    {
        uint16 bonusAPY = roundPerUser[lender][roundId].bonusAPY;
        if (bonusAPY > 0) {
            return
                rewardSystem.getAmountOfTrade(
                    _calculateRewards(roundId, lender, bonusAPY)
                );
        }
        return 0;
    }

    function _calculateRewards(
        uint roundId,
        address lender,
        uint16 APY
    ) private view returns (uint) {
        Round memory round = roundPerUser[lender][roundId];

        uint timePassed = (block.timestamp >= round.endPeriod)
            ? round.endPeriod - round.startPeriod
            : block.timestamp - round.startPeriod;

        uint result = ((APY * round.amount * timePassed) / 365 days) *
            _precision;
        return (result / 1E10);
    }
}
