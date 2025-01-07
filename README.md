# NFTRainbow NFT solidity contracts

This project contains the NFT solidity contract templates

## Utility Deployment

### ContractSponsorInfo

* Mainnet: `cfx:acch0rtajf7gu2z5pr8f1k3d6vnr9mpv1pfeau9jk6`
* Testnet: `cfxtest:acfbnrv048jvnnx28ewewufr0pf93b5aey6ug6fsyz`

## Summary of costs

Note: The following statistics are based on not setting the token URI separately, which means using the token URI as the base URI. Tests have shown that if the token URI is set separately, it will cause a significant increase in storage collateral consumption, which is related to the number of bytes in the token URI.

Contract|Action|GasUsed|StorageCollateral|hash
-|-|-|-|-
erc721NoEnum|mint|40144|128|0x2cde364600936a0343d7f8dc164bab6e932ca31551ce3c44dcb90facade100e8
erc721NoEnum|transferFrom -> poor user|68248|64|0xfe8d3f492926a918778576dde635bffc9f181cacd7cba9d9c8d2755635d573f1
erc721NoEnum|transferFrom -> rich user|68312|0|0x4c4aedfc3d6b51559aed55fb2af28cd6c9eba6c73c26f7d839dee7972deea1bb
erc721NoEnum|safeTransferFrom -> poor user|69268|64|0x0c4a07c1f352557e7ff77fd9c4d9ee2fa77eb7a4c36d8b6180b2aa9dfe9ae491
erc721NoEnum|safeTransferFrom -> rich user|69268|0|0x9aec1116bcab8062c70ae4dce19f047abb3185425f2c8d52e57987db324543a1
erc721Enum|mint|67511|192|0x8dd83ff0e913cfc5b403dd1262981d3631fbe19e0028804ba122f72026a34500
erc721Enum|transferFrom -> poor user|91886|64|0xcd95cc3d3ce8b2d2e3391faca3a39c8cca4d6d99b10a21f71b32e875b6ae26fa
erc721Enum|transferFrom -> rich user|91950|64|0xef7699a4016d137af1b5bf1c388a6a2fc4742de3dfe7e5c99924298092a10c81
erc721Enum|safeTransferFrom -> poor user|92928|64|0x49bd4b536d3afabdf79092d8b7b983c1c748725aa929ae1f789b4d51c2f090cb
erc721Enum|safeTransferFrom -> rich user|92928|64|0x8ed5119e9df85bec9fc65636a60d75d3c10ebce8e5488c568abb9b0bf8e767ae
erc1155NoEnum|mint|35447|64|0x154182ed127b366b62e84d424a4f6f7020a15118bb7638a711cfa8a97921c2e5
erc1155NoEnum|safeTransferFrom -> poor user|44632|64|0x94016192f735f24e7db45e6da5ef9a8b523e9df7936b5da842a3ba561a90e148
erc1155NoEnum|safeTransferFrom -> owned t0 token|44632|0|0xb0e902a13447a754887863739ccd46e303be99559f861ea92a0d0bb326871435
erc1155NoEnum|safeTransferFrom -> owned t0 and send t1|44696|64|0xb1c58417dc03a142f52f6a5b8cabede1798b1b9e5fc79d04eb172444a13e4430
erc1155Enum|mint|79533|384|0x01da14c175dd4a02e5ada176d9002d11151deaa6216c3c0eb0608aaaf466f637
erc1155Enum|safeTransferFrom -> poor user|65054|192|0xd38bda59b29b1bdd0cb89691fd0b669be94736537a3c2cda1806b21517c9db0b
erc1155Enum|safeTransferFrom -> owned t0 token|47198|0|0xdf01423973b13b348a1b0ea1d7a537c8d2c4706b9f6e4b28f945f2c408621fbb
erc1155Enum|safeTransferFrom -> owned t0 and send t1|65118|192|0x17db75409ec286b9672ef9a910aa6c381dc250bb8d107a7de357bb63af926440
