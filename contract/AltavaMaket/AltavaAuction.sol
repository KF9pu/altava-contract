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
    AuctionStatus status;       // 0 auction status
    address seller;             // 0 seller adress
    string title;               // 1 auction title
    string description;         // 1 auction description
    uint256 deadline;           // 1 경매 종료일
    uint256 startingPrice;      // 1 경매 시작가
    uint256 reservePrice;       // 1 경매 최소 금액 ( 이가격보다 비딩이 작으면 경매 취소[선택 || 강제] )
    address tokenAddress;       // 1 판매중인 token contract 주소
    Bid[] bids;                 // 0 비딩 정보
    uint256 currentBid;         // 0 현재 비딩 금액
  }
  
  Auction[] public auctions; // 경매 배열
  mapping(address => uint[]) public aunctionByUser; // 해당 유저의 진행중인 옥션 번호(배열)
  mapping(address => uint[]) public auctionsBidOnByUser; // 해당 유저의 비딩중인 옥션 번호(배열)
  mapping(address => uint) refunds; // 경매 종료전 비딩금액 (낙찰되지 않을 경우 반환)

  // Events
  event AuctionCreated(uint id, string title, uint256 startingPrice, uint256 reservePrice); // 경매 생성시 발생
  event AuctionActivated(uint id); // 경매 시작시 발생
  event AuctionCancelled(uint id); // 경매 취소시 발생
  event BidPlaced(uint auctionId, address bidder, uint256 amount); // 비딩시 발생 ( 이번 비드 환불 ? )
  event AuctionEndedWithWinner(uint auctionId, address winningBidder, uint256 amount); // 낙찰자가 있는 경매 종료
  event AuctionEndedWithoutWinner(uint auctionId, uint256 topBid, uint256 reservePrice); // 낙찰자가 없는 경매 종료

  // 경매 생성
  function createAuction
  (
    string calldata title,
    string calldata description,
    uint256 deadline,
    uint256 startingPrice,
    uint256 reservePrice,
    address tokenAddress
  )
    public 
    returns (uint auctionId)
  { 
    // msg.sender 와 토큰 owner 와 같은지 확인 ( tokenId 필요 )
    auctionId = auctions.length + 1;
    Auction memory  a = auctions[auctionId];
    a.status = AuctionStatus.Pending;
    a.seller = msg.sender;
    a.title = title;
    a.description = description;
    a.deadline = deadline;
    a.startingPrice = startingPrice;
    a.reservePrice = reservePrice;
    a.currentBid = startingPrice;
    a.tokenAddress = tokenAddress;
    aunctionByUser[msg.sender].push(auctionId);
    AuctionCreated(auctionId, a.title, a.startingPrice, a.reservePrice);
    return auctionId;
  }
  
  // 경매 시작 - status ( pending -> Active )
  function startAuction(uint auctionId) 
    public
  {
    // seller 확인 
    Auction a = auctions[auctionId];
    a.status = AuctionStatus.Active;
    AuctionActivated(auctionId);
    require();
  }
  
  // 경매 종료 - status ( Active -> Inactive )
  function endAuction(uint auctionId) 
    public
  {
    // seller 확인 && 날자 확인 
    Auction a = auctions[auctionId];
    a.status = AuctionStatus.Inactive;
    AuctionActivated(auctionId);
  }

  // 경매 취소 - status ( Active -> pending )
  function cancelAuction(uint auctionId) 
    public 
    returns (bool)
  {
    Auction memory a = auctions[auctionId];
    a.status = AuctionStatus.Pending;
    AuctionActivated(auctionId);
    return true;  
  }  
  
  // 비드
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
  
  // 낙찰되지 않은 비드 환불
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

  function strConcat(string _a, string _b) internal returns (string) {
    bytes memory _ba = bytes(_a);
    bytes memory _bb = bytes(_b);
    bytes memory ab = new bytes (_ba.length + _bb.length);
    uint k = 0;
    for (uint i = 0; i < _ba.length; i++) ab[k++] = _ba[i];
    for (i = 0; i < _bb.length; i++) ab[k++] = _bb[i];
    return string(ab);
  }
  function addrToString(address x) returns (string) {
    bytes memory b = new bytes(20);
    for (uint i = 0; i < 20; i++)
        b[i] = bytes(uint8(uint(x) / (2**(8*(19 - i)))));
    return string(b);
  }
}