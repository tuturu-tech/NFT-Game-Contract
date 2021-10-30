const { expect } = require("chai");
const {
  isCallTrace,
} = require("hardhat/internal/hardhat-network/stack-traces/message-trace");

describe("MyEpicGame contract", function () {
  let myEpicGame;
  let gameContract;
  let owner;
  let addr1;
  let addr2;
  let addrs;

  beforeEach(async function () {
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    gameContract = await ethers.getContractFactory("MyEpicGame");

    myEpicGame = await gameContract.deploy(
      ["Rocket", "Fireball", "Snowball"],
      [
        "QmVwDvtD5QcGfcs3U4VkzrPjWJQWhm5a9Hg8CfyQ7f91C6", // Images
        "QmV81DCEsj2c1TnNSsCeitfiDsv4M9gR1MzQHY5iK6QBRa",
        "QmfMpiW8hDd581CGcPkGAfaqX7wnJUbH3wXpawCbfchnAL",
      ],
      [100, 200, 300],
      [100, 50, 25],
      "Schwab", // Boss name
      "QmbTNQLhy67GWy42UtYgxr9JJkKWitufonrEbz15VsXMDE", // Boss image
      10000, // Boss hp
      50 // Boss attack damage
    );

    await myEpicGame.deployed();
  });

  describe("Deployment", async function () {
    it("Should set the right owner", async function () {
      expect(await myEpicGame.owner()).to.equal(owner.address);
    });

    it("Should have tokenId set to 1", async function () {
      expect(await myEpicGame._tokenIds()).to.equal(1);
    });

    it("Should initialize three Spell choices", async function () {
      const defSpells = await myEpicGame.defaultSpells;
      expect().to.equal(3);
    });
  });
});
