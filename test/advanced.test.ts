import { expect } from "chai";
import { ethers } from "hardhat";

// eslint-disable-next-line node/no-missing-import
import { increaseTime, n6, ONE_DAY } from "./helpers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import {
  LenderPool,
  LenderPool__factory,
  RewardSystem,
  RewardSystem__factory,
  Token,
  Token__factory,
  // eslint-disable-next-line node/no-missing-import
} from "../typechain";
import { BigNumber } from "ethers";

describe("LenderPool", function () {
  let lenderPool1: LenderPool;
  let lenderPool2: LenderPool;
  // eslint-disable-next-line camelcase
  let LenderPoolFactory: LenderPool__factory;
  let tokenContract: Token;
  let TokenFactory: Token__factory;
  let accounts: SignerWithAddress[];
  let addresses: string[];
  let rewardSystemContract: RewardSystem;
  let RewardSystemFactory: RewardSystem__factory;

  before(async () => {
    accounts = await ethers.getSigners();
    addresses = accounts.map((account: SignerWithAddress) => account.address);
  });

  it("Should return the Token once it's deployed", async function () {
    TokenFactory = await ethers.getContractFactory("Token");
    tokenContract = await TokenFactory.deploy(
      "Tether",
      "USDT",
      n6("1000000000")
    );
    await tokenContract.deployed();
    expect(
      await ethers.provider.getCode(tokenContract.address)
    ).to.be.length.above(100);
  });

  it("Should return the RewardSystem once it's deployed", async function () {
    RewardSystemFactory = await ethers.getContractFactory("RewardSystem");
    rewardSystemContract = await RewardSystemFactory.deploy();
    await rewardSystemContract.deployed();
    expect(
      await ethers.provider.getCode(rewardSystemContract.address)
    ).to.be.length.above(100);
  });

  it("Should distribute USDT to 10 different addresses", async () => {
    const amount = n6("10000");
    for (let i = 1; i <= 10; i++) {
      await tokenContract.transfer(addresses[i], amount);
    }
  });

  describe("Pool - 1", () => {
    it("Should return the LenderPool once it's deployed", async function () {
      LenderPoolFactory = await ethers.getContractFactory("LenderPool");
      lenderPool1 = await LenderPoolFactory.deploy(
        tokenContract.address,
        "500"
      );
      await lenderPool1.deployed();
      expect(
        await ethers.provider.getCode(lenderPool1.address)
      ).to.be.length.above(100);
    });

    it("Should set the rewardSystem contract", async () => {
      await lenderPool1.setRewardSystemContract(rewardSystemContract.address);
    });

    it("Should run new Rounds for user0", async () => {
      await tokenContract.approve(
        lenderPool1.address,
        ethers.constants.MaxUint256
      );
      await lenderPool1.newRound(n6("1000"), "1000", 30, true);
      await lenderPool1.newRound(n6("1100"), "1100", 31, false);
      await lenderPool1.newRound(n6("1200"), "1200", 32, true);
      await lenderPool1.newRound(n6("1300"), "1300", 33, false);
    });

    it.skip("Should return 0", async () => {
      const rewardBefore = await lenderPool1.roundRewardOf(0, addresses[0]);
      expect(rewardBefore).to.equal(0);
    });

    it("Should get round 0 from user0", async () => {
      const round = await lenderPool1.getRound(0, addresses[0]);
      console.log(round.toString());
    });

    it("Should get all rounds for user0", async () => {
      const count = await lenderPool1.getNumberOfRounds(addresses[0]);
      for (let i = BigNumber.from(0); i < count; i = i.add(1)) {
        const round = await lenderPool1.getRound(i, addresses[0]);
        console.log(round.toString());
      }
    });

    it("Should return stable rewards for user0 for round0 at the endPeriod", async () => {
      await increaseTime(ONE_DAY * 31);
      const rewardAfter = await lenderPool1.roundRewardOf(0, addresses[0]);
      expect(rewardAfter).to.equal(n6("4.109589"));
    });

    it("Should return bonus rewards for user0 for round0 at the endPeriod", async () => {
      const bonusRewardAfter = await lenderPool1.roundTradeRewardOf(
        0,
        addresses[0]
      );
      expect(bonusRewardAfter).to.equal(n6("8.219178"));
    });

    it("Should run new Round for user1", async () => {
      await tokenContract
        .connect(accounts[1])
        .approve(lenderPool1.address, ethers.constants.MaxUint256);
      await lenderPool1
        .connect(accounts[1])
        .newRound(n6("100"), "800", 30, true);
    });

    it("Should return stable rewards for user1 for round0 at the endPeriod", async () => {
      const rewardBefore = await lenderPool1.roundRewardOf(0, addresses[1]);
      expect(rewardBefore).to.equal(0);
      await increaseTime(ONE_DAY * 31);
      const rewardAfter = await lenderPool1.roundRewardOf(0, addresses[1]);
      expect(rewardAfter).to.equal(n6("0.410958"));
    });

    it("Should return bonus rewards for user1 for round0 at the endPeriod", async () => {
      const bonusRewardAfter = await lenderPool1.roundTradeRewardOf(
        0,
        addresses[1]
      );
      expect(bonusRewardAfter).to.equal(n6("0.657534"));
    });

    it("Should return rewards of Trade", async () => {
      const tradeRewards0 = await lenderPool1.amountTradeRewardOf(
        0,
        addresses[0]
      );
      console.log(tradeRewards0.toString());

      const tradeRewards1 = await lenderPool1.amountTradeRewardOf(
        0,
        addresses[1]
      );
      console.log(tradeRewards1.toString());
    });
  });

  describe("Pool - 2", () => {
    it("Should return the LenderPool once it's deployed", async function () {
      LenderPoolFactory = await ethers.getContractFactory("LenderPool");
      lenderPool2 = await LenderPoolFactory.deploy(
        tokenContract.address,
        "800"
      );
      await lenderPool2.deployed();
      expect(
        await ethers.provider.getCode(lenderPool2.address)
      ).to.be.length.above(100);
    });

    it("Should set the rewardSystem contract", async () => {
      await lenderPool2.setRewardSystemContract(rewardSystemContract.address);
    });

    it("Should run new Rounds for user0", async () => {
      await tokenContract.approve(
        lenderPool2.address,
        ethers.constants.MaxUint256
      );
      await lenderPool2.newRound(n6("5000"), "700", 60, true);
    });

    it("Should get round 0 from user0", async () => {
      const round = await lenderPool2.getRound(0, addresses[0]);
      console.log(round.toString());
    });

    it("Should return stable rewards for user0 for round0 at the endPeriod", async () => {
      await increaseTime(ONE_DAY * 60);
      const rewardAfter = await lenderPool2.roundRewardOf(0, addresses[0]);
      expect(rewardAfter).to.equal(n6("65.753424"));
    });

    it("Should return bonus rewards for user0 for round0 at the endPeriod", async () => {
      const bonusRewardAfter = await lenderPool2.roundTradeRewardOf(
        0,
        addresses[0]
      );
      expect(bonusRewardAfter).to.equal(n6("57.534246"));
    });
  });
});
