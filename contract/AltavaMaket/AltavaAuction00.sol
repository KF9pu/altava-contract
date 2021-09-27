// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.6;

contract AltavaAuction00 {
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

  /* 
    # 경매 생성
      - 경매 객체 생성
      - 
      - return : 경매번호
    
  */
  function createAuction(
    string calldata _title,
    string calldata _description,
    uint256 _deadline,
    uint256 _startingPrice,
    uint256 _reservePrice,
    address _tokenAddress,
    address _tokenId
  )
    public
    returns(uint auctionId)
  {
    (bool success, bytes memory data) = _tokenAddress.call(
      abi.encodeWithSignature("ownerOf(uint256)", _tokenId)
    );
    auctionId = auctions.length + 1;
    Auction memory auction = auctions[auctionId];

    auction.status = AuctionStatus.Pending;
    auction.seller = msg.sender;
    auction.title = _title;
    auction.description = _description;
    auction.deadline = _deadline;
    auction.startingPrice = _startingPrice;
    auction.reservePrice = _reservePrice;
    auction.tokenAddress = _tokenAddress;
  }
  // 경매 시작
  // 경매 취소
  // 경매 종료 ( reservePrice 미달시 선택 취소 가능 )
  // 비딩 
  // 상위 비딩시 환불, 경매 reservePrice 미달시 취소 후 환불, 경매 취소 시 환불
}