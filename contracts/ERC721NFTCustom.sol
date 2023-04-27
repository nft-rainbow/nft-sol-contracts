// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC2981 } from "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@confluxfans/contracts/token/CRC721/extensions/CRC721Enumerable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "hardhat/console.sol";

import "./lib/ERC721URIStorage.sol";
import "./lib/Base64.sol";
import "./lib/ConfigManager.sol";
import "./lib/StringUtils.sol";
import "./lib/ConfluxHelper.sol";

contract ERC721NFTCustom is CRC721Enumerable, ERC721URIStorage, ConfigManager, Initializable, ConfluxHelper {
	using Strings for uint256;
	using StringUtils for string;

	string private _name;
	string private _symbol;
	string private baseURI = "";

	uint256 public transferCooldownTime;

	mapping(uint256 => bool) public freezeTokenUris;
	mapping(uint256 => uint256) public lastTransferTimes;

	event PermanentURI(string value, uint256 indexed id); // https://docs.opensea.io/docs/metadata-standards
	event TransferCooldownTimeChanged(uint256 value);

	constructor() ERC721("", "") {}

	function initialize(
		string memory name_,
		string memory symbol_,
		string memory uri,
		uint256 royaltiesBps,
		address royaltiesAddress,
		address[] memory owners,
		// bool tokensBurnable,
		bool tokensTransferableByAdmin,
		bool tokensTransferableByUser,
		uint256 transferCooldownTime_,
		bool isSetSponsorWhitelistForAllUser
	) public initializer {
		super.initalize();
		_initRoles(owners);
		_name = name_;
		_symbol = symbol_;
		baseURI = uri;
		_setTransferCooldownTime(transferCooldownTime_);
		// _setTokensBurnable(tokensBurnable);
		_setTokensTransferable(tokensTransferableByAdmin, tokensTransferableByUser);
		_setRoyalties(royaltiesBps, royaltiesAddress);
		_addSponsorPrivilege(owners);

		if (isSetSponsorWhitelistForAllUser) {
			_setWhiteListForAllUser();
		}
	}

	function name() public view virtual override returns (string memory) {
		return _name;
	}

	function symbol() public view virtual override returns (string memory) {
		return _symbol;
	}

	function _baseURI() internal view virtual override(ERC721) returns (string memory) {
		return baseURI;
	}

	function setURI(string memory newURI) public onlyAdmin {
		require(metadataUpdatable, "NFT: Token uris are frozen globally");
		baseURI = newURI;
	}

	function setURI(uint256 tokenId, string memory tokenUri) private {
		require(metadataUpdatable, "NFT: Token uris are frozen globally");
		require(!freezeTokenUris[tokenId], "NFT: Token is frozen");
		_setTokenURI(tokenId, tokenUri);
	}

	function _setTransferCooldownTime(uint256 val) internal {
		transferCooldownTime = val;
		emit TransferCooldownTimeChanged(val);
	}

	function setTransferCooldownTime(uint256 val) public onlyAdmin {
		_setTransferCooldownTime(val);
	}

	function freezeTokenURI(uint256 tokenId) public onlyAdmin {
		require(metadataUpdatable, "NFT: Token URIs are frozen globally");
		require(!freezeTokenUris[tokenId], "NFT: Token is frozen");
		freezeTokenUris[tokenId] = true;
		emit PermanentURI(tokenURI(tokenId), tokenId);
	}

	function updateTokenURI(uint256 tokenId, string memory newUri) public onlyAdmin {
		require(_exists(tokenId), "NFT: update URI query for nonexistent token");
		require(metadataUpdatable, "NFT: Token URIs are frozen globally");
		require(!freezeTokenUris[tokenId], "NFT: Token is frozen");
		require(!newUri.equals(tokenURI(tokenId)), "NFT: New token URI is same as updated");
		setURI(tokenId, newUri);
	}

	function burn(uint256 id) public onlyAdmin {
		require(tokensBurnable(), "NFT: tokens burning is disabled");
		_burn(id);
	}

	function burnBatch(uint256[] memory ids) public onlyAdmin {
		require(tokensBurnable(), "NFT: tokens burning is disabled");
		for (uint256 i = 0; i < ids.length; i++) {
			_burn(ids[i]);
		}
	}

	function transferByAdmin(address user, address to, uint256 id) public onlyAdmin {
		require(tokensTransferableByAdmin, "NFT: Transfers by admin are disabled");
		_safeTransfer(user, to, id, "");
	}

	function transferBatchByAdmin(address[] memory users, address[] memory to, uint256[] memory ids) public onlyAdmin {
		require(tokensTransferableByAdmin, "NFT: Transfers by admin are disabled");
		for (uint256 i = 0; i < ids.length; i++) {
			_safeTransfer(users[i], to[i], ids[i], "");
		}
	}

	function _mintTo(address to, uint256 id, string memory tokenUri) internal {
		_mint(to, id);
		if (bytes(tokenUri).length > 0) {
			setURI(id, tokenUri);
		}
	}

	function mintTo(address to, uint256 id, string memory tokenUri) public onlyMinter {
		_mintTo(to, id, tokenUri);
	}

	function mintToBatch(address[] memory tos, uint256[] memory ids, string[] memory uris) public onlyMinter {
		require(tos.length == ids.length && tos.length == uris.length, "input length not same");
		for (uint256 i = 0; i < ids.length; i++) {
			require(tos[i] == address(tos[i]), "NFT: one of addresses is invalid");
			_mintTo(tos[i], ids[i], uris[i]);
		}
	}

	/*============================= sponsor manager ======================*/

	function addSponsorPrivilege(address[] memory whites) public onlyAdmin {
		_addSponsorPrivilege(whites);
	}

	function removeSponsorPrivilege(address[] memory whites) public onlyAdmin {
		_removeSponsorPrivilege(whites);
	}

	/*============================= overrides==============================*/
	function supportsInterface(
		bytes4 interfaceId
	) public view virtual override(ERC721Enumerable, ERC721, AccessControl) returns (bool) {
		return
			ERC721.supportsInterface(interfaceId) ||
			ERC721Enumerable.supportsInterface(interfaceId) ||
			interfaceId == type(IERC2981).interfaceId ||
			interfaceId == type(CRC721Enumerable).interfaceId;
	}

	function _beforeTokenTransfer(
		address from,
		address to,
		uint256 tokenId
	) internal virtual override(ERC721Enumerable, ERC721) {
		if (from != address(0) && to != address(0)) {
			require(block.timestamp - lastTransferTimes[tokenId] >= transferCooldownTime, "Now on cooldown time");
			lastTransferTimes[tokenId] = block.timestamp;
		}

		if (from != address(0)) {
			bool isAdminAndEnable = isAdmin() && tokensTransferableByAdmin;
			bool isUserAndEnable = _isApprovedOrOwner(_msgSender(), tokenId) && tokensTransferableByUser;
			console.log("isAdminAndEnable %s, isUserAndEnable %s", isAdminAndEnable, isUserAndEnable);
			require(isAdminAndEnable || isUserAndEnable, "ERC721NFTCustom: no permission");
		}
		ERC721Enumerable._beforeTokenTransfer(from, to, tokenId);
	}

	function tokenURI(uint256 tokenId) public view virtual override(ERC721URIStorage, ERC721) returns (string memory) {
		return ERC721URIStorage.tokenURI(tokenId);
	}

	function _burn(uint256 tokenId) internal virtual override(ERC721URIStorage, ERC721) {
		return ERC721URIStorage._burn(tokenId);
	}
}
