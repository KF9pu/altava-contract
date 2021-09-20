// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract AltavaMint is ERC721URIStorage {
  struct AlvataNFT {
    string name;
    string data1;
  }
  address public owner;
  AlvataNFT[] public AlvataNFTs;
  
  constructor() ERC721("ALTAVA NFT", "ALTAVA"){ 
    owner = msg.sender;
  }    
  
  modifier isOwner(){
    require(owner == msg.sender);
    _;
  }
  
  function createNFT(address account, string memory tokenURI) 
    public 
    isOwner
    returns (uint)
  {
    uint256 nftId = AlvataNFTs.length;
    
    _setTokenURI(nftId, tokenURI);
    _safeMint(account, nftId);
    return nftId;
  }
}
