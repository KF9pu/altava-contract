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

}