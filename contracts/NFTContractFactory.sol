// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721NFT.sol";
import "./ERC721NFTCustom.sol";
import "./ERC1155NFT.sol";
import "./ERC1155NFTCustom.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import "@confluxfans/contracts/InternalContracts/InternalContractsLib.sol";
import "@confluxfans/contracts/InternalContracts/SponsorWhitelistControl.sol";
import "@confluxfans/contracts/utils/ERC1820Context.sol";

contract ConfluxHelper is ERC1820Context {
    function setWhitelist(address targetContract, address user) public {
        if (!_isCfxChain()) {
            return;
        }

        address[] memory users = new address[](1);
        users[0] = user;
        InternalContracts.SPONSOR_CONTROL.addPrivilegeByAdmin(
            targetContract,
            users
        );
    }
}

contract NFTContractFactory is AccessControl, ConfluxHelper, Initializable {
    bytes32 public constant ROLE_OWNER = keccak256("ROLE_OWNER");

    event ContractCreated(ContractType contractType, address contractAddress);

    enum ContractType {
        ERC721,
        ERC721Custom,
        ERC1155
    }

    constructor() {
        _grantRole(ROLE_OWNER, msg.sender);
    }

    function initialize() public initializer {
        _grantRole(ROLE_OWNER, msg.sender);
    }

    function changeOwner(address newOwner) public onlyRole(ROLE_OWNER) {
        _revokeRole(ROLE_OWNER, msg.sender);
        _grantRole(ROLE_OWNER, newOwner);
    }

    function newERC721(address subOwner) public onlyRole(ROLE_OWNER) {
        address addr = address(new ERC721NFT(subOwner));
        setWhitelist(addr, address(0));
        emit ContractCreated(ContractType.ERC721, addr);
    }

    function newERC721Custom(
        string memory name,
        string memory symbol,
        address subOwner
    ) public onlyRole(ROLE_OWNER) {
        address addr = address(new ERC721NFTCustom(name, symbol, subOwner));
        setWhitelist(addr, address(0));
        emit ContractCreated(ContractType.ERC721Custom, address(addr));
    }

    function newERC1155(
        string memory uri,
        string memory name,
        string memory symbol,
        address subOwner
    ) public onlyRole(ROLE_OWNER) {
        address addr = address(new ERC1155NFT(uri, name, symbol, subOwner));
        setWhitelist(addr, address(0));
        emit ContractCreated(ContractType.ERC1155, address(addr));
    }

    function newERC1155Custom(
        string memory uri,
        string memory name,
        string memory symbol,
        address subOwner
    ) public onlyRole(ROLE_OWNER) {
        address addr = address(new ERC1155NFTCustom(uri, name, symbol, subOwner));
        setWhitelist(addr, address(0));
        emit ContractCreated(ContractType.ERC1155, address(addr));
    }
}
