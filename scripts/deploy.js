const { ethers } = require("hardhat");

async function main() {
  // Replace with your token contract address
  const tokenAddress = "0xYourTokenContractAddressHere";

  const TimeVesting = await ethers.getContractFactory("TimeVesting");
  const timeVesting = await TimeVesting.deploy(tokenAddress);

  await timeVesting.deployed();

  console.log("TimeVesting contract deployed to:", timeVesting.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
