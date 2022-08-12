// const assert = require('assert');
// const mocha = require('mocha');
// const { ethers } = require('hardhat')
// const { describe, it, before, after } = mocha

// import mocha from "mocha";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { ERC1155NFTCustom } from "../typechain";

const { keccak256 } = ethers.utils;
const roles = {
    ADMIN_ROLE: keccak256(Buffer.from("ADMIN_ROLE")),
    MINT_ROLE: keccak256(Buffer.from("MINT_ROLE")),
};

async function deploy(
    metadataUpdatable = true,
    tokensBurnable = true,
    tokensTransferable = true,
    baseURI = "http://www.google.com",
): Promise<ERC1155NFTCustom> {
    const [admin, receiver, owner, stranger0, stranger1, stranger2, stranger3, stranger4] = await ethers.getSigners();

    const StringsUtils = await ethers.getContractFactory("StringUtils");
    const lib = await StringsUtils.deploy();

    const NFT = await ethers.getContractFactory("ERC1155NFTCustom", {
        libraries: {
            StringUtils: lib.address,
        }
    });
    const nft = await NFT.deploy("NFT RAINBOW URI", "NFT RAINBOW", "NFT", 200, owner.address, owner.address, true);
    return nft as ERC1155NFTCustom
};

describe("test erc1155custom", async function () {
    let admin: SignerWithAddress, receiver: SignerWithAddress, owner: SignerWithAddress, stranger0: SignerWithAddress,
        stranger1: SignerWithAddress, stranger2: SignerWithAddress, stranger3: SignerWithAddress, stranger4: SignerWithAddress

    before(async function () {
        [admin, receiver, owner, stranger0, stranger1, stranger2, stranger3, stranger4] = await ethers.getSigners();
    });

    it("only mint role and admin could mint", async function () {
        const nft = await deploy()
        await nft["mintTo(address,uint256,uint256,string)"](stranger1.address, 1, 10, "url_1")
        await nft.connect(owner)["mintTo(address,uint256,uint256,string)"](stranger1.address, 2, 10, "url_2")
        await expect(nft.connect(stranger1)["mintTo(address,uint256,uint256,string)"](stranger1.address, 3, 10, "url_1")).to.be.reverted;
    })

    it("totoal supply should be right", async function () {
        // deploy
        const nft = await deploy()
        
        // mint and check total supply
        await nft["mintTo(address,uint256,uint256,string)"](stranger1.address, 1, 10, "url_1")
        expect(await nft["totalSupply()"]()).equal(1);
        expect(await nft["totalSupply(uint256)"](1)).equal(10);
        
        // batch mint and check total supply
        await nft.mintToBatch([stranger1.address, stranger2.address], [2, 3], [10, 10], ["url_2", "url_3"])
        expect(await nft["totalSupply()"]()).equal(3);
        expect(await nft["totalSupply(uint256)"](2)).equal(10);
        
        // transfer and check total supply
        await nft.transferByOwner(stranger1.address, stranger3.address, 1, 5)
        expect(await nft["totalSupply()"]()).equal(3);
        expect(await nft["totalSupply(uint256)"](1)).equal(10);
        
        // transfer batch and check total supply
        await nft.transferByOwnerBatch([stranger1.address, stranger3.address], [stranger2.address, stranger1.address], [2, 1], [5, 5])
        expect(await nft["totalSupply()"]()).equal(3);
        expect(await nft["totalSupply(uint256)"](1)).equal(10);
        expect(await nft["totalSupply(uint256)"](2)).equal(10);

        // burn and check total supply
        await nft.burn(stranger1.address, 1, 5)
        expect(await nft["totalSupply()"]()).equal(3);
        expect(await nft["totalSupply(uint256)"](1)).equal(5);

        // burn batch and check total supply
        await nft.burnBatch(stranger1.address, [1, 2], [5, 5])
        expect(await nft["totalSupply()"]()).equal(2);
        expect(await nft["totalSupply(uint256)"](1)).equal(0);
        expect(await nft["totalSupply(uint256)"](2)).equal(5);
        expect(await nft["totalSupply(uint256)"](3)).equal(10);
    });

    after(function () { });
});