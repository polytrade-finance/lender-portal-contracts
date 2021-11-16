import { expect } from "chai";
import { ethers } from "hardhat";

import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import {
  LenderPool,
  LenderPool__factory,
  LenderPoolFactory,
  LenderPoolFactory__factory,
  Token,
  Token__factory,
  // eslint-disable-next-line node/no-missing-import
} from "../typechain";
// eslint-disable-next-line node/no-missing-import
import { n18 } from "./helpers";

describe("LenderPool", function () {
  let lenderPoolContract: LenderPool;
  // eslint-disable-next-line camelcase
  let tokenContract: Token;
  let TokenFactory: Token__factory;
  let accounts: SignerWithAddress[];
  // eslint-disable-next-line no-unused-vars
  let addresses: string[];
  let LenderProxyFactory: LenderPoolFactory__factory;
  let lenderPoolFactory: LenderPoolFactory;

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

  it("Should return the LenderPool once it's deployed", async function () {
    const LenderPoolFactory: LenderPool__factory =
      await ethers.getContractFactory("LenderPool");
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

  it("Should clone", async () => {
    LenderProxyFactory = await ethers.getContractFactory("LenderPoolFactory");
    lenderPoolFactory = await LenderProxyFactory.deploy(
      lenderPoolContract.address
    );

    await lenderPoolFactory.clonePool().then((tx) => tx.wait());
    console.log(
      await lenderPoolFactory.getDeterministicPoolAddress(
        ethers.constants.HashZero
      )
    );
    await lenderPoolFactory
      .cloneDeterministicPool(ethers.constants.HashZero)
      .then((tx) => tx.wait());

    await lenderPoolFactory.clonePool().then((tx) => tx.wait());
    console.log(
      await lenderPoolFactory.getDeterministicPoolAddress(
        ethers.constants.HashZero
      )
    );
    await lenderPoolFactory
      .cloneDeterministicPool(ethers.constants.HashZero)
      .then((tx) => tx.wait());
  });
});
