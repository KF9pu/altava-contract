// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./Modifier.sol";

contract Save001 is ERC721URIStorage {
  struct AlvataNFT {
    string ModelCode;
    uint MasterTokenId;
    uint PairTokenId;
    uint Royalty;
    /* 
      MasterTokenId == PairTokenId && 마스터 토큰
      MasterTokenId != pairTokenId && 해당 마스터 토큰에 대한 PairToken
    */
  }
  struct Pair {

  }
  
  address public owner; // contract 소유자
  AlvataNFT[] public AlvataNFTs; // Token 정보 저장
  
  constructor() ERC721("ALTAVA NFT", "ALTAVA"){ 
    owner = msg.sender;
  }
  
  /* 
    #1. Master Token Mint
      - 배열객체에 생성된 토큰 저장, Mint 수익 배분율 설정, ModelCode 설정
  */
  function CreateNFT (string memory tokenURI, string memory modelCode, uint royalty) 
    public 
    isOwner(owner)
    returns (uint)
  {
    uint256 nftId = AlvataNFTs.length;
    AlvataNFTs.push(AlvataNFT(modelCode, nftId, nftId, royalty));
    
    _setTokenURI(nftId, tokenURI);
    _safeMint(msg.sender, nftId);
    return nftId;
  }

  /* 
    #2. Pair Token Mint
      - 
  */
  function CreateNFT (string memory tokenURI, string memory modelCode)
    public
    
  {

  }

  /*  
    #3. pair 토큰 권한 지갑 등록 ( 1회성 )
      - Pair Token 생성가능하도록 아이디 등록 ( 컨트랙트 소유자만 권한 부여 가능 ), 
        master NFT 1개당 다른회사에서 Mint는 1번씩 제한 ( 이미 회사명이 등록되어 있으면 수정 )
        기업명 등록 > 구조체 배열 매핑 > 
  */
  function PairApproval (string memory name, string memory modelCode)
    public
    isOwner(owner)
  {

  }


  /* 
    # fallback 기본 함수
      - 
  */
  fallback (){

  }


  /* 개발 해야하는 기능

    # 
  */
}
