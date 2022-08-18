import * as dotenv from "dotenv";

import { HardhatUserConfig, task } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";
import "hardhat-conflux";
import { checkRole, tryMintTo } from "./tools/validate";

dotenv.config();

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  // @ts-ignore
  const accounts = await hre.network.config.accounts;
  console.log(accounts);
});

task("checkrole", "Check user if is the role")
  .addParam("address", "contract address")
  .addParam("role", "role name")
  .addParam("user", "user address")
  .setAction(async (taskArgs, hre) => {
    const ok = await checkRole(
      // @ts-ignore
      hre.network.config.url,
      taskArgs.address,
      taskArgs.role,
      taskArgs.user
    );
    console.log(
      `${taskArgs.user} has role ${taskArgs.role} of  ${taskArgs.address}: ${ok}`
    );
  });

task("tryMintTo", "Check if could mint to success")
  .addParam("address", "contract address")
  .addParam("user", "user address")
  .setAction(async (taskArgs, hre) => {
    await tryMintTo(
      // @ts-ignore
      hre.network.config.url,
      taskArgs.address,
      taskArgs.user
    );
    console.log(`${taskArgs.user} try mint ${taskArgs.address} ok`);
  });

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.4",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
},
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true,
    },
    cfxtest: {
      url: "https://test.confluxrpc.com",
      allowUnlimitedContractSize: true,
      chainId: 1,
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    cfx: {
      url: "https://main.confluxrpc.com",
      chainId: 1029,
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    ropsten: {
      url: process.env.ROPSTEN_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};

export default config;
