import { conflux } from "hardhat";

async function deploy(contractName: string, ...args: any[]): Promise<any> {
  // @ts-ignore
  const accounts = await conflux.getSigners();
  // We get the contract to deploy
  // @ts-ignore
  const contract = await conflux.getContractFactory(contractName);
  const deployReceipt = await contract
    .constructor(...args)
    .sendTransaction({
      from: accounts[0].address,
    })
    .executed();
  return deployReceipt;
}

export { deploy };
