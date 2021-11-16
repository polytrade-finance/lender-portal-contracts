import { expect } from "chai";
import { ethers } from "hardhat";

// eslint-disable-next-line node/no-missing-import
import { increaseTime, n18, n6, ONE_DAY } from "./helpers";
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
import { formatEther, formatUnits } from "ethers/lib/utils";

describe("LenderPool", function () {
  let lenderPoolContract: LenderPool;
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
      n18("1000000000")
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

  it("Should return the LenderPool once it's deployed", async function () {
    LenderPoolFactory = await ethers.getContractFactory("LenderPool");
    lenderPoolContract = await LenderPoolFactory.deploy(
      tokenContract.address,
      "500",
      20
    );
    await lenderPoolContract.deployed();
    expect(
      await ethers.provider.getCode(lenderPoolContract.address)
    ).to.be.length.above(100);
  });

  it("Should set the rewardSystem contract", async () => {
    await lenderPoolContract.setRewardSystemContract(
      rewardSystemContract.address
    );
  });

  it("Should set a new minimumDeposit", async () => {
    expect(await lenderPoolContract.minimumDeposit()).to.equal(n6("0"));
    await lenderPoolContract.setMinimumDeposit(n6("100"));
    expect(await lenderPoolContract.minimumDeposit()).to.equal(n6("100"));
  });

  it("Should fail deposit if amount lower than minimumDeposit ", async () => {
    await tokenContract.approve(lenderPoolContract.address, n6("10"));
    await expect(lenderPoolContract.deposit(n6("10"))).to.revertedWith(
      "amount lower than minimumDeposit"
    );
  });

  it("Should set minimumDeposit to 0", async () => {
    await lenderPoolContract.setMinimumDeposit(n6("0"));
  });

  it("Should deposit 10 times with 10 different users at different intervals", async () => {
    const amount = n6("1000000");
    for (let i = 1; i <= 10; i++) {
      await tokenContract.transfer(addresses[i], amount);
      expect(await tokenContract.balanceOf(addresses[i])).to.equal(amount);
      await tokenContract
        .connect(accounts[i])
        .approve(lenderPoolContract.address, amount);
      await lenderPoolContract.connect(accounts[i]).deposit(amount);
      expect(await lenderPoolContract.getAmountLent(addresses[i])).to.equal(
        amount
      );
      await increaseTime(ONE_DAY);
    }
  });

  it("Should set BonusAPY for each user", async () => {
    for (let i = 1; i <= 10; i++) {
      await rewardSystemContract
        .connect(accounts[i])
        .setUserBonusAPY(addresses[i], "100");
      expect(
        await rewardSystemContract
          .connect(accounts[i])
          .getUserBonusAPY(addresses[i])
      ).to.equal(100);
    }

    for (let i = 1; i <= 10; i++) {
      const amountLent = await lenderPoolContract.getAmountLent(addresses[i]);
      const stableRewards = await lenderPoolContract.rewardOf(addresses[i]);
      const bonusRewards = await lenderPoolContract.bonusRewardOf(addresses[i]);
      console.log(
        `
      ---After10Days
      User${i}
      amountLent=${formatUnits(amountLent, "6")}
      stableRewards=${formatUnits(stableRewards, "6")}
      bonusRewards=${formatEther(bonusRewards)}
      ---After10Days
      
      `
      );
      console.log(formatEther(stableRewards.toString()));
      console.log(formatEther(bonusRewards.toString()));
    }
  });

  it("Should returns user1's rewards", async () => {
    expect(await lenderPoolContract.rewardOf(addresses[1])).to.equal(
      n6("25000")
    );
    const bonus = await lenderPoolContract.bonusRewardOf(addresses[1]);
    console.log(formatEther(bonus.toString()));
  });

  it("Should returns user2's rewards", async () => {
    expect(await lenderPoolContract.rewardOf(addresses[2])).to.equal(
      n6("22500")
    );
  });

  it("Should returns user3's rewards", async () => {
    expect(await lenderPoolContract.rewardOf(addresses[3])).to.equal(
      n6("20000")
    );
  });

  it("Should returns user4's rewards", async () => {
    expect(await lenderPoolContract.rewardOf(addresses[4])).to.equal(
      n6("17500")
    );
  });

  it("Should returns user5's rewards", async () => {
    expect(await lenderPoolContract.rewardOf(addresses[5])).to.equal(
      n6("15000")
    );
  });

  it("Should returns user6's rewards", async () => {
    expect(await lenderPoolContract.rewardOf(addresses[6])).to.equal(
      n6("12500")
    );
  });

  it("Should returns user7's rewards", async () => {
    expect(await lenderPoolContract.rewardOf(addresses[7])).to.equal(
      n6("10000")
    );
  });

  it("Should returns user8's rewards", async () => {
    expect(await lenderPoolContract.rewardOf(addresses[8])).to.equal(
      n6("7500")
    );
  });

  it("Should returns user9's rewards", async () => {
    expect(await lenderPoolContract.rewardOf(addresses[9])).to.equal(
      n6("5000")
    );
  });

  it("Should returns user10's rewards", async () => {
    expect(await lenderPoolContract.rewardOf(addresses[10])).to.equal(
      n6("2500")
    );
  });

  it("Should deposit again 10 times", async () => {
    for (let i = 0; i <= 7; i++) {
      await increaseTime(ONE_DAY);

      const amountLent = await lenderPoolContract.getAmountLent(addresses[i]);
      const stableRewards = await lenderPoolContract.rewardOf(addresses[i]);
      const bonusRewards = await lenderPoolContract.bonusRewardOf(addresses[i]);
      console.log(
        `
        ---after17days
        User${i}
        amountLent=${formatUnits(amountLent, "6")}
        stableRewards=${formatUnits(stableRewards, "6")}
        bonusRewards=${formatEther(bonusRewards)}
        ---after17days
        
        `
      );
    }

    const amount = n6("0.000001");
    for (let i = 1; i <= 10; i++) {
      await tokenContract.transfer(addresses[i], amount);
      expect(await tokenContract.balanceOf(addresses[i])).to.equal(amount);
      await tokenContract
        .connect(accounts[i])
        .approve(lenderPoolContract.address, amount);
      await lenderPoolContract.connect(accounts[i]).deposit(amount);
    }

    for (let i = 0; i <= 7; i++) {
      await increaseTime(ONE_DAY);

      const amountLent = await lenderPoolContract.getAmountLent(addresses[i]);
      const stableRewards = await lenderPoolContract.rewardOf(addresses[i]);
      const bonusRewards = await lenderPoolContract.bonusRewardOf(addresses[i]);
      console.log(
        `
        ---END
        User${i}
        amountLent=${formatUnits(amountLent, "6")}
        stableRewards=${formatUnits(stableRewards, "6")}
        bonusRewards=${formatEther(bonusRewards)}
        ---END`
      );
    }
  });
});
