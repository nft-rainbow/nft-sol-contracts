import { deploy, deployWithLibs } from "./deploy";
import { network, conflux } from "hardhat";
import { nftFactoryProxyAddress } from "../../app.dev.config.json";
// import { conflux } from "hardhat";

async function deployOrUpdateNftFactoryTemplate() {
  // @ts-ignore
  const accounts = await conflux.getSigners();
  console.log("Start deploy NFTContractFactory in proxy mode");

  // @ts-ignore
  const factoryTemplate = await deploy("NFTContractFactory");
  console.log("Deployed NFTContractFactory template at %s", factoryTemplate.contractCreated);

  let proxy: any
  if ((nftFactoryProxyAddress as any)[network.name] === undefined) {
    proxy = await deploy("Proxy1967", factoryTemplate.contractCreated);
    // @ts-ignore
    proxy = await conflux.getContractAt("Proxy1967", proxy.contractCreated);
    (nftFactoryProxyAddress as any)[network.name] = proxy.address
    console.log("Proxy deployed at %s, use NFTContractFactory template address %s", proxy.address, factoryTemplate.contractCreated);
  } else {
    // @ts-ignore
    proxy = await conflux.getContractAt("Proxy1967", nftFactoryProxyAddress[network.name]);
    await proxy.upgradeTo(factoryTemplate.contractCreated)
      .sendTransaction({
        from: accounts[0].address,
      })
      .executed();
    console.log("Upgrade NFTContractFactory template address to %s", factoryTemplate.contractCreated);
  }

  await updateTemplates(true, true)
}

async function deployErc1155customTemplate(): Promise<{ contractCreated: string }> {
  const stringUtils = await deploy("StringUtils");
  // @ts-ignore
  const impl = await deployWithLibs("ERC1155NFTCustom", {
    libraries: {
      StringUtils: stringUtils.contractCreated,
    }
  });
  console.log("Deployed ERC1155NFTCustom template at %s", impl.contractCreated);
  return impl
}

async function deployErc721customTemplate(): Promise<{ contractCreated: string }> {
  const stringUtils = await deploy("StringUtils");
  // @ts-ignore
  const impl = await deployWithLibs("ERC721NFTCustom", {
    libraries: {
      StringUtils: stringUtils.contractCreated,
    }
  });
  console.log("Deployed ERC721NFTCustom template at %s", impl.contractCreated);
  return impl
}

async function updateTemplates(is721Custom: boolean, is1155Custom: boolean) {
  if(!is721Custom && !is1155Custom) {
    console.log("both are not need update")
    return
  }
  // @ts-ignore
  const accounts = await conflux.getSigners();
  console.log("Start update ERC721NFTCustom template: %s, ERC1155NFTCustom template: %s", is721Custom, is1155Custom);
  // @ts-ignore
  const proxy = await conflux.getContractAt("Proxy1967", nftFactoryProxyAddress[network.name]);
  // @ts-ignore
  const factory = await conflux.getContractAt("NFTContractFactory", proxy.address)

  const erc721TemplateAddr = is721Custom ? (await deployErc721customTemplate()).contractCreated : await factory.erc721CustomImpl();
  const erc1155TemplateAddr = is1155Custom ? (await deployErc1155customTemplate()).contractCreated : await factory.erc1155CustomImpl();

  await factory.updateNftTemplates(erc721TemplateAddr, erc1155TemplateAddr).sendTransaction({from: accounts[0].address,}).executed();

  console.log("Updated nft templates to:", erc721TemplateAddr, erc1155TemplateAddr);
}

// // We recommend this pattern to be able to use async/await everywhere
// // and properly handle errors.
// deployOrUpdateNftFactoryTemplate().catch((error) => {
//   console.error(error);
//   process.exitCode = 1;
// });
export { deployOrUpdateNftFactoryTemplate, updateTemplates }