// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.6;

contract Modifier {
  /*  
    #1. contract 소유자 검증
  */
  modifier isOwner (address owner){
    require(owner == msg.sender, "The caller's address is different from the contract owner.");
    _;
  }

  /*  
    #2. 경매 소유자 확인 ( 경매 소유자는 비딩 금지 )
  */
  modifier isAuctionOwner (address auctionOwner){
    require(auctionOwner != msg.sender, "The auction owner cannot bid.");
    _;
  }
}