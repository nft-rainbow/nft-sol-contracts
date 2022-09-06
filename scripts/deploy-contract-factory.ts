import { deploy, deployWithLibs } from "./lib/deploy";
// eslint-disable-next-line import/no-duplicates
import { network } from "hardhat";
// @ts-ignore
// eslint-disable-next-line import/no-duplicates
import { conflux } from "hardhat";

async function main() {
  // @ts-ignore
  const accounts = await conflux.getSigners();

  console.log("Start deploy nft factory in proxy mode");
  const nftFactoryProxyAddress: { [networkName: string]: string | undefined } = {
    // "cfxtest": "cfxtest:acayzaxxu34gv7nr2u8upj52fbuyhbsf06e2n1rjtb"
  }
  // @ts-ignore
  const factoryTemplate = await deploy("NFTContractFactory");
  console.log("Deployed factory template", factoryTemplate.contractCreated);

  let proxy: any
  if (nftFactoryProxyAddress[network.name] === undefined) {
    proxy = await deploy("Proxy1967", factoryTemplate.contractCreated);
    // @ts-ignore
    proxy = await conflux.getContractAt("Proxy1967", proxy.contractCreated);
    console.log("Proxy deployed to %s, use NFTContractFactory template address %s", proxy.address, factoryTemplate.contractCreated);
  } else {
    // @ts-ignore
    proxy = await conflux.getContractAt("Proxy1967", nftFactoryProxyAddress[network.name]);
    await proxy.upgradeTo(factoryTemplate.contractCreated)
      .sendTransaction({
        from: accounts[0].address,
      })
      .executed();
    console.log("Upgrad NFTContractFactory template address %s", factoryTemplate.contractCreated);
  }

  const erc1155Template = await deployErc1155custom()
  const erc721Template = await deployErc721custom()
  console.log("Deployed erc721Template %s, erc1155Template %s", erc721Template.contractCreated, erc1155Template.contractCreated);
  // @ts-ignore
  const factory = await conflux.getContractAt("NFTContractFactory", proxy.address)
  await factory.updateNftTemplates(erc721Template.contractCreated, erc1155Template.contractCreated)
    .sendTransaction({
      from: accounts[0].address,
    })
    .executed();
  console.log("Initialize nft templates to:", erc721Template.contractCreated, erc1155Template.contractCreated);
}

async function deployErc1155custom(): Promise<{ contractCreated: string }> {
  const stringUtils = await deploy("StringUtils");
  // @ts-ignore
  const impl = await deployWithLibs("ERC1155NFTCustom", {
    libraries: {
      StringUtils: stringUtils.contractCreated,
    }
  });
  // impl.address = impl.contractCreated;
  return impl
}

async function deployErc721custom(): Promise<{ contractCreated: string }> {
  const stringUtils = await deploy("StringUtils");
  // @ts-ignore
  const impl = await deployWithLibs("ERC721NFTCustom", {
    libraries: {
      StringUtils: stringUtils.contractCreated,
    }
  });
  // impl.address = impl.contractCreated;
  return impl
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
