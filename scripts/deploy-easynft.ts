import { conflux } from "hardhat";

async function main() {
  // @ts-ignore
  const accounts = await conflux.getSigners();
  // We get the contract to deploy
  // @ts-ignore
  const ERC721NFT = await conflux.getContractFactory("ERC721NFT");
  const easynft = await ERC721NFT.constructor(accounts[0].address)
    .sendTransaction({
      from: accounts[0].address,
    })
    .executed();

  console.log("ERC721NFT deployed to:", easynft.contractCreated);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
