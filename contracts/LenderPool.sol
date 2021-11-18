//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./interfaces/ILenderPool.sol";
import "./interfaces/IUniswapV2Router.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


/// @author Polytrade
/// @title LenderPool V1
contract LenderPool is ILenderPool, Ownable, Pausable {
    using SafeERC20 for IERC20;

    IERC20 public immutable stableInstance;
    IUniswapV2Router public immutable router;

    uint16 stableAPY;

    uint _precision = 1E6;

    uint public minimumDeposit;


    struct Round {
        bool paidTrade;
        uint16 bonusAPY;
        uint amountLent;
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
        require(amount_ >= minimumDeposit, "Amount lower than minimumDeposit");

        Round memory round;
        round.bonusAPY = bonusAPY_;
        round.startPeriod = block.timestamp;
        round.endPeriod = block.timestamp + (tenure_ * 1 days);
        round.amountLent = amount_;
        round.paidTrade = paidTrade_;
        roundPerUser[_msgSender()][roundCount[_msgSender()]] = round;
        roundCount[_msgSender()]++;
        amountLent[_msgSender()] += amount_;
        tokenAddress.safeTransferFrom(_msgSender(), address(this), amount_);
    }

    function withdraw(uint roundId) external {
        Round memory round = roundPerUser[_msgSender()][roundId];
        require(
            block.timestamp >= round.endPeriod,
            "Round is not finished yet"
        );
        _withdraw(round.amountLent);
    }

    function withdrawAll() external {
        uint nbRound = roundCount[_msgSender()];
        for (uint i = 0; i < nbRound; i++) {
            withdraw(i);
        }
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
        returns (uint)
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
                rewardSystem.getAmountTradeForUSDT(
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

        uint result = ((APY * round.amountLent * timePassed) / 365 days) *
            _precision;
        return (result / 1E10);
    }

    function _withdraw(uint amount) private {
        amountLent[_msgSender()] -= amount;
        roundPerUser[_msgSender()][roundId].amountLent -= amount;
        tokenAddress.safeTransfer(_msgSender(), amount);
    }
}
