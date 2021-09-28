// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.6;

interface AltavaMint {
  function ownerOf(uint256 tokenId) external view returns(address);
}

contract AltavaUtil {
  /* 
    #1. 토큰 소유자 확인
      - 외부 컨트랙트 주소와 토큰ID를 인자로 받아 다른 컨트랙트의 ownerOf함수 실행 (ERC-721 표준)
      - return : 해당 토큰의 소유자 주소
   */
  function tokenOwner (address _tokenAddress, uint _tokenId) internal view returns(address) {
    AltavaMint am = AltavaMint(_tokenAddress);
    return am.ownerOf(_tokenId);
  }

  function strConcat(string calldata _a, string calldata _b) internal pure returns (string memory) {
    bytes memory _ba = bytes(_a);
    bytes memory _bb = bytes(_b);
    bytes memory ab = new bytes (_ba.length + _bb.length);
    uint k = 0;
    for (uint i = 0; i < _ba.length; i++) ab[k++] = _ba[i];
    for (uint i = 0; i < _bb.length; i++) ab[k++] = _bb[i];
    return string(ab);
  }

}