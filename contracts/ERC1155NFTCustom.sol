// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract ERC1155NFTCustom is ERC1155, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    using Strings for uint256;

    string public name;
    string public symbol;
    string public baseURI;

    mapping(uint256 => uint256) public tokenSupply;
    mapping(uint256 => string) private _tokenURIs;

    constructor(
        string memory _uri,
        string memory _name,
        string memory _symbol,
        address owner
    ) ERC1155(_uri) {
        baseURI = _uri;

        name = _name;
        symbol = _symbol;

        _setupRole(MINTER_ROLE, owner);
    }

    function setURI(string memory _newURI) public onlyRole(MINTER_ROLE) {
        _setURI(_newURI);
    }

    function totalSupply(uint256 _id) public view returns (uint256) {
        return tokenSupply[_id];
    }

    function uri(uint256 _id) public view override returns (string memory) {
        if (bytes(_tokenURIs[_id]).length > 0) {
            if (bytes(baseURI).length > 0) {
                return string(abi.encodePacked(baseURI, _tokenURIs[_id]));
            } else {
                return _tokenURIs[_id];
            }
        } else {
            return super.uri(_id);
        }
    }

    function mintTo(
        address account, 
        uint256 id, 
        string memory tokenUri
    ) public onlyRole(MINTER_ROLE) returns (uint256) {
        mintTo(account, id, 1, tokenUri);
        return id;
    }

    function mintTo(
        address account,
        uint256 id,
        uint256 amount,
        string memory _uri
    ) public onlyRole(MINTER_ROLE) {
        require(!_exists(id), "NFT: token already minted");
        if (bytes(_uri).length > 0) {
            _tokenURIs[id] = _uri;
            emit URI(_uri, id);
        }
        _mint(account, id, amount, "");
        tokenSupply[id] += amount;
    }

    function mintToBatch(
        address[] memory to,
        uint256[] memory ids,
        uint256[] memory amounts,
        string[] memory uris
    ) public onlyRole(MINTER_ROLE) {
        for (uint256 i = 0; i < ids.length; i++) {
            require(!_exists(ids[i]), "NFT: one of tokens are already minted");
            require(
                to[i] == address(to[i]),
                "NFT: one of addresses is invalid"
            );
            require(amounts[i] > 0, "NFT: all amounts must be > 0");
            tokenSupply[ids[i]] += amounts[i];
            if (bytes(uris[i]).length > 0) {
                _tokenURIs[ids[i]] = uris[i];
                emit URI(uris[i], ids[i]);
            }
            _mint(to[i], ids[i], amounts[i], "");
        }
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return ERC1155.supportsInterface(interfaceId);
    }

    function _exists(uint256 _tokenId) internal view virtual returns (bool) {
        return tokenSupply[_tokenId] > 0;
    }
}
