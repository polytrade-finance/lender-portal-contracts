//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./LenderPool.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "hardhat/console.sol";

contract LenderPoolFactory {
    using Clones for address;
    address lenderInstance;

    constructor(address lenderInstance_) {
        lenderInstance = lenderInstance_;
    }

    function clonePool() external returns (address) {
        address clonedPool = lenderInstance.clone();
        console.log("%s <<<", clonedPool);
        return clonedPool;
    }

    function getDeterministicPoolAddress(bytes32 salt)
        external
        view
        returns (address)
    {
        address clonedPool = lenderInstance.predictDeterministicAddress(
            salt,
            msg.sender
        );
        return clonedPool;
    }

    function cloneDeterministicPool(bytes32 salt) external returns (address) {
        address clonedPool = lenderInstance.cloneDeterministic(salt);
        console.log("%s <<<", clonedPool);
        return clonedPool;
    }
}
