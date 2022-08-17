import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
// eslint-disable-next-line node/no-missing-import
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
    // eslint-disable-next-line no-unused-vars
    const [admin, receiver, owner, stranger0, stranger1, stranger2, stranger3, stranger4] = await ethers.getSigners();

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

describe("test erc1155custom", async function () {
    // eslint-disable-next-line no-unused-vars
    let admin: SignerWithAddress, receiver: SignerWithAddress, owner: SignerWithAddress, stranger0: SignerWithAddress
    // eslint-disable-next-line no-unused-vars
    let stranger1: SignerWithAddress, stranger2: SignerWithAddress, stranger3: SignerWithAddress, stranger4: SignerWithAddress

    before(async function () {
        [admin, receiver, owner, stranger0, stranger1, stranger2, stranger3, stranger4] = await ethers.getSigners();
        // console.log("nft deployed, admin %s, owner %s, stranger0 %s", admin.address, owner.address, stranger0.address)
        // console.log("admin role %s, mint role %s", roles.ADMIN_ROLE, roles.MINT_ROLE);
    });

    it("after intial roles are correct", async function () {
        const nft = await deploy()

        expect(await nft.hasRole(roles.ADMIN_ROLE, admin.address)).equal(true);
        expect(await nft.hasRole(roles.ADMIN_ROLE, owner.address)).equal(true);
        expect(await nft.hasRole(roles.ADMIN_ROLE, stranger0.address)).equal(false);

        expect(await nft.hasRole(roles.MINT_ROLE, admin.address)).equal(true);
        expect(await nft.hasRole(roles.MINT_ROLE, owner.address)).equal(true);
        expect(await nft.hasRole(roles.MINT_ROLE, stranger0.address)).equal(false);
    })

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
        await nft.transferByAdmin(stranger1.address, stranger3.address, 1, 5)
        expect(await nft["totalSupply()"]()).equal(3);
        expect(await nft["totalSupply(uint256)"](1)).equal(10);

        // transfer batch and check total supply
        await nft.transferBatchByAdmin([stranger1.address, stranger3.address], [stranger2.address, stranger1.address], [2, 1], [5, 5])
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