require("@nomiclabs/hardhat-waffle");
require("dotenv").config();

module.exports = {
  solidity: "0.8.0",
  defaultNetwork: "hardhat",
  networks: {
    rinkeby: {
      url: process.env.ALCHEMY_RINKEBY_KEY,
      accounts: [process.env.TESTNET_PRIVATE_KEY],
    },
  },
};
