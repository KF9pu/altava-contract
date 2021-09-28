// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.6;

interface SaveData {
  function ownerOf(uint256 tokenId) external view returns(address);
  function GetType(uint tokenId) external view returns(uint);
}

contract Util {
  /* 
    #1. 토큰 소유자 확인
      - 외부 컨트랙트 주소와 토큰ID를 인자로 받아 다른 컨트랙트의 ownerOf함수 실행 (ERC-721 표준)
      - return : 해당 토큰의 소유자 주소
   */
  function tokenOwner (address _tokenAddress, uint _tokenId) internal view returns(address) {
    SaveData am = SaveData(_tokenAddress);
    return am.ownerOf(_tokenId);
  }
  
  /*  
    #2. 
  */
}