// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import { IERC2981 } from "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@confluxfans/contracts/token/CRC1155/extensions/CRC1155Enumerable.sol";

import "./lib/Base64.sol";
import "./lib/Config.sol";
import "./lib/ConfigManager.sol";
import "./lib/StringUtils.sol";

contract ERC1155NFTCustom is CRC1155Enumerable, ConfigManager {
	using Strings for uint256;
	using StringUtils for string;

	mapping(uint256 => bool) public freezeTokenUris;
	mapping(uint256 => string) private _tokenUris;

	event PermanentURI(string _value, uint256 indexed _id); // https://docs.opensea.io/docs/metadata-standards

	constructor(
		string memory name,
		string memory symbol,
		string memory baseURI,
		uint256 royaltiesBps,
		address royaltiesAddress,
		address owner,
		bool tokensBurnable
	) ERC1155(baseURI) ConfigManager(name, symbol) {
		_initRolesWithMsgSender(owner);
		setTokensBurnable(tokensBurnable);
		setRoyalties(royaltiesBps, royaltiesAddress);
	}

	function setURI(string memory _newURI) public onlyRole(ADMIN_ROLE) {
		require(metadataUpdatable, "NFT: Token uris are frozen globally");
		_setURI(_newURI);
	}

	function setTokenURI(uint256 tokenId, string memory tokenUri) private {
		_tokenUris[tokenId] = tokenUri;
		emit URI(tokenUri, tokenId);
	}

	function freezeTokenURI(uint256 _tokenId) public onlyRole(ADMIN_ROLE) {
		require(metadataUpdatable, "NFT: Token URIs are frozen globally");
		require(!freezeTokenUris[_tokenId], "NFT: Token is frozen");
		freezeTokenUris[_tokenId] = true;
		emit PermanentURI(_tokenUris[_tokenId], _tokenId);
	}

	function updateTokenURI(uint256 _tokenId, string memory _newUri) public onlyRole(ADMIN_ROLE) {
		require(exists(_tokenId), "NFT: update URI query for nonexistent token");
		require(metadataUpdatable, "NFT: Token URIs are frozen globally");
		require(!freezeTokenUris[_tokenId], "NFT: Token is frozen");
		require(!_newUri.equals(_tokenUris[_tokenId]), "NFT: New token URI is same as updated");
		setTokenURI(_tokenId, _newUri);
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

	function uri(uint256 _id) public view override returns (string memory) {
		if (bytes(_tokenUris[_id]).length > 0) {
			if (bytes(baseURI).length > 0) {
				return string(abi.encodePacked(baseURI, _tokenUris[_id]));
			} else {
				return _tokenUris[_id];
			}
		} else {
			return super.uri(_id);
		}
	}

	function mintTo(
		address to,
		uint256 id,
		string memory tokenUri
	) public onlyRole(MINT_ROLE) {
		mintTo(to, id, 1, tokenUri);
	}

	function mintTo(
		address to,
		uint256 id,
		uint256 amount,
		string memory tokenUri
	) public onlyRole(MINT_ROLE) {
		revertIfUriConflict(id, tokenUri);
		if (bytes(tokenUri).length > 0) {
			_tokenUris[id] = tokenUri;
			emit URI(tokenUri, id);
		}
		_mint(to, id, amount, "");
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
			require(amounts[i] > 0, "NFT: all amounts must be > 0");
			if (bytes(uris[i]).length > 0) {
				_tokenUris[ids[i]] = uris[i];
				emit URI(uris[i], ids[i]);
			}
			_mint(tos[i], ids[i], amounts[i], "");
		}
	}

	function royaltyInfo(uint256 tokenId, uint256 salePrice) external view returns (address, uint256) {
		return (royaltiesAddress, (royaltiesBps * salePrice) / ROYALTIES_BASIS);
	}

	function contractURI() external view returns (string memory) {
		string memory json = Base64.encode(
			bytes(
				string(
					abi.encodePacked(
						// solium-disable-next-line quotes
						'{"seller_fee_basis_points": ', // solhint-disable-line
						royaltiesBps.toString(),
						// solium-disable-next-line quotes
						', "fee_recipient": "', // solhint-disable-line
						uint256(uint160(royaltiesAddress)).toHexString(20),
						// solium-disable-next-line quotes
						'"}' // solhint-disable-line
					)
				)
			)
		);

		string memory output = string(abi.encodePacked("data:application/json;base64,", json));

		return output;
	}

	function supportsInterface(bytes4 interfaceId)
		public
		view
		override(CRC1155Enumerable, AccessControl)
		returns (bool)
	{
		return
			ERC1155.supportsInterface(interfaceId) ||
			interfaceId == type(IERC2981).interfaceId ||
			interfaceId == type(ICRC1155Enumerable).interfaceId;
	}

	function revertIfUriConflict(uint256 id, string memory tokenUri) internal view {
		if (exists(id)) {
			require(tokenUri.equals(_tokenUris[id]), "NFT: URI different with previous");
		}
	}
}
