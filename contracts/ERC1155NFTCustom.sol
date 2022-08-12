// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import { IERC2981 } from "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@confluxfans/contracts/token/CRC1155/extensions/CRC1155Enumerable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";


// import "./lib/Config.sol";
import "./lib/ConfigManager.sol";
import "./lib/StringUtils.sol";

contract ERC1155NFTCustom is CRC1155Enumerable, ERC1155URIStorage, ConfigManager {
	using Strings for uint256;
	using StringUtils for string;

	string public name;	
	string public symbol;
	mapping(uint256 => bool) public freezeTokenUris;

	event PermanentURI(string _value, uint256 indexed _id); // https://docs.opensea.io/docs/metadata-standards

	constructor(
		string memory _name,
		string memory _symbol,
		string memory baseURI,
		uint256 royaltiesBps,
		address royaltiesAddress,
		address owner,
		bool tokensBurnable
	) ERC1155(baseURI) {
		name = _name;
		symbol = _symbol;
		_setURI(baseURI);
		_initRolesWithMsgSender(owner);
		setTokensBurnable(tokensBurnable);
		setRoyalties(royaltiesBps, royaltiesAddress);
	}

	function setURI(string memory _newURI) public onlyRole(ADMIN_ROLE) {
		require(metadataUpdatable, "NFT: Token uris are frozen globally");
		_setURI(_newURI);
	}

	function setURI(uint256 tokenId, string memory tokenUri) private {
		require(metadataUpdatable, "NFT: Token uris are frozen globally");
		_setURI(tokenId, tokenUri);
		emit URI(tokenUri, tokenId);
	}

	function freezeTokenURI(uint256 _tokenId) public onlyRole(ADMIN_ROLE) {
		require(metadataUpdatable, "NFT: Token URIs are frozen globally");
		require(!freezeTokenUris[_tokenId], "NFT: Token is frozen");
		freezeTokenUris[_tokenId] = true;
		emit PermanentURI(uri(_tokenId), _tokenId);
	}

	function updateTokenURI(uint256 _tokenId, string memory _newUri) public onlyRole(ADMIN_ROLE) {
		require(exists(_tokenId), "NFT: update URI query for nonexistent token");
		require(metadataUpdatable, "NFT: Token URIs are frozen globally");
		require(!freezeTokenUris[_tokenId], "NFT: Token is frozen");
		require(!_newUri.equals(uri(_tokenId)), "NFT: New token URI is same as updated");
		setURI(_tokenId, _newUri);
	}

	function burn(
		address user,
		uint256 id,
		uint256 value
	) public onlyRole(ADMIN_ROLE) {
		require(tokensBurnable, "NFT: tokens burning is disabled");
		_burn(user, id, value);
	}

	function burnBatch(
		address user,
		uint256[] memory ids,
		uint256[] memory values
	) public onlyRole(ADMIN_ROLE) {
		require(tokensBurnable, "NFT: tokens burning is disabled");
		_burnBatch(user, ids, values);
	}

	function transferByOwner(
		address user,
		address to,
		uint256 id,
		uint256 amount
	) public onlyRole(ADMIN_ROLE) {
		require(tokensTransferable, "NFT: Transfers by owner are disabled");
		_safeTransferFrom(user, to, id, amount, "");
	}

	function transferByOwnerBatch(
		address[] memory users,
		address[] memory to,
		uint256[] memory ids,
		uint256[] memory amounts
	) public onlyRole(ADMIN_ROLE) {
		require(tokensTransferable, "NFT: Transfers by owner are disabled");
		for (uint256 i = 0; i < ids.length; i++) {
			_safeTransferFrom(users[i], to[i], ids[i], amounts[i], "");
		}
	}

	// function uri(uint256 _id) public view override returns (string memory) {
	// 	if (bytes(_tokenUris[_id]).length > 0) {
	// 		if (bytes(baseURI).length > 0) {
	// 			return string(abi.encodePacked(baseURI, _tokenUris[_id]));
	// 		} else {
	// 			return _tokenUris[_id];
	// 		}
	// 	} else {
	// 		return super.uri(_id);
	// 	}
	// }

	function _mintTo(
		address to,
		uint256 id,
		uint256 amount,
		string memory tokenUri
	) internal {
		revertIfUriConflict(id, tokenUri);
		if (bytes(tokenUri).length > 0) {
			setURI(id, tokenUri);
		}
		_mint(to, id, amount, "");
	}

	function mintTo(
		address to,
		uint256 id,
		string memory tokenUri
	) public onlyRole(MINT_ROLE) {
		_mintTo(to, id, 1, tokenUri);
	}

	function mintTo(
		address to,
		uint256 id,
		uint256 amount,
		string memory tokenUri
	) public onlyRole(MINT_ROLE) {
		_mintTo(to, id, amount, tokenUri);
	}

	function mintToBatch(
		address[] memory tos,
		uint256[] memory ids,
		uint256[] memory amounts,
		string[] memory uris
	) public onlyRole(MINT_ROLE) {
		require(
			tos.length == ids.length && tos.length == amounts.length && tos.length == uris.length,
			"input length not same"
		);
		for (uint256 i = 0; i < ids.length; i++) {
			revertIfUriConflict(ids[i], uris[i]);
			require(tos[i] == address(tos[i]), "NFT: one of addresses is invalid");
			_mintTo(tos[i], ids[i], amounts[i], uris[i]);
		}
	}

	function revertIfUriConflict(uint256 id, string memory tokenUri) internal view {
		if (exists(id)) {
			require(tokenUri.equals(uri(id)), "NFT: URI different with previous");
		}
	}

	/*============================= overrides==============================*/
	function supportsInterface(bytes4 interfaceId)
		public
		view
		override(CRC1155Enumerable, ERC1155, AccessControl)
		returns (bool)
	{
		return
			ERC1155.supportsInterface(interfaceId) ||
			interfaceId == type(IERC2981).interfaceId ||
			interfaceId == type(ICRC1155Enumerable).interfaceId;
	}

	function _beforeTokenTransfer(
		address operator,
		address from,
		address to,
		uint256[] memory ids,
		uint256[] memory amounts,
		bytes memory data
	) internal override(CRC1155Enumerable, ERC1155) {
		CRC1155Enumerable._beforeTokenTransfer(operator, from, to, ids, amounts, data);
	}

	function uri(uint256 tokenId) public view override(ERC1155URIStorage, ERC1155) returns (string memory) {
		return ERC1155URIStorage.uri(tokenId);
	}
}
