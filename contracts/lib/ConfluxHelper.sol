// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@confluxfans/contracts/utils/ERC1820Context.sol";
import "@confluxfans/contracts/InternalContracts/InternalContractsLib.sol";

contract ConfluxHelper is ERC1820Context {
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
		InternalContracts.SPONSOR_CONTROL.addPrivilege(users);
		require(InternalContracts.SPONSOR_CONTROL.isWhitelisted(address(this), user), "failed to set white list");
	}

	function _setWhiteListForAllUser() internal {
		_setWhiteListForUser(address(0));
	}
}
