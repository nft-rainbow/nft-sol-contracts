import { deploy } from "./lib/deploy";

async function main() {
  // direct deploy
  // @ts-ignore
  const customnft = await deploy("NFTContractFactory");
  console.log("NFTContractFactory deployed to:", customnft.contractCreated);

  // deploy by factory
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
