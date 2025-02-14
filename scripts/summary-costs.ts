// @ts-ignore
import { conflux } from "hardhat";
import { deployAndInitialize } from "./lib/deploy"

type DeployResult = {
    erc721NoEnum: string,
    erc1155NoEnum: string,
    erc721Enum: string,
    erc1155Enum: string,
}

class Action {
    contractType: string
    name: string
    hash: string
    gas: string
    collateral: string

    constructor(_contractType: string, _name: string, receipt: any) {
        this.contractType = _contractType
        this.name = _name
        this.gas = receipt.gasUsed
        this.collateral = receipt.storageCollateralized
        this.hash = receipt.transactionHash
    }
}

class Actions {
    value: Action[] = []
    push(v: Action) {
        console.log(v)
        this.value.push(v)
    }

    map(fn: any): any[] {
        return this.value.map(fn)
    }
}

async function deployContracts(): Promise<DeployResult> {
    // @ts-ignore
    const accounts = await conflux.getSigners();
    // @ts-ignore
    // const erc721 = await deployAndInitialize("ERC721NFTCustom");
    // console.log("Deployed ERC721 at %s", erc721.contractCreated);

    // // @ts-ignore
    // const erc1155 = await deployAndInitialize("ERC1155NFTCustom");
    // console.log("Deployed MYERC1155 at %s", erc1155.contractCreated);

    // @ts-ignore
    const erc721NoEnum = await deployAndInitialize("ERC721NFTCustomNoEnum", "ERC721NFTCustomNoEnum", "ERC721NoENUM", "", 0, "0x0000000000000000000000000000000000000000", [accounts[0].address], true, true, 0, true);
    // @ts-ignore
    const erc1155NoEnum = await deployAndInitialize("ERC1155NFTCustomNoEnum", "ERC1155NFTCustomNoEnum", "ERC1155NoENUM", "", 0, "0x0000000000000000000000000000000000000000", [accounts[0].address], true, true, true);
    // @ts-ignore
    const erc721Enum = await deployAndInitialize("ERC721NFTCustom", "ERC721NFTCustom", "ERC721ENUM", "", 0, "0x0000000000000000000000000000000000000000", [accounts[0].address], true, true, 0, true);
    // @ts-ignore
    const erc1155Enum = await deployAndInitialize("ERC1155NFTCustom", "ERC1155NFTCustom", "ERC1155ENUM", "", 0, "0x0000000000000000000000000000000000000000", [accounts[0].address], true, true, true);

    return {
        erc721NoEnum: erc721NoEnum.contractCreated,
        erc1155NoEnum: erc1155NoEnum.contractCreated,
        erc721Enum: erc721Enum.contractCreated,
        erc1155Enum: erc1155Enum.contractCreated
    }
}

