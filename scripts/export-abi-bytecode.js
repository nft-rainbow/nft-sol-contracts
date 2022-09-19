const fs = require("fs");
const path = require("path");

function exportDatas(source, target, wants) {
  fs.mkdirSync(target, { recursive: true });
  
  const folder = path.join(__dirname, source);
  for (let i = 0; i < wants.length; i++) {
    const data = require(path.join(
      folder,
      wants[i],
      wants[i].replace(".sol", ".json")
    ));
    fs.writeFileSync(
      path.join(target, wants[i].replace(".sol", ".abi")),
      JSON.stringify(data.abi)
    );
    fs.writeFileSync(
      path.join(target, wants[i].replace(".sol", ".bin")),
      data.bytecode.substr(2)
    );
  }
}

exportDatas("../artifacts/contracts", process.argv[2], [
  "ERC1155NFT.sol",
  "ERC1155NFTCustom.sol",
  "ERC721NFT.sol",
  "ERC721NFTCustom.sol",
  "NFTContractFactory.sol",
]);
exportDatas("../artifacts/@confluxfans/contracts/InternalContracts", process.argv[2], ["AdminControl.sol",
  "SponsorWhitelistControl.sol"
]);

