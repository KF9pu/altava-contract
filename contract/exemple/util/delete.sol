// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.6;

contract delete_Test {
    mapping (address => uint256[]) public owned1;
    mapping (address => mapping(uint => uint)) public owned2;
    uint256 index = 0;
    uint256 tokenID = 0;
    
    // array mapping
    function pushMappingOwned1 () 
      public
    {
      owned1[msg.sender].push(index);
      index+=2;
    }
    
    // Double mapping
    function pushMappingOwned2 () 
      public
    {
      owned1[msg.sender][tokenID] = index;
      index+=2;
      tokenID++;
    }
    
    // array last index delete
    function deleteArray ()
      public
    {
      owned1[msg.sender].pop();
    }
    
    // this tokenID mapping delete
    function deleteMapping (uint _tokenID)
      public
    {
      delete owned2[msg.sender][_tokenID];
    }
}