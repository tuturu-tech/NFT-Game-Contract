const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory("MyEpicGame");
  const gameContract = await gameContractFactory.deploy(
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
  await gameContract.deployed();
  console.log("contract deployed to:", gameContract.address);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();
