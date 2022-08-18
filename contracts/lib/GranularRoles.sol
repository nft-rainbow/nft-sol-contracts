// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

abstract contract GranularRoles is AccessControl {
	// Roles list
	bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
	bytes32 public constant MINT_ROLE = keccak256("MINT_ROLE");
	
	mapping(bytes32 => bool) internal _rolesFrozen;


	function initalize() virtual internal {
		_setupRole(DEFAULT_ADMIN_ROLE,msg.sender);
		_setRoleAdmin(MINT_ROLE, ADMIN_ROLE);
	}

	function _initRoles(address[] memory owners) internal {
		for (uint256 i = 0; i < owners.length; i++) {
			_setupRole(MINT_ROLE, owners[i]);
			_setupRole(ADMIN_ROLE, owners[i]);
		}
	}

	function grantAdminRole(address user) public onlyRole(ADMIN_ROLE) {
		_setupRole(ADMIN_ROLE, user);
	}

	function grantMintRole(address user) public onlyRole(ADMIN_ROLE) {
		_setupRole(MINT_ROLE, user);
	}
}
