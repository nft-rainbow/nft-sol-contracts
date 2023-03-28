// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "./lib/ConfluxHelper.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract testSponsor is ConfluxHelper,Initializable {
	// sponsor when deploy erc721/erc1155 contracts
	uint public sponsorGas = 0.01 ether;
	uint public sponsorGasUpperBound = 0.00001 ether;
	uint public sponsorCollateral = 0.99 ether;

	receive() external payable {}

    function initialize() public initializer {
		_setWhiteListForAllUser();
	}

	function newAndSponsor() public {
		Empty e = new Empty();
		sponsor(address(e));
	}

	function sponsor(address addr) internal {
		_sponsor(addr, sponsorGas, sponsorGasUpperBound, sponsorCollateral);
	}
}

contract Empty {}
