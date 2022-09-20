// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./Constants.sol";

abstract contract GranularRoles is AccessControl {
	// Roles list
	// bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
	// bytes32 public constant MINT_ROLE = keccak256("MINT_ROLE");

	mapping(bytes32 => bool) internal _rolesFrozen;

	modifier onlyAdmin(){
		_checkRole(Constants.ADMIN_ROLE);
		_;
	}

	modifier onlyMinter(){
		_checkRole(Constants.MINT_ROLE);
		_;
	}

	function initalize() internal virtual {
		_setupRole(DEFAULT_ADMIN_ROLE, tx.origin);
		_setRoleAdmin(Constants.MINT_ROLE, Constants.ADMIN_ROLE);
	}

	function _initRoles(address[] memory owners) internal {
		for (uint256 i = 0; i < owners.length; i++) {
			_setupRole(Constants.MINT_ROLE, owners[i]);
			_setupRole(Constants.ADMIN_ROLE, owners[i]);
		}
	}

	function grantAdminRole(address user) public onlyAdmin {
		_setupRole(Constants.ADMIN_ROLE, user);
	}

	function grantMintRole(address user) public onlyAdmin {
		_setupRole(Constants.MINT_ROLE, user);
	}
}
