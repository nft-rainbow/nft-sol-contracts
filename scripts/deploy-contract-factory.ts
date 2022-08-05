import { deploy } from "./lib/deploy";

async function main() {
  // direct deploy
  // @ts-ignore
  const factoryImpl = await deploy("NFTContractFactory");
  // console.log("NFTContractFactory deployed to:", factoryImpl.contractCreated);

  const nftFactory = await deploy("Proxy1967", factoryImpl.contractCreated);
  console.log("NFTContractFactory deployed to:", nftFactory.contractCreated);
  // deploy by factory
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
