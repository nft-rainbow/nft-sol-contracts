# export abi and bytecode to rainbow-api
export:
	npx hardhat compile
	node ./scripts/export-abi-bytecode.js ./abi_bytecode
	scp -r ./abi_bytecode/ ${RAINBOW_API_PATH}/contracts/artifacts
	rm -rf ./abi_bytecode

# deploy NFTContractFactory proxy or update NFTContractFactory template if proxy already exists, then update both ERC721NFTCustom and ERC1155NFTCustom templates
# Note: ENV is the environment name, like dev, prod, etc. Which is defined in app.config.json.
deploy:
	npx hardhat compile  
	PRIVATE_KEY=${PRIVATE_KEY} HARDHAT_NETWORK=${HARDHAT_NETWORK} ENV=${ENV} ts-node ./scripts/cli/contract-factory-op.ts deploy

# update ERC721NFTCustom or ERC1155NFTCustom templates
# Note: ENV is the environment name, like dev, prod, etc. Which is defined in app.config.json.
update:
	npx hardhat compile
	PRIVATE_KEY=${PRIVATE_KEY} HARDHAT_NETWORK=${HARDHAT_NETWORK} ENV=${ENV} ts-node ./scripts/cli/contract-factory-op.ts update_templates --erc721 true --erc1155 true --erc721NoEnum true --erc1155NoEnum true