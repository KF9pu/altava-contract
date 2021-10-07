// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.6;

contract DoubleMapping {
  struct doubleMapData {
    mapping (address => bool) members;
    bytes32 Role;
  }

  mapping (bytes32 => doubleMapData) _roles;

  function setDoubleMap (string calldata str)
    public
  {
    bytes32 role = keccak256(abi.encodePacked(str));
    setMembers(role);
    setRole(role);
  }

  function setMembers (bytes32 role)
    private
  {
    _roles[role].members[msg.sender] = true;
  }

  function setRole (bytes32 role)
    private
  {
    _roles[role].Role = 0x00;
  }

  function getMembers (string calldata str) 
    public
    view
    returns (bool)
  {
    bytes32 role = keccak256(abi.encodePacked(str));
      
    return _roles[role].members[msg.sender];
  }

  function getRole (string calldata str)
    public
    view
    returns (bytes32)
  {
    bytes32 role = keccak256(abi.encodePacked(str));
    return _roles[role].Role;
  }
}