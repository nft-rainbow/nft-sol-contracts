# export abi and bytecode to rainbow-api
export:
	npx hardhat compile
	node ./scripts/export-abi-bytecode.js ./abi_bytecode
	scp -r ./abi_bytecode/ ${RAINBOW_API_PATH}/contracts/artifacts
	rm -rf ./abi_bytecode