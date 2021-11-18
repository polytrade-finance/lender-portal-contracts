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

    address public immutable trade;

    uint16 private immutable _stableAPY;
    uint private constant _precision = 1E6;

    uint public minimumDeposit;

    mapping(address => uint) private _amountLent;
    mapping(address => uint) private _roundCount;
    mapping(address => mapping(uint => Round)) private _userRounds;

    constructor(address stableAddress_, uint16 stableAPY_) {
        stableInstance = IERC20(stableAddress_);
        _stableAPY = stableAPY_;
        router = IUniswapV2Router(0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff);
        trade = 0x692AC1e363ae34b6B489148152b12e2785a3d8d6;
    }

    function setMinimumDeposit(uint _minimumDeposit) external onlyOwner {
        minimumDeposit = _minimumDeposit;
    }

    function newRound(
        address lender,
        uint amount,
        uint16 bonusAPY,
        uint8 tenure,
        bool paidTrade
    ) external onlyOwner whenNotPaused {
        require(amount >= minimumDeposit, "Amount lower than minimumDeposit");
        Round memory round = Round({
            bonusAPY : bonusAPY,
            startPeriod : block.timestamp,
            endPeriod : block.timestamp + (tenure * 1 days),
            amountLent : amount,
            paidTrade : paidTrade
        });
        _userRounds[lender][_roundCount[lender]] = round;
        _roundCount[lender]++;
        _amountLent[lender] += amount;
        stableInstance.safeTransferFrom(lender, address(this), amount);
        emit Deposit(lender, _roundCount[lender] - 1, amount);
    }

    function withdraw(address lender, uint roundId) public onlyOwner {
        Round memory round = _userRounds[lender][roundId];
        require(
            block.timestamp >= round.endPeriod,
            "Round is not finished yet"
        );
        _claimRewards(lender, roundId);
        _withdraw(lender, roundId, round.amountLent);
    }

    function withdrawAllFinishedRounds(address lender) external onlyOwner {
        uint[] memory rounds = _getFinishedRounds(lender);

        for (uint i = 0; i < rounds.length; i++) {
            withdraw(lender, rounds[i]);
        }
    }

    function getRound(address user, uint roundId)
        external
        view
        returns (Round memory)
    {
        return _userRounds[user][roundId];
    }

    function getNumberOfRounds(address user) external view returns (uint) {
        return _roundCount[user];
    }

    function getAmountLent(address lender) external view returns (uint) {
        return _amountLent[lender];
    }

    function getFinishedRounds(address lender)
        external
        view
        returns (uint[] memory)
    {
        return _getFinishedRounds(lender);
    }

    function stableRewardOf(address lender, uint roundId)
        external
        view
        returns (uint)
    {
        return _calculateRewards(lender, roundId, _stableAPY);
    }

    function bonusRewardOf(address lender, uint roundId)
        external
        view
        returns (uint)
    {
        return
            _calculateRewards(
                lender,
                roundId,
                _userRounds[lender][roundId].bonusAPY
            );
    }

    function totalRewardOf(address lender, uint roundId)
        external
        view
        returns (uint)
    {
        uint stableReward = _calculateRewards(lender, roundId, _stableAPY);

        uint bonusReward = _calculateRewards(
            lender,
            roundId,
            _userRounds[lender][roundId].bonusAPY
        );

        return stableReward + bonusReward;
    }

    function _claimRewards(address lender, uint roundId) private {
        Round memory round = _userRounds[lender][roundId];
        stableInstance.approve(address(router), ~uint(0));
        if (round.paidTrade) {
            uint amountTrade = _swapExactTokens(lender, roundId, (_stableAPY + round.bonusAPY));
            emit ClaimTrade(lender, roundId, amountTrade);
        } else {
            uint amountStable = _calculateRewards(lender, roundId, _stableAPY);
            stableInstance.transfer(
                lender,
                amountStable
            );
            emit ClaimStable(lender, roundId, amountStable);
            uint amountTrade = _swapExactTokens(lender, roundId, round.bonusAPY);
            emit ClaimTrade(lender, roundId, amountTrade);
        }
    }

    function _withdraw(
        address lender,
        uint roundId,
        uint amount
    ) private {
        _amountLent[lender] -= amount;
        _userRounds[lender][roundId].amountLent -= amount;
        stableInstance.safeTransfer(lender, amount);
        emit Withdraw(lender, roundId, amount);
    }

    function _swapExactTokens(
        address lender,
        uint roundId,
        uint16 rewardAPY
    ) private returns (uint) {
        uint amountStable = _calculateRewards(lender, roundId, rewardAPY);
        uint amountTrade = router.swapExactTokensForTokens(
                amountStable,
                0,
                _getPath(),
                lender,
                block.timestamp
            )[2];
        emit Swapped(amountStable, amountTrade);
        return amountTrade;
    }

    function _calculateRewards(
        address lender,
        uint roundId,
        uint16 rewardAPY
    ) private view returns (uint) {
        Round memory round = _userRounds[lender][roundId];

        uint timePassed = (block.timestamp >= round.endPeriod)
            ? round.endPeriod - round.startPeriod
            : block.timestamp - round.startPeriod;

        uint result = ((rewardAPY * round.amountLent * timePassed) / 365 days) *
            _precision;
        return (result / 1E10);
    }

    function _withdraw(uint amount) private {
        amountLent[_msgSender()] -= amount;
        roundPerUser[_msgSender()][roundId].amountLent -= amount;
        tokenAddress.safeTransfer(_msgSender(), amount);
    }
}
