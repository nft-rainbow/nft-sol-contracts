import { conflux } from "hardhat";
import { deploy } from "./lib/deploy";

async function main() {
  // @ts-ignore
  const { address } = (await conflux.getSigners())[0];
  const easynft = await deploy("ERC721NFT", address);
  console.log("ERC721NFT deployed to:", easynft.contractCreated);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
