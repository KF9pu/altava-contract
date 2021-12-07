// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

/* 
  
*/
interface IERC721Altava {
  function mint(address _to, string memory _uri, address[] memory _feeAddresses, uint256[] memory _fees) external;
  function hasRole(bytes32 role, address account) view external returns(bool);
  function getFeeInfo(uint256 tokenId) external returns(address[] memory, uint256[] memory);
  function getFeeAddresses(uint256 tokenId) external returns(address[] memory);
  function getFees(uint256 tokenId) external returns(uint256[] memory);
}