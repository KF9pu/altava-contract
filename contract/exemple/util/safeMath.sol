// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract ERC721Altava {
    using SafeMath for uint256;
    uint256 public _currentTokenId;
    
    function _getNextTokenId() private view returns (uint256) {
        return _currentTokenId.add(1);
    }
}