// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.6;

import './AltavaUtil.sol';

contract AltavaAuction is AltavaUtil{
  struct Bid {
    address bidder;
    uint256 amount;
    uint bidDate;
  }
  
  /* 
    Pending  : 보류중
    Active   : 활성
    Inactive : 비활성
  */
  enum AuctionStatus {
    Pending, 
    Active, 
    Inactive
  }

  struct Auction {
    AuctionStatus status;       // 0 auction status
    address seller;             // 0 seller adress
    string title;               // 1 auction title
    string description;         // 1 auction description
    uint256 deadline;           // 1 경매 종료일
    uint256 startingPrice;      // 1 경매 시작가
    uint256 reservePrice;       // 1 경매 최소 금액 ( 이가격보다 비딩이 작으면 경매 취소[선택 || 강제] )
    address tokenAddress;       // 1 판매중인 token contract 주소
    uint256 currentBid;         // 0 현재 비딩 금액
  }
  
  Auction[] public auctions; // 경매 배열
  Bid[] public bids;
  mapping(address => uint[]) public aunctionByUser; // 해당 유저의 경매 생성 내역
  mapping(uint => Bid[]) public BidsByAuction; // 경매에 비딩된 비딩 정보

  /* 
    #1. 경매 생성
      - 경매 객체 생성
      - return : 경매번호
  */
  function createAuction
  (
    string calldata title,
    string calldata description,
    uint deadline,
    uint256 startingPrice,
    uint256 reservePrice,
    address tokenAddress,
    uint256 tokenId
  )
    public 
    returns (uint auctionId)
  { 
    require (tokenOwner(tokenAddress, tokenId)==msg.sender, "Token owners are different."); // 토큰 소유자인지 확인
    auctions.push(Auction(AuctionStatus.Pending, msg.sender, title, description, deadline, startingPrice, reservePrice, tokenAddress, startingPrice));
    auctionId = auctions.length-1;
    aunctionByUser[msg.sender].push(auctionId);
    return auctionId;
  }


  /* 
    # 경매 정보 조회
      - 해당 경매 번호의 경매 정보 출력
      - return : 경매 정보
   */
  function getAuction(uint index)
    public
    view
    returns (
      AuctionStatus status,
      address seller,
      string memory title,
      string memory description,
      uint256 deadline,
      uint256 startingPrice,
      uint256 reservePrice,
      address tokenAddress,
      uint256 currentBid
    )
  {
    Auction memory a = auctions[index];
    return (
      a.status,
      a.seller,
      a.title,
      a.description,
      a.deadline,
      a.startingPrice,
      a.reservePrice,
      a.tokenAddress,
      a.currentBid
    );
  }
  
  /* 
    # 경매 시작
      - 해당 경매 status 변경
      - return : 없음
   */
  function StartAuction(uint index)
    public
  {
    require(auctions[index].seller==msg.sender, "Not the auction owner.");
    auctions[index].status = AuctionStatus.Active;
  }

  
  /* 
    - 경매 취소
    - 경매 종료
    - 비딩
    - 상위 비딩시 환불, 경매 reservePrice 미달시 취소 후 환불, 경매 취소 시 환불
    - 해당 경매 비딩 정보 리턴
    - 모든 경매 정보 리턴 ( 경매 리스트 업 )

  
   */
}