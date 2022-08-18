// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

abstract contract GranularRoles is AccessControl {
	// Roles list
	// Admin role can have 2 addresses:
	// one address same as (_owner) which can be changed
	// one for NFTPort API access which can only be revoked
	bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
	// Following roles can have multiple addresses, can be changed by admin or update contrac role
	bytes32 public constant MINT_ROLE = keccak256("MINT_ROLE");
	
	mapping(bytes32 => bool) internal _rolesFrozen;


	function initalize() virtual internal {
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
