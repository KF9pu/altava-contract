// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "./IERC721Standard.sol";

contract ERC721Standard is Context, AccessControl, ERC721Enumerable, ERC721Burnable {
    uint256 public currentTokenId;

    bytes4 public constant ROYALTY_INTERFACE = bytes4(keccak256("ROYALTY_INTERFACE"));
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 constant MAX_FEE_ADDRESSES = 10;

    mapping (uint256 => string) public uri;
    mapping (uint256 => uint256[]) public fees;
    mapping (uint256 => address[]) public feeAddresses;

    uint256 public constant UNIT = 1e18;

    constructor(
      string memory _name,
      string memory _symbol
    ) ERC721(_name, _symbol) {
      _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
      _setupRole(MINTER_ROLE, _msgSender());
    }

    // ========== ADMIN FUNCTIONS ==========
 
    function mint(
      address _to,
      string memory _uri,
      address[] memory _feeAddresses,
      uint256[] memory _fees
    ) external virtual {
      require(hasRole(MINTER_ROLE, _msgSender()), "Only minter");
      _safeMint(_to, _uri, _feeAddresses, _fees);
    }

    function batchMint(
      address[] memory _to,
      string[] memory _uri,
      address[][] memory _feeAddresses,
      uint256[][] memory _fees
    ) external {
      require(hasRole(MINTER_ROLE, _msgSender()), "Only minter");
      require(_to.length == _uri.length && _to.length == _feeAddresses.length && _to.length == _fees.length, "Invalid params");
      for(uint256 i = 0; i < _to.length; i++) {
          _safeMint(_to[i], _uri[i], _feeAddresses[i], _fees[i]);
      }
    }

    function setFeeAddress(
      uint256 _tokenId,
      uint256 _addressPosition,
      address _feeAddress
    ) external virtual {
      require(_feeAddress != address(0));
      require(_msgSender() == feeAddresses[_tokenId][_addressPosition], "Invalid account");
      feeAddresses[_tokenId][_addressPosition] = _feeAddress;
    }

    // ========== VIEW FUNCTIONS ==========

    function tokenURI(
        uint256 _tokenId
        ) public view virtual override returns (string memory) {
        return uri[_tokenId];
    } 

    function getFeeAddresses(
        uint256 _tokenId
    ) external view returns(address[] memory) {
        return feeAddresses[_tokenId];
    }

    function getFees(
        uint256 _tokenId
    ) external view returns(uint256[] memory) {
        return fees[_tokenId];
    }

    function getFeeInfo(
        uint256 _tokenId
    ) external view returns (address[] memory, uint[] memory){
        return (feeAddresses[_tokenId], fees[_tokenId]);
    }

    function supportsInterface(
        bytes4 _interfaceId
        ) public view virtual override(ERC721, ERC721Enumerable, AccessControl) returns (bool) {

            
        return _interfaceId == ROYALTY_INTERFACE ||
         super.supportsInterface(_interfaceId);
    }

    // ========== INTERNAL FUNCTIONS ==========

    function _safeMint(
        address _to,
        string memory _uri,
        address[] memory _feeAddresses,
        uint256[] memory _fees
        ) internal {
        require(_feeAddresses.length == _fees.length, "Invalid fee lengths");
        require(_feeAddresses.length <= MAX_FEE_ADDRESSES, "Too many fees");
        require(bytes(_uri).length > 0, "Invalid URI");

        uint256 feeTotal;

        for (uint256 i = 0; i < _fees.length; i++) {
            require(_feeAddresses[i] != address(0), "Invalid fee address");
            feeTotal += _fees[i];
        }

        require(feeTotal <= UNIT, "Invalid fee");

        super._safeMint(_to, currentTokenId);

        uri[currentTokenId] = _uri;
        feeAddresses[currentTokenId] = _feeAddresses;
        fees[currentTokenId] = _fees;
        currentTokenId++;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
        ) internal virtual override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }
}