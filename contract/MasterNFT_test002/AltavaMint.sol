// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract AltavaMint is ERC721URIStorage{
  constructor () ERC721("", "BrandName") {
    
  }
  

  // master token
  function CreateToken(string calldata tokenURI, string calldata modelCode, uint royalty)
    external
    returns (uint tokenId)
  {
    
  }

  // pair token
  function CreateToken(string calldata tokenUTI, uint masterTokenId)
    external
  {
      
  }

  // test token
  function CreateToken()
    external
  {
      
  }
}