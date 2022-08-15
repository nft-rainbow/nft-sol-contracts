/* eslint-disable prettier/prettier */
const { Conflux } = require('js-conflux-sdk');
// eslint-disable-next-line node/no-unpublished-require
const { keccak256 } = require('ethers/lib/utils');

// console.log("argv", process.argv)
// console.log("keccak256", keccak256)

async function checkRole(url, address, role, user) {
    // console.log("arguments", arguments)
    const conflux = new Conflux({ url })
    const abi = ["function hasRole(bytes32 role, address account) view returns (bool) "]
    const contract = conflux.Contract({ abi, address: address })
    const ok = await contract.hasRole(keccak256(Buffer.from(role)), user)
    return ok;
}

async function tryMintTo(url, address, user) {
    const conflux = new Conflux({ url })
    const abi = ["function mintTo(address account,uint256 id,string memory _uri) returns (uint256)"]
    const contract = conflux.Contract({ abi, address: address })
    await contract.mintTo(user, 1, "uri").call({ from: user })
}

module.exports = { checkRole, tryMintTo }