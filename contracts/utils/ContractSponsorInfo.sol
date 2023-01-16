// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@confluxfans/contracts/InternalContracts/SponsorWhitelistControl.sol";

contract ContractSponsorInfo {
    struct SponsorInfo{
        uint256 gasBalnce;
        address gasSponsor;
        uint256 gasFeeUpperBound;
        address collateralSponsor;
        uint256 collateralBalance;
        bool    isAllWhiteListed;
    }

    SponsorWhitelistControl cpc = SponsorWhitelistControl(0x0888000000000000000000000000000000000001);

    function getSponsorInfos(
        address[] memory addresses
    )public view returns (SponsorInfo[] memory){
        SponsorInfo[] memory SponsorInfos = new SponsorInfo[](uint(addresses.length));

        for (uint i = 0; i < addresses.length; i ++) {
            require(isContract(addresses[i]));
            SponsorInfos[i] = getSponsorInfo(addresses[i]);
        }

        return SponsorInfos;
    }

    function getSponsorInfo(
        address target
    )public view returns (SponsorInfo memory){
        require(isContract(target), "The address should be contract address");

        address gasSponsor = cpc.getSponsorForGas(target);
        uint256 gasBalnce  = cpc.getSponsoredBalanceForGas(target);
        uint256 gasFeeUpperBound = cpc.getSponsoredGasFeeUpperBound(target);
        address collateralSponsor = cpc.getSponsorForCollateral(target);
        uint256 collateralBalance = cpc.getSponsoredBalanceForCollateral(target);
        bool    isAllWhiteListed  = cpc.isAllWhitelisted(target);
        SponsorInfo memory res    = SponsorInfo(
            gasBalnce,
            gasSponsor,
            gasFeeUpperBound,
            collateralSponsor,
            collateralBalance,
            isAllWhiteListed
            );
        return res;
    }

    function isContract(address addr) private view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
   }
}
