const fs = require("fs");
const path = require("path");

function exportDatas(target) {
  fs.mkdirSync(target, { recursive: true });
  const wants = [
    "ERC1155NFT.sol",
    "ERC1155NFTCustom.sol",
    "ERC721NFT.sol",
    "ERC721NFTCustom.sol",
    "NFTContractFactory.sol",
  ];

  const folder = path.join(__dirname, "../artifacts/contracts");
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

exportDatas(process.argv[2]);
