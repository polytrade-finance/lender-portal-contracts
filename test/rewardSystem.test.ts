// import { expect } from "chai";
// import { ethers } from "hardhat";
// import {
//   RewardSystem__factory,
//   RewardSystem,
//   Token__factory,
// } from "../typechain";
// import { increaseTime, n18, ONE_DAY } from "./helpers";
// import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
// import { formatEther, formatUnits } from "ethers/lib/utils";
//
// describe("LenderPool", function () {
//   let rewardSystem: RewardSystem;
//   let RewardSystem: RewardSystem__factory;
//   let accounts: SignerWithAddress[];
//   let addresses: string[];
//
//   before(async () => {
//     accounts = await ethers.getSigners();
//     addresses = accounts.map((account: SignerWithAddress) => account.address);
//   });
//
//   it("Should return the RewardSystem once it's deployed", async function () {
//     RewardSystem = await ethers.getContractFactory("RewardSystem");
//     rewardSystem = await RewardSystem.deploy();
//     await rewardSystem.deployed();
//     expect(
//       await ethers.provider.getCode(rewardSystem.address)
//     ).to.be.length.above(100);
//   });
//
//   it("Should return the price of WMATIC/TRADE", async () => {
//     // console.log(formatEther(await rewardSystem.getTokenPrice(100)));
//     // console.log(formatEther(await rewardSystem.getTradePrice(1)));
//     let test = await rewardSystem.getAmountTradeWithMATIC(1);
//     console.log("1", formatEther(test));
//
//     test = await rewardSystem.getAmountTradeWithMATIC(10);
//     console.log("10", formatEther(test));
//
//     test = await rewardSystem.getAmountTradeWithMATIC(100);
//     console.log(100, formatEther(test));
//
//     test = await rewardSystem.getAmountTradeWithMATIC(1000);
//     console.log(1000, formatEther(test));
//
//     test = await rewardSystem.getAmountTradeWithMATIC("10000");
//     console.log("10000", formatEther(test));
//
//     test = await rewardSystem.getAmountTradeWithMATIC("100000");
//     console.log("100000", formatEther(test));
//
//     test = await rewardSystem.getAmountTradeWithMATIC("1000000");
//     console.log("1000000", formatEther(test));
//
//     test = await rewardSystem.getAmountTradeWithMATIC("10000000");
//     console.log("10000000", formatEther(test));
//
//     test = await rewardSystem.getAmountTradeWithMATIC("100000000");
//     console.log("100000000", formatEther(test));
//
//     test = await rewardSystem.getAmountTradeWithMATIC("1000000000");
//     console.log("1000000000", formatEther(test));
//
//     test = await rewardSystem.getAmountTradeWithMATIC("10000000000");
//     console.log("10000000000", formatEther(test));
//
//     test = await rewardSystem.getAmountTradeWithMATIC("100000000000");
//     console.log("100000000000", formatEther(test));
//
//     test = await rewardSystem.getAmountTradeWithMATIC("1000000000000");
//     console.log("1000000000000", formatEther(test));
//
//     test = await rewardSystem.getAmountTradeWithMATIC("10000000000000");
//     console.log("10000000000000", formatEther(test));
//
//     // const test2 = await rewardSystem.getAmountMATICWithUSDT(n18("100"));
//
//     // console.log("MATIC/USDT", formatUnits(test2, "6"));
//
//     // console.log("+", test[1].toString());
//     // console.log(formatEther(test[2]));
//   });
// });
