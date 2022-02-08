# lender-portal-contracts
[![Documentation Status](https://readthedocs.org/projects/smart-contracts-for-testing/badge/?version=latest)](https://smart-contracts-for-testing.readthedocs.io/en/latest/?badge=latest)

    # Guide for lenders
    
    1. Each lender has to interact with "LenderPool" Contract to lend money. This can be done using some UI/another smart  contract/ some script.
    2. Lender will check Fixed Annual Percentage Yield and tenure of loan period, minimum deposit amount for a different lending pools and choose lending pool of their choice. 
    3. Apart from fixed APY lenders will also get bonus APY which will be set at the time of lending. bonus APY is calculated offchain only Owner is able to  call this function.
    4. Lenders can give out money in several rounds also. However for each round bonus APY and fixed APY may be different.
    5. Lenders can withdraw the amount for a particular round if the tenure of that round is over.
    6. newRound and withdraw can be called by only owner. So user have to approve the transfer for this contract address for new round.  There must be some interface(UI) to tell polytrade that user want to lend or withdraw. Then it will called later by the owner.


 ## SAMPLE CODE 
### 
    import './LendingPool.sol'; 
    LendingPool public obj ; 
    constructor(address _address){ 
    obj = LendingPool(_address); }
    uint16 public tenure = obj.tenure();
    uint16 public stableAPY = obj.stableAPY();
    uint public minimumDeposit = obj.minimumDeposit();
    

# License 
