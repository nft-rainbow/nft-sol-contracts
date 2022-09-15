// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@confluxfans/contracts/utils/ERC1820Context.sol";
import "@confluxfans/contracts/InternalContracts/InternalContractsLib.sol";
import "./GranularRoles.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract ConfluxHelper is ERC1820Context, AccessControl {
	using EnumerableSet for EnumerableSet.AddressSet;

	address public constant ZERO = address(0);
	EnumerableSet.AddressSet sponsorWhitelist;

	function _setWhitelistByAdmin(address targetContract, address user) internal {
		if (!_isCfxChain()) {
			return;
		}

		address[] memory users = new address[](1);
		users[0] = user;
		InternalContracts.SPONSOR_CONTROL.addPrivilegeByAdmin(targetContract, users);
	}

	function _setWhiteListForUser(address user) internal {
		if (!_isCfxChain()) {
			return;
		}
		address[] memory users = new address[](1);
		users[0] = user;
		_addSponsorPrivilege(users);
	}

	function _setWhiteListForAllUser() internal {
		_setWhiteListForUser(address(0));
	}

	function _setAdminToNone(address contractAddr) internal {
		InternalContracts.ADMIN_CONTROL.setAdmin(contractAddr, ZERO);
		require(InternalContracts.ADMIN_CONTROL.getAdmin(contractAddr) == ZERO, "failed to set admin to none");
	}

	function _addSponsorPrivilege(address[] memory whites) internal {
		if (!_isCfxChain()) {
			return;
		}
		InternalContracts.SPONSOR_CONTROL.addPrivilege(whites);
		for (uint256 i = 0; i < whites.length; i++) {
			sponsorWhitelist.add(whites[i]);
			require(
				InternalContracts.SPONSOR_CONTROL.isWhitelisted(address(this), whites[i]),
				"failed to set white list"
			);
		}
	}

	function _removeSponsorPrivilege(address[] memory whites) internal {
		if (!_isCfxChain()) {
			return;
		}
		InternalContracts.SPONSOR_CONTROL.removePrivilege(whites);
		for (uint256 i = 0; i < whites.length; i++) {
			sponsorWhitelist.remove(whites[i]);
		}
	}

	function listSponsorPrivilege() public view returns (address[] memory) {
		return sponsorWhitelist.values();
	}
}
