// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.6;

import './AltavaMint.sol';

contract AltavaAuction is AltavaMint {
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
    AuctionStatus status;       // 경매 상태
    address seller;             // 판매자 지갑주소
    string title;               // 경매 제목
    string description;         // 경매 내용
    uint256 deadline;           // 경매 종료일
    uint256 startingPrice;      // 경매 시작가
    uint256 reservePrice;       // 경매 최소 금액 ( 이가격보다 비딩이 작으면 경매 취소[선택 || 강제] )
    uint256 currentBid;         // 현재 비딩 금액
    address contractAddress;    // 판매중인 token contract 주소
    Bid[] bids;                 // 비딩 정보
  }
  
  Auction[] public auctions; // 경매 배열
  mapping(address => uint[]) public aunctionByUser; // 해당 유저의 진행중인 옥션 번호(배열)
  mapping(address => uint[]) public auctionsBidOnByUser; // 해당 유저의 비딩중인 옥션 번호(배열)
  mapping(address => uint) refunds; // 경매 종료전 비딩금액 (낙찰되지 않을 경우 반환)
  
  function createAuction
  (
    string calldata title,
    string calldata description,
    uint256 deadline,
    uint256 startingPrice,
    uint256 reservePrice,
    uint256 currentBid,
    address contractAddress
  )
    public 
    returns (uint auctionId)
  { 
    auctionId = auctions.length + 1;
    Auction memory  a = auctions[auctionId];
    a.status = AuctionStatus.Pending;
    a.seller = msg.sender;
    a.title = title;
    a.description = description;
    a.deadline = deadline;
    a.startingPrice = startingPrice;
    a.reservePrice = reservePrice;
    a.currentBid = currentBid;
    a.contractAddress = contractAddress;
    aunctionByUser[msg.sender].push(auctionId);
    return auctionId;
  }
  
  function startAuction() 
    public
  {
    
  }
  
  function endAuction() 
    public
  {
      
  }

  function cancelAuction(uint auctionId) 
    public 
    returns (bool)
  {
    Auction memory a = auctions[auctionId];
      
    return true;  
  }  
  
  function placeBid(uint auctionId) public payable returns (bool success) {
    uint256 amount = msg.value;
    Auction memory a = auctions[auctionId];
    
    require(a.currentBid >= amount);
    
    uint bidIdx = a.bids.length + 1;
    Bid memory b = a.bids[bidIdx];
    b.bidder = msg.sender;
    b.amount = amount;
    b.bidDate = block.timestamp;
    a.currentBid = amount;
    
    auctionsBidOnByUser[b.bidder].push(auctionId);
    
    if (bidIdx > 0) {
      Bid memory previousBid = a.bids[bidIdx - 1];
      refunds[previousBid.bidder] += previousBid.amount;
    }
    return true;
  }
  
  function withdrawRefund
  (
    address payable _to
  )
  public
  {
    uint refund = refunds[msg.sender];
    refunds[msg.sender] = 0;
    if (!_to.send(refund))
        refunds[msg.sender] = refund;
  }  
}