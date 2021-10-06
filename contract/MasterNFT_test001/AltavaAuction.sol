// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.6;

import "./External.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract AltavaAuction is External{
  using Counters for Counters.Counter;
  Counters.Counter private _auctionId;
  Counters.Counter private _bidId;

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
    uint256 deadline;            // 1 경매 종료일
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
  mapping (address => uint[]) auctionRunByUser; // 해당 지갑이 가진 auction ID
  mapping (address => uint256) refunds; // 입찰자 지갑주소 => contract로 보낸 이더(BNB)
  /*  
    #1. 경매 생성
      - ( require ) 토큰 소유자 검증
      - return : 경매 ID
  */
  function createAuction
  (
    string calldata title,
    string calldata description,
    uint256 startingPrice,
    uint32 deadline,
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
    AuctionData memory ad = AuctionData(msg.sender, title, description, (block.timestamp + deadline*1 days + 7 days), startingPrice, reservePrice, tokenId, tokenAddress, 0);
    
    Auctions[auctionId] = ad; // 해당 경매 번호에 경매 정보 저장
    auctionRunByUser[msg.sender].push(auctionId); // 해당 지갑 주소에 경매 번호 저장
    // event : DB insert ?
    return auctionId;
  }

  /*  
    #2. 입찰
      - (require : isCurrentBid) = 현재 비딩금보다 비율이 1% 이상 높은지 확인
      - returns : 경매 번호 (  )
  */
  function ActionBid (uint auctionId, uint date)
    external
    payable
    returns(uint bidId)
  {
    require(Auctions[auctionId].seller != msg.sender, "The auction owner cannot bid."); // 경매 소유자 비딩 금지
    require(msg.value > (Auctions[auctionId].currentBid));
    // require 종료되지 않은 경매만가능
    // 
    _bidId.increment();
    bidId = _bidId.current();
    Bid memory bid = Bid(msg.sender, msg.value, date);
    BiddingForAuction[auctionId].push(bid);
    // 입찰시 bid amount 정보 저장 ( refund )
    refunds[msg.sender] += msg.value;

    // 상위 입찰시 기존 bid 환불

    return bidId;
  }

  /*  
    #3. 경매 완료
  */
  function EndAuction
  ()
    public

  {

  }
}