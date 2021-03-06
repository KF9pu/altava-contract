// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract AltavaMint is ERC721URIStorage {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  constructor() ERC721("ALTAVA NFT", "ALTAVA"){ 
    owner = msg.sender;
  }

  struct AltavaNFT {
    string ModelCode;
    uint Royalty;
    uint tokenType; // 0 : masterNFT, 1 : pairNFT
  }

  address public owner; // contract 소유자
  
  AltavaNFT[] public AltavaNFTs; // MasterNFT 정보 저장
  mapping (uint => uint) getMasterTokenId; // pairTokenId => MasterTokenId 매핑

  /*  
    # contract 소유자 검증
  */
  modifier isOwner (){
    require(owner == msg.sender, "The caller's address is different from the contract owner.");
    _;
  }

  /*  
    # master token 검증
  */
  modifier isMasterToken (uint256 tokenId){
    require(AltavaNFTs[tokenId].tokenType==0, "It's not a master token.");
    _;
  }


  /* 
    #1-0. MasterNFT Mint
      - 마스터 토큰 mint
        배열객체에 생성된 토큰 저장, Mint 수익 배분율 설정, ModelCode 설정
      - return : 토큰 id
  */
  function CreateNFT (string memory tokenURI, string memory modelCode, uint32 royalty) 
    public 
    isOwner()
    returns (uint)
  {
    _tokenIds.increment();
    uint256 tokenId = _tokenIds.current();

    AltavaNFTs.push(AltavaNFT(modelCode, royalty, 0));

    _setTokenURI(tokenId, tokenURI);
    _safeMint(msg.sender, tokenId);
    return tokenId;
  }
  
  /*  
    #1-1. PairNFT Mint
      - 하위 페어 토큰 mint
      - (modifier : isOwner) = 메소드 호출자가 컨트랙트 소유자인지 확인
      - (modifier : isMasterToken) = 민트하려는 토큰이 마스터 토큰인지 확인
      - return : 토큰 id
  */
  function CreateNFT (string calldata tokenURI, string calldata modelCode, uint256 masterId)
    public
    isOwner()
    isMasterToken(masterId)
    returns (uint pairId)
  {
    _tokenIds.increment();
    uint256 tokenId = _tokenIds.current();

    AltavaNFTs.push(AltavaNFT(modelCode, 0, 1));
    getMasterTokenId[pairId] = masterId;

    _setTokenURI(tokenId, tokenURI);
    _safeMint(msg.sender, tokenId);
    return tokenId;
  }

  /*  
    #1-2. test mint
       - 경매기능 확인용 민트
  */
  function CreateNFT (string calldata modelCode) 
    public
    isOwner()
    returns (uint)
  {
    _tokenIds.increment();
    uint256 tokenId = _tokenIds.current();

    AltavaNFTs.push(AltavaNFT(modelCode, 0, 0));
    _safeMint(msg.sender, tokenId);
    return tokenId;
  }


  /*  
    #2. get token type
      - 해당 토큰의 토큰타입 출력
        0 : master NFT
        1 : pair NFT
  */
  function GetType (uint tokenId) 
    public
    view
    returns (uint tokenType)
  {
    tokenType = AltavaNFTs[tokenId].tokenType;
    return tokenType;
  }

  /* 
    #4. 
  */













  /* 개발 해야하는 기능
    # 
  */
}
