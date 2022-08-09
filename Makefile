export:
	npx hardhat compile
	node ./scripts/export-abi-bytecode.js ./abi_bytecode
	scp -r ./abi_bytecode/ ~/myspace/mywork/rainbow-api/contracts/artifacts
	rm -rf ./abi_bytecode