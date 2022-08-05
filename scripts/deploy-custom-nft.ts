import { conflux } from "hardhat";

async function main() {
  // @ts-ignore
  const { address } = (await conflux.getSigners())[0];

  // deploy by factory
  // @ts-ignore
  const factory = await conflux.getContractAt(
    "NFTContractFactory",
    "cfxtest:acbjznfws0ku06capkz82gam4jnvuv9j6avg9jxfm3"
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