async function summary() {
    // @ts-ignore
    const accounts = await conflux.getSigners();
    const receivers = ["cfxtest:aang4d91rejdbpgmgtmspdyefxkubj2bbywrwm9j3z", "cfxtest:aamjxdgz4m84hjvf2s9rmw5uzd4dkh8aa6krdsh0ep"];
    console.log("Start deploy NFT contracts");

    let contractAddrs = await deployContracts()

    const actions = new Actions();

    // ============= erc721 ==============
    console.log("run erc721 without enum")
    // @ts-ignore
    let erc721NoEnum = await conflux.getContractAt("ERC721NFTCustomNoEnum", contractAddrs.erc721NoEnum);
    let receipt = await erc721NoEnum.mintTo(accounts[0].address, 0, "").sendTransaction({ from: accounts[0].address, }).executed();
    actions.push(new Action("erc721NoEnum", "mint", receipt))

    receipt = await erc721NoEnum.transferFrom(accounts[0].address, receivers[0], 0).sendTransaction({ from: accounts[0].address, }).executed();
    actions.push(new Action("erc721NoEnum", "transferFrom -> poor user", receipt))

    receipt = await erc721NoEnum.mintTo(accounts[0].address, 1, "").sendTransaction({ from: accounts[0].address, }).executed();
    receipt = await erc721NoEnum.transferFrom(accounts[0].address, receivers[0], 1).sendTransaction({ from: accounts[0].address, }).executed();
    actions.push(new Action("erc721NoEnum", "transferFrom -> rich user", receipt))

    receipt = await erc721NoEnum.mintTo(accounts[0].address, 2, "").sendTransaction({ from: accounts[0].address, }).executed();
    receipt = await erc721NoEnum.safeTransferFrom(accounts[0].address, receivers[1], 2).sendTransaction({ from: accounts[0].address, }).executed();
    actions.push(new Action("erc721NoEnum", "safeTransferFrom -> poor user", receipt))

    receipt = await erc721NoEnum.mintTo(accounts[0].address, 3, "").sendTransaction({ from: accounts[0].address, }).executed();
    receipt = await erc721NoEnum.safeTransferFrom(accounts[0].address, receivers[1], 3).sendTransaction({ from: accounts[0].address, }).executed();
    actions.push(new Action("erc721NoEnum", "safeTransferFrom -> rich user", receipt))

    // ============= erc721 enum ==============
    console.log("run erc721 enum")
    // @ts-ignore
    let erc721Enum = await conflux.getContractAt("ERC721NFTCustom", contractAddrs.erc721Enum);
    receipt = await erc721Enum.mintTo(accounts[0].address, 0, "").sendTransaction({ from: accounts[0].address, }).executed();
    actions.push(new Action("erc721Enum", "mint", receipt))

    receipt = await erc721Enum.transferFrom(accounts[0].address, receivers[0], 0).sendTransaction({ from: accounts[0].address, }).executed();
    actions.push(new Action("erc721Enum", "transferFrom -> poor user", receipt))

    receipt = await erc721Enum.mintTo(accounts[0].address, 1, "").sendTransaction({ from: accounts[0].address, }).executed();
    receipt = await erc721Enum.transferFrom(accounts[0].address, receivers[0], 1).sendTransaction({ from: accounts[0].address, }).executed();
    actions.push(new Action("erc721Enum", "transferFrom -> rich user", receipt))

    receipt = await erc721Enum.mintTo(accounts[0].address, 2, "").sendTransaction({ from: accounts[0].address, }).executed();
    receipt = await erc721Enum.safeTransferFrom(accounts[0].address, receivers[1], 2).sendTransaction({ from: accounts[0].address, }).executed();
    actions.push(new Action("erc721Enum", "safeTransferFrom -> poor user", receipt))

    receipt = await erc721Enum.mintTo(accounts[0].address, 3, "").sendTransaction({ from: accounts[0].address, }).executed();
    receipt = await erc721Enum.safeTransferFrom(accounts[0].address, receivers[1], 3).sendTransaction({ from: accounts[0].address, }).executed();
    actions.push(new Action("erc721Enum", "safeTransferFrom -> rich user", receipt))

    // // ============= erc1155 ==============
    console.log("run erc1155 without enum")
    // @ts-ignore
    let erc1155NoEnum = await conflux.getContractAt("ERC1155NFTCustomNoEnum", contractAddrs.erc1155NoEnum);
    receipt = await erc1155NoEnum.mintTo(accounts[0].address, 0, 10, "").sendTransaction({ from: accounts[0].address, }).executed();
    actions.push(new Action("erc1155NoEnum", "mint", receipt))

    receipt = await erc1155NoEnum.safeTransferFrom(accounts[0].address, receivers[0], 0, 1, []).sendTransaction({ from: accounts[0].address, }).executed();
    actions.push(new Action("erc1155NoEnum", "safeTransferFrom -> poor user", receipt))

    receipt = await erc1155NoEnum.safeTransferFrom(accounts[0].address, receivers[0], 0, 1, []).sendTransaction({ from: accounts[0].address, }).executed();
    actions.push(new Action("erc1155NoEnum", "safeTransferFrom -> owned t0 token", receipt))

    receipt = await erc1155NoEnum.mintTo(accounts[0].address, 1, 10, "").sendTransaction({ from: accounts[0].address, }).executed();
    receipt = await erc1155NoEnum.safeTransferFrom(accounts[0].address, receivers[0], 1, 1, []).sendTransaction({ from: accounts[0].address, }).executed();
    actions.push(new Action("erc1155NoEnum", "safeTransferFrom -> owned t0 and send t1", receipt))

    // ============= erc1155 enum ==============
    console.log("run erc1155 enum")
    // @ts-ignore
    let erc1155Enum = await conflux.getContractAt("ERC1155NFTCustom", contractAddrs.erc1155Enum);
    receipt = await erc1155Enum.mintTo(accounts[0].address, 0, 10, "").sendTransaction({ from: accounts[0].address, }).executed();
    actions.push(new Action("erc1155Enum", "mint", receipt))

    receipt = await erc1155Enum.safeTransferFrom(accounts[0].address, receivers[0], 0, 1, []).sendTransaction({ from: accounts[0].address, }).executed();
    actions.push(new Action("erc1155Enum", "safeTransferFrom -> poor user", receipt))

    receipt = await erc1155Enum.safeTransferFrom(accounts[0].address, receivers[0], 0, 1, []).sendTransaction({ from: accounts[0].address, }).executed();
    actions.push(new Action("erc1155Enum", "safeTransferFrom -> owned t0 token", receipt))

    receipt = await erc1155Enum.mintTo(accounts[0].address, 1, 10, "").sendTransaction({ from: accounts[0].address, }).executed();
    receipt = await erc1155Enum.safeTransferFrom(accounts[0].address, receivers[0], 1, 1, []).sendTransaction({ from: accounts[0].address, }).executed();
    actions.push(new Action("erc1155Enum", "safeTransferFrom -> owned t0 and send t1", receipt))


    const actStrs = actions.map((a: Action) => `${a.contractType}|${a.name}|${a.gas}|${a.collateral}|${a.hash}`)
    console.log("Contract|Action|GasUsed|StorageCollateral|hash\n-|-|-|-|-\n" + actStrs.join("\n"))
}

summary().
    then(() => console.log("completed"))