import { deploy } from "./lib/deploy";

async function main() {
  // @ts-ignore
  const customnft = await deploy("NFTContractFactory");
  console.log("NFTContractFactory deployed to:", customnft.contractCreated);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
