// import { Signer } from "ethers";
// @ts-ignore
import { conflux } from "hardhat";
// @ts-ignore
import { FactoryOptions} from "hardhat-conflux"
import { getNftFactoryProxyAddress, setNftFactoryProxyAddress, getStringUtilsAddress, setStringUtilsAddress } from "./config"


async function deploy(contractName: string, ...args: any[]): Promise<{contractCreated: string}> {
  return deployWithLibs(contractName, null, ...args);
}

async function deployAndInitialize(contractName: string, ...args: any[]): Promise<{contractCreated: string}> {
  const stringUtils = await deploy("StringUtils");
  const deployReceipt = await deployWithLibs(contractName, {
    libraries: {
      StringUtils: stringUtils.contractCreated
    }
  });
  const contractAddr = deployReceipt.contractCreated;
  // @ts-ignore
  const contract = await conflux.getContractAt(contractName, contractAddr);
  // @ts-ignore
  const accounts = await conflux.getSigners();
  await contract.initialize(...args).sendTransaction({
    from: accounts[0].address,
  }).executed();
  return deployReceipt;
}

async function deployWithLibs(contractName: string, libs: FactoryOptions | null, ...args: any[]): Promise<{contractCreated: string}> {
  // @ts-ignore
  const accounts = await conflux.getSigners();
  // We get the contract to deploy
  // @ts-ignore
  const contract = libs === null ?
    // @ts-ignore
    await conflux.getContractFactory(contractName) :
    // @ts-ignore
    await conflux.getContractFactory(contractName, libs);
    
  const deployReceipt = await contract
    .constructor(...args)
    .sendTransaction({
      from: accounts[0].address,
    })
    .executed();
  console.log(`deployed ${contractName} to ${deployReceipt.contractCreated}`);
  return deployReceipt;
}

export { deploy, deployWithLibs, deployAndInitialize };