// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract ERC721NFTCustom is ERC721Enumerable, ERC721URIStorage, AccessControl {
	bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

	constructor(
		string memory name,
		string memory symbol,
		address owner
	) ERC721(name, symbol) {
		_setupRole(MINTER_ROLE, owner);
	}

	function mintTo(
		address to,
		uint256 tokenId,
		string memory tokenUri
	) public onlyRole(MINTER_ROLE) {
		_mint(to, tokenId);
		_setTokenURI(tokenId, tokenUri);
	}

	function _beforeTokenTransfer(
		address from,
		address to,
		uint256 tokenId
	) internal override(ERC721, ERC721Enumerable) {
		super._beforeTokenTransfer(from, to, tokenId);
	}

	function _burn(uint256 tokenId) internal override(ERC721URIStorage, ERC721) {
		super._burn(tokenId);
	}

	function tokenURI(uint256 tokenId) public view override(ERC721URIStorage, ERC721) returns (string memory) {
		return super.tokenURI(tokenId);
	}

	function supportsInterface(bytes4 interfaceId)
		public
		view
		override(AccessControl, ERC721, ERC721Enumerable)
		returns (bool)
	{
		return
			interfaceId == type(IERC721).interfaceId ||
			interfaceId == type(IERC721Metadata).interfaceId ||
			interfaceId == type(IAccessControl).interfaceId ||
			interfaceId == type(IERC721Enumerable).interfaceId ||
			super.supportsInterface(interfaceId);
	}
}
