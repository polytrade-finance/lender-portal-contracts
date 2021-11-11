import { expect } from "chai";
import { ethers } from "hardhat";
import {
  LenderPool,
  LenderPool__factory,
  Token,
  Token__factory,
} from "../typechain";
import { increaseTime, n18, ONE_DAY } from "./helpers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

describe("LenderPool", function () {
  let lenderPool: LenderPool;
  let LenderPool: LenderPool__factory;
  let token: Token;
  let Token: Token__factory;
  let accounts: SignerWithAddress[];
  let addresses: string[];

  before(async () => {
    accounts = await ethers.getSigners();
    addresses = accounts.map((account: SignerWithAddress) => account.address);
  });

  it("Should return the Token once it's deployed", async function () {
    Token = await ethers.getContractFactory("Token");
    token = await Token.deploy("Tether", "USDT", n18("1000000000"));
    await token.deployed();
    expect(await ethers.provider.getCode(token.address)).to.be.length.above(
      100
    );
  });

  it("Should return the LenderPool once it's deployed", async function () {
    LenderPool = await ethers.getContractFactory("LenderPool");
    lenderPool = await LenderPool.deploy(token.address, "500", "500", 20);
    await lenderPool.deployed();
    expect(
      await ethers.provider.getCode(lenderPool.address)
    ).to.be.length.above(100);
  });

  it("Should set a new minimumDeposit", async () => {
    expect(await lenderPool.minimumDeposit()).to.equal(n18("0"));
    await lenderPool.setMinimumDeposit(n18("100"));
    expect(await lenderPool.minimumDeposit()).to.equal(n18("100"));
  });

  it("Should fail deposit if amount lower than minimumDeposit ", async () => {
    await token.approve(lenderPool.address, n18("10"));
    await expect(lenderPool.deposit(n18("10"))).to.revertedWith(
      "amount lower than minimumDeposit"
    );
  });

  it("Should set minimumDeposit to 0", async () => {
    await lenderPool.setMinimumDeposit(n18("0"));
  });

  it("Should deposit 10 times with 10 different users at different intervals", async () => {
    const amount = n18("1000000");
    for (let i = 1; i <= 10; i++) {
      await token.transfer(addresses[i], amount);
      expect(await token.balanceOf(addresses[i])).to.equal(amount);
      await token.connect(accounts[i]).approve(lenderPool.address, amount);
      await lenderPool.connect(accounts[i]).deposit(amount);
      expect(await lenderPool.getAmountLent(addresses[i])).to.equal(amount);
      await increaseTime(ONE_DAY);
    }
  });

  it("Should returns user1's rewards", async () => {
    expect(await lenderPool.rewardOf(addresses[1])).to.equal(n18("25000"));
  });

  it("Should returns user2's rewards", async () => {
    expect(await lenderPool.rewardOf(addresses[2])).to.equal(n18("22500"));
  });

  it("Should returns user3's rewards", async () => {
    expect(await lenderPool.rewardOf(addresses[3])).to.equal(n18("20000"));
  });

  it("Should returns user4's rewards", async () => {
    expect(await lenderPool.rewardOf(addresses[4])).to.equal(n18("17500"));
  });

  it("Should returns user5's rewards", async () => {
    expect(await lenderPool.rewardOf(addresses[5])).to.equal(n18("15000"));
  });

  it("Should returns user6's rewards", async () => {
    expect(await lenderPool.rewardOf(addresses[6])).to.equal(n18("12500"));
  });

  it("Should returns user7's rewards", async () => {
    expect(await lenderPool.rewardOf(addresses[7])).to.equal(n18("10000"));
  });

  it("Should returns user8's rewards", async () => {
    expect(await lenderPool.rewardOf(addresses[8])).to.equal(n18("7500"));
  });

  it("Should returns user9's rewards", async () => {
    expect(await lenderPool.rewardOf(addresses[9])).to.equal(n18("5000"));
  });

  it("Should returns user10's rewards", async () => {
    expect(await lenderPool.rewardOf(addresses[10])).to.equal(n18("2500"));
  });

  it("Should deposit again 10 times", async () => {
    const amount = n18("0.0000000000000001");
    for (let i = 1; i <= 10; i++) {
      await token.transfer(addresses[i], amount);
      expect(await token.balanceOf(addresses[i])).to.equal(amount);
      await token.connect(accounts[i]).approve(lenderPool.address, amount);
      await lenderPool.connect(accounts[i]).deposit(amount);
    }
    for (let i = 0; i <= 7; i++) {
      await increaseTime(ONE_DAY);
    }

    for (let i = 1; i <= 10; i++) {
      console.log((await lenderPool.rewardOf(addresses[i])).toString());
    }
  });
});
