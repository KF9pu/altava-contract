// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
   @dev 주소 유형과 관련된 함수 모음
 */
library Address {
    /**
       @dev 'account'가 계약인 경우 true를 반환합니다.
      
       [IMPORTANT]
       ====
        이 함수가 반환하는 주소를 가정하는 것은 안전하지 않습니다.
        거짓은 계약이 아닌 외부 소유 계정(EOA)입니다.

        그 중에서도 isContract는 다음과 같이 거짓으로 반환된다.
        주소 유형:

        - an externally-owned account 외부 소유 계정
        - a contract in construction 건설 계약
        - an address where a contract will be created 계약이 작성되는 주소
        - an address where a contract lived, but was destroyed 계약서가 살았지만 파기된 주소
       ====
     */
    function isContract(address account) internal view returns (bool) {
        /* 
            이 방법은 extcodesize에 의존하는데, extcodesize는 생성자 실행의 끝에 코드가 저장되기 때문에 생성 중인 계약에 대해 0을 반환한다.
        */
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
       @dev 
        Solidity의 이전을 대체하는 것: 
          사용 가능한 모든 가스를 전달한 후 오류가 발생하면 반환하는 '수령자'에게 '금액' 웨이(wei)를 보낸다. 
          https://eips.ethereum.org/EIPS/eip-1884[EIP1884]는 특정 운영코드의 가스비를 인상해 양도가 부과하는 가스제한량(2300)을 초과해 양도로 자금을 받을 수 없게 만들 가능성이 있다. {sendValue}은(는) 이 제한을 제거합니다.

          https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[자세히 알아보세요.

          중요: 
            제어가 '환원'으로 전환되므로 재진입 취약성이 발생하지 않도록 주의해야 합니다. 
        
        
        {ReentrancyGuard} 또는 https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[부정 효과-상호작용 패턴]을 사용하는 것이 좋습니다.
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
       @dev 
          낮은 수준의 'call'을 사용하여 Solidity 함수 호출을 수행합니다. 일반 호출은 안전하지 않은 함수 호출입니다. 대신 이 함수를 사용하십시오.
         
          'target'이 되돌리는 이유로 되돌아가는 경우, 이 함수에 의해 거품이 일어난다(일반 Solidity 함수 호출과 같이). 
          원시 반환 데이터를 반환합니다. 
          예상 수익 값으로 변환하려면, 
          use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
         
          Requirements:
         
          - `target` 은 contract 이어야 합니다.
          - target을 data로 호출하면 되돌릴 수 없습니다.
         
          _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
       @dev {xref-Address-functionCall-address-bytes-}[''functionCall']과 동일하지만 'target'이(가) 반환될 때 'errorMessage'가 대체 이유로 표시됩니다.
      
       _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
    @dev {xref-Address-functionCall-address-bytes-}['functionCall']과 동일하지만 'value' wei를 'target'으로 전송하기도 합니다.
    
      Requirements:
       - 콜계약은 ETH 잔액이 최소한 'value' 이상이어야 한다.
       - solidity 함수는 'payable'이어야 한다.
    
    _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
    @dev 
      {xref-Address-functionCallWithValue-bytes-uint256-}['''functionCallWithValue']와 동일하지만 'target'이(가) 반환될 때 대체 이유로 'errorMessage'가 있습니다.
           
    _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
    @dev 
      {xref-Address-functionCall-address-bytes-}[''functionCall')과 동일하지만 정적 호출을 수행합니다.

    _Available since v3.3._
    */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
    @dev 
      {xref-Address-functionCall-address-bytes-string-}['functionCall')과 동일하지만 정적 호출을 수행합니다. 

    _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
    @dev 
      {xref-Address-functionCall-address-bytes-}['functionCall')과 동일하지만 대리자 호출을 수행합니다.

    _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
    @dev 
      {xref-Address-functionCall-address-bytes-string-}['functionCall')과 동일하지만 대리자 호출을 수행합니다.

    _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // 되돌리기 이유를 찾고 있는 경우 버블업
            if (returndata.length > 0) {
                // 되돌리는 이유를 버블링하는 가장 쉬운 방법은 어셈블리를 통해 메모리를 사용하는 것입니다.

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
