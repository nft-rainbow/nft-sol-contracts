import { deploy, deployWithLibs } from "./deploy";
import { ethers, conflux } from "hardhat";
import { getNftFactoryProxyAddress, setNftFactoryProxyAddress, getStringUtilsAddress, setStringUtilsAddress } from "./config"

const provider = ethers.provider
provider.on('debug', (info) => {
    console.log(info.request);
    console.log(info.response);
});

async function deployErc1155customTemplate(): Promise<{ contractCreated: string }> {
  const stringUtilsAddr = getStringUtilsAddress()
  if (stringUtilsAddr === "") {
    const stringUtils = await deploy("StringUtils");
    console.log("Deployed stringUtils at %s", stringUtils.contractCreated);
    setStringUtilsAddress(stringUtils.contractCreated);
  }

  // console.log("Get stringUtils %s", getStringUtilsAddress());
  // @ts-ignore
  const impl = await deployWithLibs("ERC1155NFTCustom", {
    libraries: {
      StringUtils: getStringUtilsAddress()
    }
  });
  console.log("Deployed ERC1155NFTCustom template at %s", impl.contractCreated);
  return impl
}

async function deployErc721customTemplate(): Promise<{ contractCreated: string }> {
  const stringUtilsAddr = getStringUtilsAddress()
  if (stringUtilsAddr === "") {
    const stringUtils = await deploy("StringUtils");
    console.log("Deployed stringUtils at %s", stringUtils.contractCreated);
    setStringUtilsAddress(stringUtils.contractCreated);
  }
  // console.log("Get stringUtils %s", getStringUtilsAddress());
  // @ts-ignore
  const impl = await deployWithLibs("ERC721NFTCustom", {
    libraries: {
      StringUtils: getStringUtilsAddress(),
    }
  });
  console.log("Deployed ERC721NFTCustom template at %s", impl.contractCreated);
  return impl
}

export async function deployOrUpdateNftFactoryTemplate() {
  // @ts-ignore
  const accounts = await conflux.getSigners();
  console.log("Start deploy NFTContractFactory in proxy mode");

  // @ts-ignore
  const factoryTemplate = await deploy("NFTContractFactory");
  console.log("Deployed NFTContractFactory template at %s", factoryTemplate.contractCreated);

  let proxy: any
  if (getNftFactoryProxyAddress() === "") {
    proxy = await deploy("Proxy1967", factoryTemplate.contractCreated);
    // @ts-ignore
    proxy = await conflux.getContractAt("Proxy1967", proxy.contractCreated);
    setNftFactoryProxyAddress(proxy.address)
    console.log("Proxy deployed at %s, use NFTContractFactory template address %s", proxy.address, factoryTemplate.contractCreated);
  } else {
    // @ts-ignore
    proxy = await conflux.getContractAt("Proxy1967", getNftFactoryProxyAddress());
    await proxy.upgradeTo(factoryTemplate.contractCreated)
      .sendTransaction({
        from: accounts[0].address,
      })
      .executed();
    console.log("Upgrade NFTContractFactory template address to %s", factoryTemplate.contractCreated);
  }

  await updateTemplates(true, true)
}

export async function updateTemplates(is721Custom: boolean, is1155Custom: boolean) {
  if (!is721Custom && !is1155Custom) {
    console.log("both are not need update")
    return
  }
  // @ts-ignore
  const accounts = await conflux.getSigners();
  console.log("Start update ERC721NFTCustom template: %s, ERC1155NFTCustom template: %s", is721Custom, is1155Custom);
  // @ts-ignore
  const proxy = await conflux.getContractAt("Proxy1967", getNftFactoryProxyAddress());
  // @ts-ignore
  const factory = await conflux.getContractAt("NFTContractFactory", proxy.address)

  const erc721TemplateAddr = is721Custom ? (await deployErc721customTemplate()).contractCreated : await factory.erc721CustomImpl();
  const erc1155TemplateAddr = is1155Custom ? (await deployErc1155customTemplate()).contractCreated : await factory.erc1155CustomImpl();

  await factory.updateNftTemplates(erc721TemplateAddr, erc1155TemplateAddr).sendTransaction({ from: accounts[0].address, }).executed();

  console.log("Updated nft templates to:", erc721TemplateAddr, erc1155TemplateAddr);
}
