// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@confluxfans/contracts/InternalContracts/SponsorWhitelistControl.sol";
import "@confluxfans/contracts/InternalContracts/AdminControl.sol";

contract ContractSponsorInfo {
	AdminControl constant ac = AdminControl(0x0888000000000000000000000000000000000000);
    SponsorWhitelistControl constant spc = SponsorWhitelistControl(0x0888000000000000000000000000000000000001);
    
    struct SponsorInfo {
		uint256 gasBalance;
		address gasSponsor;
		uint256 gasFeeUpperBound;
		address collateralSponsor;
		uint256 collateralBalance;
		bool isAllWhiteListed;
        address contractAdmin;
        bool isContract;
	}

	function getSponsorInfos(address[] memory addresses) public view returns (SponsorInfo[] memory) {
		SponsorInfo[] memory SponsorInfos = new SponsorInfo[](uint(addresses.length));

		for (uint i = 0; i < addresses.length; i++) {
			SponsorInfos[i] = getSponsorInfo(addresses[i]);
		}

		return SponsorInfos;
	}

	function getSponsorInfo(address target) public view returns (SponsorInfo memory) {
        if (!isContract(target)) {
            SponsorInfo memory empty;
		    return empty;
        }

		address gasSponsor = spc.getSponsorForGas(target);
		uint256 gasBalnce = spc.getSponsoredBalanceForGas(target);
		uint256 gasFeeUpperBound = spc.getSponsoredGasFeeUpperBound(target);
		address collateralSponsor = spc.getSponsorForCollateral(target);
		uint256 collateralBalance = getSponsoredBalanceForCollateral(target);
		bool isAllWhiteListed = spc.isAllWhitelisted(target);
        address admin = ac.getAdmin(target);

		return SponsorInfo(
			gasBalnce,
			gasSponsor,
			gasFeeUpperBound,
			collateralSponsor,
			collateralBalance,
			isAllWhiteListed,
            admin,
            true
		);
	}

    function getSponsoredBalanceForCollateral(address target) public view returns (uint256) {
        uint256 sponsorBalance = spc.getSponsoredBalanceForCollateral(target);
        uint256 availablePoints = spc.getAvailableStoragePoints(target);
        return sponsorBalance + availablePoints / 1024 * 1 ether;
    }

	function isContract(address addr) private view returns (bool) {
		uint size;
		assembly {
			size := extcodesize(addr)
		}
		return size > 0;
	}
}
