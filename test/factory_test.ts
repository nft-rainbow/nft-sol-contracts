import { expect } from "chai";
import { ethers } from "hardhat";
// eslint-disable-next-line node/no-missing-import
import { ERC1155NFTCustom, ERC721NFTCustom, NFTContractFactory } from "../typechain";

const { keccak256 } = ethers.utils;
// eslint-disable-next-line no-unused-vars
const roles = {
    ADMIN_ROLE: keccak256(Buffer.from("ADMIN_ROLE")),
    MINT_ROLE: keccak256(Buffer.from("MINT_ROLE")),
};

// 
async function deployAndSetTemplates(): Promise<NFTContractFactory> {
    // const [admin, , owner] = await ethers.getSigners();
    const nft1155Template = await deploy1155custom();
    const nft721Template = await deploy721custom();
    const nftContractFactory = await deployNftContractFactory();

    await nftContractFactory.initialize();
    await nftContractFactory.updateNftTemplates(nft721Template.address, nft1155Template.address)
    return nftContractFactory;
}

async function deployNftContractFactory(): Promise<NFTContractFactory> {
    // const [admin, , owner] = await ethers.getSigners();
    const f = await ethers.getContractFactory("NFTContractFactory")
    const nftContractFactory = await f.deploy();
    return nftContractFactory as NFTContractFactory;
}

async function deploy1155custom(
    metadataUpdatable = true,
    tokensBurnable = true,
    tokensTransferable = true,
    baseURI = "http://www.google.com",
): Promise<ERC1155NFTCustom> {
    const [admin, , owner] = await ethers.getSigners();

    const StringsUtils = await ethers.getContractFactory("StringUtils");
    const lib = await StringsUtils.deploy();

    const NFT = await ethers.getContractFactory("ERC1155NFTCustom", {
        libraries: {
            StringUtils: lib.address,
        }
    });
    const nft = await NFT.deploy();
    await nft.initialize("NFT RAINBOW URI", "NFT RAINBOW", "NFT", 200, owner.address, [owner.address, admin.address], true, true)
    return nft as ERC1155NFTCustom
};

async function deploy721custom(
    metadataUpdatable = true,
    tokensBurnable = true,
    tokensTransferable = true,
    baseURI = "http://www.google.com",
): Promise<ERC721NFTCustom> {
    const [admin, , owner] = await ethers.getSigners();

    const StringsUtils = await ethers.getContractFactory("StringUtils");
    const lib = await StringsUtils.deploy();

    const NFT = await ethers.getContractFactory("ERC721NFTCustom", {
        libraries: {
            StringUtils: lib.address,
        }
    });
    const nft = await NFT.deploy();
    await nft.initialize("NFT RAINBOW URI", "NFT RAINBOW", "NFT", 200, owner.address, [owner.address, admin.address], true, true, 0)
    return nft as ERC721NFTCustom
};



describe("test factory", async function () {
    it("test new erc1155custom", async function () {
        const [admin, , owner] = await ethers.getSigners();
        const factory = await deployAndSetTemplates();
        const tx = await factory.newERC1155Custom("NFT RAINBOW URI", "NFT RAINBOW", "NFT", 200, owner.address, [owner.address, admin.address], true, true);
        const receipt = await tx.wait()
        expect(receipt.status).equals(1)
    })

    it("test new erc721custom", async function () {
        const [admin, , owner] = await ethers.getSigners();
        const factory = await deployAndSetTemplates();
        const tx = await factory.newERC721Custom("NFT RAINBOW URI", "NFT RAINBOW", "NFT", 200, owner.address, [owner.address, admin.address], true, true, 1);
        const receipt = await tx.wait()
        expect(receipt.status).equals(1)
    })
})