// import { ethers } from "hardhat";
// import { ERC1155NFTCustom } from "../typechain";
// import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

// async function deploy(
//     metadataUpdatable = true,
//     tokensBurnable = true,
//     tokensTransferable = true,
//     baseURI = "http://www.google.com",
// ): Promise<ERC1155NFTCustom> {
//     const [caller, receiver, adminRole, mintRole, stranger1, stranger2, stranger3, stranger4] = await ethers.getSigners();
//     const NFT = await ethers.getContractFactory("ERC1155NFTCustom");

//     const deploymentConfig = {
//         name: "NFTPort",
//         symbol: "NFT",
//         owner: adminRole.address,
//         tokensBurnable,
//     };

//     const runtimeConfig = {
//         baseURI,
//         metadataUpdatable,
//         tokensTransferable,
//         royaltiesBps: 250,
//         royaltiesAddress: adminRole.address,
//     };

//     const nft = await NFT.deploy(deploymentConfig, runtimeConfig, adminRole.address);
//     // console.log("nft.constructor", nft.constructor.name);
//     const deployed = await nft.deployed();
//     // console.log("deployed.constructor", deployed.constructor.name);
//     return deployed as ERC1155NFTCustom
// };

// async function testTotalSupply() {
//     const nft = await deploy();
//     const [caller, receiver, adminRole, mintRole, stranger1, stranger2, stranger3, stranger4] = await ethers.getSigners();
//     const gas = await nft.estimateGas.mint(stranger1.address, 1, 10, "url_1", { from: caller.address }).catch(err => console.error(err))
//     console.log("estimated gas", gas)
// }

// // testTotalSupply()