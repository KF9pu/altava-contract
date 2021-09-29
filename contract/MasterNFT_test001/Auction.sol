// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.6;

import "./External.sol";
import "./Modifier.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Auction is External, Modifier{
  using Counters for Counters.Counter;
  Counters.Counter private _auctionId;

  /* 
    #2. Token Auction
    #3. Distribution of profits
    #4. 
  */

  // auction 데이터 형식
  struct AuctionData {
    address seller;             // 0 seller adress
    string title;               // 1 auction title
    string description;         // 1 auction description
    uint32 deadline;            // 1 경매 종료일
    uint256 startingPrice;      // 1 경매 시작가
    uint256 reservePrice;       // 1 경매 최소 금액 ( 이가격보다 비딩이 작으면 경매 취소[선택 || 강제] )
    uint256 tokenId;            // 1 판매하는 토큰 ID 값
    address tokenAddress;       // 1 판매중인 token contract 주소
    uint256 currentBid;         // 0 현재 비딩 금액
  }

  // Bid 데이터 형식
  struct Bid {
    address bidder;             // 입찰자
    uint256 amount;             // 입찰금액
    uint bidDate;               // 입찰일
  }

  mapping (uint => AuctionData) Auctions; // 경매 ID => 경매 정보
  mapping (uint => Bid[]) BiddingForAuction; // 경매 ID => 해당 경매의 모든 비딩

  /*  
    #1. 경매 생성
      - ( require ) 토큰 소유자 검증
      - return : 경매 ID
  */
  function createAuction
  (
    string calldata title,
    string calldata description,
    uint32 deadline,
    uint256 startingPrice,
    uint256 reservePrice,
    uint256 tokenId, 
    address tokenAddress
  )
    public
    returns (uint256 auctionId)
  {
    require(tokenOwner(tokenAddress, tokenId)==msg.sender, "Token owners are different.");
    _auctionId.increment();
    auctionId = _auctionId.current();
    AuctionData memory ad = AuctionData(msg.sender, title, description, deadline, startingPrice, reservePrice, tokenId, tokenAddress, 0);
    
    Auctions[auctionId] = ad;
    // event : DB insert ?
    return auctionId;
  }

  /*  
    #2. 입찰
      - (modifier) 경매 소유자 비딩 금지 
      - 
  */
  function ActionBid (uint auctionId)
    public
    payable
    isAuctionOwner(Auctions[auctionId].seller)
    returns(uint)
  {
    Bid memory bid = Bid(msg.sender, msg.value, block.timestamp);
    BiddingForAuction[auctionId].push(bid);

  }


}