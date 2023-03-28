// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@confluxfans/contracts/utils/ERC1820Context.sol";
import "@confluxfans/contracts/InternalContracts/InternalContractsLib.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./Constants.sol";

contract ConfluxHelper is ERC1820Context, AccessControl {
	using EnumerableSet for EnumerableSet.AddressSet;

	address public constant ZERO = address(0);
	EnumerableSet.AddressSet sponsorWhitelist;

	function _setWhiteListForUser(address user) internal {
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
		for (uint256 i = 0; i < whites.length; i++) {}
		InternalContracts.SPONSOR_CONTROL.removePrivilege(whites);
		for (uint256 i = 0; i < whites.length; i++) {
			require(!hasRole(Constants.ADMIN_ROLE, whites[i]), "NFT: could not remove admin");
			sponsorWhitelist.remove(whites[i]);
		}
	}

	function listSponsorPrivilege() public view returns (address[] memory) {
		return sponsorWhitelist.values();
	}

	function _sponsor(address addr, uint gas, uint gasUpperbound, uint collateral) internal {
		if (!_isCfxChain()) {
			return;
		}
		require(address(this).balance > 0, "need deposit");

		require(gas>=gasUpperbound*1000,"gas < upper bound * 1000");

		address spnsorForGas = InternalContracts.SPONSOR_CONTROL.getSponsorForGas(addr);
		address spnsorForColl = InternalContracts.SPONSOR_CONTROL.getSponsorForCollateral(addr);

		require(spnsorForGas == address(0), "has sponsored gas user");
		require(spnsorForColl == address(0), "has sponsored coll user");

		uint sponsorGasBalance = InternalContracts.SPONSOR_CONTROL.getSponsoredBalanceForGas(addr);
		uint sponsorCollBalance = InternalContracts.SPONSOR_CONTROL.getSponsoredBalanceForCollateral(addr);

		require(sponsorGasBalance == 0, "has sponsored gas balance");
		require(sponsorCollBalance == 0, "has sponsored coll balance");

		InternalContracts.SPONSOR_CONTROL.setSponsorForGas{ value: gas }(addr, gasUpperbound);
		InternalContracts.SPONSOR_CONTROL.setSponsorForCollateral{ value: collateral }(addr);
	}
}
