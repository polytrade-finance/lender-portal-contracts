//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface ILenderPool {
    struct Round {
        bool paidTrade;
        uint16 bonusAPY;
        uint amountLent;
        uint startPeriod;
        uint endPeriod;
    }

    function setMinimumDeposit(uint _minimumDeposit) external;

    function newRound(
        address lender,
        uint amount_,
        uint16 bonusAPY_,
        uint8 tenure_,
        bool paidTrade_
    ) external;

    function withdraw(address lender, uint roundId) external;

    function getRound(address lender, uint roundId)
        external
        view
        returns (Round memory);

    function getNumberOfRounds(address user) external view returns (uint);

    function getAmountLent(address lender) external view returns (uint);

    function stableRewardOf(address lender, uint roundId)
        external
        view
        returns (uint);


    function bonusRewardOf(address lender, uint roundId)
        external
        view
        returns (uint);

    /**
     * @dev Emitted when `amount` tokens are deposited into a pool by generating a new Round
     */
    event Deposit(address indexed owner, uint indexed roundId, uint amount);

    /**
     * @dev Emitted when user withdraw initial `amount` lent on a specific round
     */
    event Withdraw(address indexed owner, uint indexed roundId, uint amount);

    /**
     * @dev Emitted when `lender` claim rewards in Stable coin for a specific round
     */
    event ClaimStable(address indexed lender, uint indexed roundId, uint amount);

    /**
     * @dev Emitted when `lender` claim rewards in Trade token for a specific round
     */
    event ClaimTrade(address indexed lender, uint indexed roundId, uint amount);

    /**
    * @dev Emitted when Stable coin are swapped into Trade token
     */
    event Swapped(uint amountStable, uint amountTrade);
}
