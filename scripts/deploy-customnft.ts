import { conflux } from "hardhat";

async function main() {
  // @ts-ignore
  const { address } = (await conflux.getSigners())[0];

  // deploy by factory
  // @ts-ignore
  const factory = await conflux.getContractAt(
    "NFTContractFactory",
    "cfxtest:acamkyztefkzz9prr3jd53kgcweaabdaw6e67hnw4r"
  );

  const customnft = await factory
    .newERC721Custom("abc", "ABC", address)
    .sendTransaction({
      from: address,
    })
    .executed();
  console.log("ERC721NFTCustom deployed to:", customnft);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
