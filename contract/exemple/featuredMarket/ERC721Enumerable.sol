// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

/**
    @dev 
    이렇게 하면 EIP에 정의된 {ERC721}의 선택적 확장이 구현되어 계약의 모든 토큰 ID와 각 계정이 소유한 모든 토큰 ID의 열거성이 추가됩니다.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // 소유자에서 소유 토큰 ID 목록으로 매핑
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // 토큰 ID에서 소유자 토큰 목록의 인덱스로 매핑
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // 열거에 사용되는 모든 토큰 ID가 있는 배열
    uint256[] private _allTokens;

    // 토큰 ID에서 allTokens 배열의 위치로 매핑
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /**
      @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.

    */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds"); // index가 owner의 계정 에 있는 토큰 수 보다 작아야 true : 클경우 out bounds
        return _ownedTokens[owner][index];
    }

    /**
      @dev See {IERC721Enumerable-totalSupply}.
    */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
      @dev See {IERC721Enumerable-tokenByIndex}.
    */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
      @dev 
        토큰 전송 전에 호출되는 후크입니다. 여기에는 {minting} 및 굽기가 포함됩니다. 통화 조건:
        from과 to가 모두 0이 아닐 때 from의 tokenId는 to로 옮겨진다.
        - from이 0일 때 tokenId는 to로 주조된다.
        - to가 0이면 from의 tokenId가 타버린다.
        - 'from'은 0 주소가 될 수 없습니다.
        - 'to'는 0 주소가 될 수 없습니다. 후크에 대해 자세히 알아보려면 xref로 이동하십시오.
        ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev 이 확장의 토큰 추적 데이터 구조에 토큰을 추가하는 private function입니다.
     * @param tokenId uint256 토큰 목록에 추가할 토큰의 ID
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
      @dev 
        이 확장의 소유권 추적 데이터 구조에서 토큰을 제거하는 개인 함수입니다. 
        토큰에 새 소유자가 할당되지 않은 경우 '_소유됨TokensIndex 매핑이 업데이트되지 않음: 
          전송 작업을 수행할 때(중복 쓰기를 피함) 가스 최적화를 허용합니다. 이 작업은 O(1)시간 복잡성을 가지지만 {_ownedTokens} 배열의 순서를 변경합니다.
      @param from 지정된 토큰 ID의 이전 소유자를 나타내는 주소
      @param tokenId 지정된 주소의 토큰 목록에서 제거할 토큰의 uint256 ID
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // 토큰 배열과의 격차를 방지하기 위해 삭제할 토큰의 색인에 마지막 토큰을 저장합니다. 그리고 마지막 슬롯(마지막 슬롯 및 팝)을 삭제합니다.

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // 삭제할 토큰이 마지막 토큰인 경우 스왑 작업이 불필요함
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // 마지막 토큰을 삭제할 토큰의 슬롯으로 이동
            _ownedTokensIndex[lastTokenId] = tokenIndex; // 이동한 토큰 인덱스 업데이트
        }

        // 이렇게 하면 배열의 마지막 위치에 있는 내용도 삭제됩니다.
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
      @dev
        이 확장의 토큰 추적 데이터 구조에서 토큰을 제거하는 개인 함수입니다.
        이 경우 O(1)시간의 복잡성이 있지만 _allTokens 배열의 순서가 변경됩니다.
      @param tokenId 토큰 목록에서 제거할 토큰의 uint256 ID
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // 토큰 배열의 공백을 방지하기 위해 삭제할 토큰 색인에 마지막 토큰을 저장한 다음 마지막 슬롯(스왑 및 팝)을 삭제합니다.

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        /* 
          삭제할 토큰이 마지막 토큰이면 스왑 작업이 필요하지 않지만 이러한 현상이 매우 드물기 때문에 스왑을 계속합니다 ('if' 문을 추가하는 데 드는 가스 비용을 피하기 위해)
          (예: _removeTokenFromOwnerEnumeration).
        */
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // 마지막 토큰을 삭제할 토큰의 슬롯으로 이동
        _allTokensIndex[lastTokenId] = tokenIndex; // 이동한 토큰 인덱스 업데이트

        // 이렇게 하면 배열의 마지막 위치에 있는 내용도 삭제됩니다.
        delete _allTokensIndex[tokenId];
        _allTokens.pop(); //배열에서 마지막 요소를 제거합니다.이렇게 하면 배열 길이가 1개 줄어듭니다.
    }
}
