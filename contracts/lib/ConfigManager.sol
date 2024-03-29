// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "./Config.sol";
import "./GranularRoles.sol";
import "./Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Constants.sol";

contract ConfigManager is GranularRoles {
	using Strings for uint256;

	uint16 internal constant ROYALTIES_BASIS = 10000;

	// The contract owner address. If you wish to own the contract, then set it as your wallet address.
	// This is also the wallet that can manage the contract on NFT marketplaces.
	// address owner;
	// If true, tokens may be burned by owner. Cannot be changed later.
	// bool public tokensBurnable;
	// Metadata base URI for tokens, NFTs minted in this contract will have metadata URI of `baseURI` + `tokenID`.
	// Set this to reveal token metadata.
	// string baseURI;
	// If true, the base URI of the NFTs minted in the specified contract can be updated after minting (token URIs
	// are not frozen on the contract level). This is useful for revealing NFTs after the drop. If false, all the
	// NFTs minted in this contract are frozen by default which means token URIs are non-updatable.
	bool public metadataUpdatable;
	// If true, tokens may be transferred by owner. Default is true. Can be only changed to false.
	bool public tokensTransferableByAdmin;
	// If true, tokens may be transferred by user. Default is true. Can be only changed to false or true.
	bool public tokensTransferableByUser;

	// Secondary market royalties in basis points (100 bps = 1%)
	uint256 public royaltiesBps;
	// Address for royalties
	address public royaltiesAddress;

	event PermanentURIGlobal();
	// event BurnableChanged(bool burnable);
	event TransferableChanged(bool transferableByAdmin, bool transferableByUser);
	event RoyaltyUpdated(uint256 royaltiesBps, address royaltiesAddress);

	function initalize() internal virtual override {
		super.initalize();
		metadataUpdatable = true;
		tokensTransferableByAdmin = true;
		tokensTransferableByUser = true;
	}

	// function _setTokensBurnable(bool burnable) internal {
	// 	tokensBurnable = burnable;
	// 	emit BurnableChanged(burnable);
	// }

	function _setTokensTransferable(bool transferableByAdmin, bool transferableByUser) internal {
		tokensTransferableByAdmin = transferableByAdmin;
		tokensTransferableByUser = transferableByUser;
		emit TransferableChanged(transferableByAdmin, transferableByUser);
	}

	function tokensBurnable() public view returns(bool){
		return tokensTransferableByAdmin;
	}

	function _setRoyalties(uint256 _royaltiesBps, address _royaltiesAddress) internal {
		royaltiesBps = _royaltiesBps;
		royaltiesAddress = _royaltiesAddress;
		emit RoyaltyUpdated(royaltiesBps, royaltiesAddress);
	}

	// function setTokensBurnable(bool burnable) public onlyRole(Constants.ADMIN_ROLE) {
	// 	_setTokensBurnable(burnable);
	// }

	function setTokensTransferable(
		bool transferableByAdmin,
		bool transferableByUser
	) public onlyRole(Constants.ADMIN_ROLE) {
		if (transferableByAdmin) {
			require(tokensTransferableByAdmin, "transfer by admin can be only changed to false");
		}
		_setTokensTransferable(transferableByAdmin, transferableByUser);
	}

	function setRoyalties(uint256 _royaltiesBps, address _royaltiesAddress) public onlyRole(Constants.ADMIN_ROLE) {
		_setRoyalties(_royaltiesBps, _royaltiesAddress);
	}

	function freezeGlobalMetadata() public onlyRole(Constants.ADMIN_ROLE) {
		require(!metadataUpdatable, "Metadata already frozen globally");
		metadataUpdatable = false;
		emit PermanentURIGlobal();
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
}
