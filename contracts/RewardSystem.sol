pragma solidity ^0.8.10;

import "hardhat/console.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract RewardSystem {
    address DAI = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063;
    address USDT = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;
    address WMATIC = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
    address TRADE = 0x692AC1e363ae34b6B489148152b12e2785a3d8d6;
    address router = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;

    mapping(address => uint16) private _userBonusAPY;

    function getAmountOfTrade(uint256 amount) external view returns (uint256) {
        address[] memory path = new address[](3);
        path[0] = USDT;
        path[1] = WMATIC;
        path[2] = TRADE;
        return IUniswapV2Router(router).getAmountsOut(amount, path)[2];
    }

    function getAmountTradeForDAI(uint amount) external view returns (uint) {
        address[] memory path = new address[](3);
        path[0] = DAI;
        path[1] = WMATIC;
        path[2] = TRADE;
        return IUniswapV2Router(router).getAmountsOut(amount, path)[2];
    }

    function setUserBonusAPY(address lender, uint16 bonusAPY) external {
        _userBonusAPY[lender] = bonusAPY;
    }

    function getUserBonusAPY(address lender) external view returns (uint16) {
        return _userBonusAPY[lender];
    }
}
