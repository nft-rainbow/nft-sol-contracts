// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/IAccessControl.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import "@confluxfans/contracts/InternalContracts/SponsorWhitelistControl.sol";
import "@confluxfans/contracts/utils/ERC1820Context.sol";

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./lib/ConfluxHelper.sol";

interface IGranularRoles {
	function grantAdminRole(address user) external;

	function grantMintRole(address user) external;
}

interface IERC721NFTCustomIniter is IGranularRoles {
	function initialize(
		string memory name_,
		string memory symbol_,
		string memory uri,
		uint256 royaltiesBps,
		address royaltiesAddress,
		address[] memory owners,
		bool tokensBurnable,
		bool tokensTransferableByAdmin,
		bool tokensTransferableByUser,
		uint256 transferCooldownTime_,
		bool isSetSponsorWhitelistForAllUser
	) external;
}

interface IERC1155NFTCustomIniter is IGranularRoles {
	function initialize(
		string memory _name,
		string memory _symbol,
		string memory baseURI,
		uint256 royaltiesBps,
		address royaltiesAddress,
		address[] memory owners,
		bool tokensBurnable,
		bool tokensTransferableByAdmin,
		bool tokensTransferableByUser,
		bool isSetSponsorWhitelistForAllUser
	) external;
}

contract NFTContractFactory is AccessControl, Initializable, ConfluxHelper {
	bytes32 public constant ROLE_OWNER = keccak256("ROLE_OWNER");

	address public erc721CustomImpl;
	address public erc1155CustomImpl;

	// sponsor when deploy erc721/erc1155 contracts
	uint public sponsorGas = 0.01 ether;
	uint public sponsorGasUpperBound = 0.001 ether;
	uint public sponsorCollateral = 0.99 ether;

	event ContractCreated(ContractType contractType, address contractAddress);

	enum ContractType {
		// ERC721,
		ERC721Custom,
		// ERC1155,
		ERC1155Custom
	}

	function initialize() public initializer {
		_grantRole(ROLE_OWNER, msg.sender);
		_setWhiteListForAllUser();
	}

	function changeOwner(address newOwner) public onlyRole(ROLE_OWNER) {
		_revokeRole(ROLE_OWNER, msg.sender);
		_grantRole(ROLE_OWNER, newOwner);
	}

	function updateNftTemplates(address _erc721CustomImpl, address _erc1155CustomImpl) public onlyRole(ROLE_OWNER) {
		erc721CustomImpl = _erc721CustomImpl;
		erc1155CustomImpl = _erc1155CustomImpl;
	}

	function newERC721Custom(
		string memory name,
		string memory symbol,
		string memory baseURI,
		uint256 royaltiesBps,
		address royaltiesAddress,
		address[] memory owners,
		bool tokensBurnable,
		bool tokensTransferableByAdmin,
		bool tokensTransferableByUser,
		uint256 transferCooldownTime,
		bool isSetSponsorWhitelistForAllUser
	) public onlyRole(ROLE_OWNER) {
		IERC721NFTCustomIniter instance = IERC721NFTCustomIniter(Clones.clone(erc721CustomImpl));
		instance.initialize(
			name,
			symbol,
			baseURI,
			royaltiesBps,
			royaltiesAddress,
			owners,
			tokensBurnable,
			tokensTransferableByAdmin,
			tokensTransferableByUser,
			transferCooldownTime,
			isSetSponsorWhitelistForAllUser
		);

		// _sponsor(address(instance), sponsorGas, sponsorGasUpperBound, sponsorCollateral);
		emit ContractCreated(ContractType.ERC721Custom, address(instance));
	}

	function newERC1155Custom(
		string memory name,
		string memory symbol,
		string memory baseURI,
		uint256 royaltiesBps,
		address royaltiesAddress,
		address[] memory owners,
		bool tokensBurnable,
		bool tokensTransferableByAdmin,
		bool tokensTransferableByUser,
		bool isSetSponsorWhitelistForAllUser
	) public onlyRole(ROLE_OWNER) {
		IERC1155NFTCustomIniter instance = IERC1155NFTCustomIniter(Clones.clone(erc1155CustomImpl));
		instance.initialize(
			name,
			symbol,
			baseURI,
			royaltiesBps,
			royaltiesAddress,
			owners,
			tokensBurnable,
			tokensTransferableByAdmin,
			tokensTransferableByUser,
			isSetSponsorWhitelistForAllUser
		);

		// _sponsor(address(instance), sponsorGas, sponsorGasUpperBound, sponsorCollateral);
		emit ContractCreated(ContractType.ERC1155Custom, address(instance));
	}

	function withdraw(uint amount) public onlyRole(ROLE_OWNER) {
		require(msg.sender.balance >= amount, "out of balance");
		payable(msg.sender).transfer(amount);
	}

	receive() external payable {}
}
