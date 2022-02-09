# lender-portal-contracts (beta)
[![Documentation Status](https://readthedocs.org/projects/smart-contracts-for-testing/badge/?version=latest)](https://smart-contracts-for-testing.readthedocs.io/en/latest/?badge=latest)(add link to docs)

### Introduction
Lender portal contract help lenders to interact with polytrade.finance contracts. They can join a lending pool and start lending. 
## Table of content
1. [ Guide for lenders  ](#guide_for_lenders)
2. [SAMPLE CODE ](#sample_code)
3. [Project status](#project_status)
4. [Technologies](#technologies)
5. [Routers](#routers)
6. [License](#license)

<a name="guide_for_lenders"></a>
## 1. Guide for lenders 

    
    1. Each lender has to interact with "LenderPool" Contract to lend money. This can be done using some UI/another smart  contract/ some script.
    2. Lender will check Fixed Annual Percentage Yield and tenure of loan period, minimum deposit amount for a different lending pools and choose lending pool of their choice. 
    3. Apart from fixed APY lenders will also get bonus APY which will be set at the time of lending. bonus APY is calculated offchain only Owner is able to  call this function.
    4. Lenders can give out money in several rounds also. However for each round bonus APY and fixed APY may be different.
    5. Lenders can withdraw the amount for a particular round if the tenure of that round is over.
    6. newRound and withdraw can be called by only owner. So user have to approve the transfer for this contract address for new round.  There must be some interface(UI) to tell polytrade that user want to lend or withdraw. Then it will called later by the owner.


<a name="sample_code"></a>
 ## 2. SAMPLE CODE 
 
    import './LendingPool.sol'; 
    LendingPool public obj ; 
    constructor(address _address){ 
    obj = LendingPool(_address); }
    uint16 public tenure = obj.tenure();
    uint16 public stableAPY = obj.stableAPY();
    uint public minimumDeposit = obj.minimumDeposit();


<a name = "project_status"></a>
## 3. Project status
This smart contract is the first version for lending protocol. There are plans to make this project more decentralized.



<a name="technologies"></a>
## 4. Technologies
Hardhat, Ethers, Solidity
<a name =  "routers"></a>
## 5. Routers 
IUniswapV2Router(0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff)

<a name="license"></a>
## 6. License 
