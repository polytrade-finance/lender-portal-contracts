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
