pragma solidity ^0.8.10;

import "hardhat/console.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract RewardSystem {

    IERC20Metadata USDT = IERC20Metadata(0xc2132D05D31c914a87C6611C10748AEb04B58e8F);
    IERC20Metadata WMATIC = IERC20Metadata(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270);
    IERC20Metadata tradeToken = IERC20Metadata(0x692AC1e363ae34b6B489148152b12e2785a3d8d6);
    IUniswapV2Router router = IUniswapV2Router(0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff);

    function getAmountOfTrade(uint amount) public view returns(uint) {
        address[] memory path = new address[](3);
        path[0] = address(USDT);
        path[1] = address(WMATIC);
        path[2] = address(tradeToken);
        return router.getAmountsOut(amount, path)[2];
    }
}
