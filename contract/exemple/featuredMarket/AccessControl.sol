// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

/**
   @dev ERC165 탐지를 지원하도록 선언된 AccessControl의 외부 인터페이스입니다.
 */
interface IAccessControl {
    function hasRole(bytes32 role, address account) external view returns (bool);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function renounceRole(bytes32 role, address account) external;
}

/**
 * @dev 
  자녀가 역할 기반 액세스를 구현할 수 있는 계약 모듈
  제어 메커니즘. 역할 열거를 허용하지 않는 경량 버전입니다.
  계약 이벤트 로그에 액세스하여 오프체인 수단을 제외한 멤버. 썸
  애플리케이션은 온체인 열거성의 이점을 얻을 수 있습니다. 이러한 경우 참조
  {AccessControlEnumable}.
 
   역할은 'bytes32' 식별자로 참조됩니다. 이것들은 노출되어야 한다.
   외부 API에서 고유해야 합니다. 이것을 성취하는 가장 좋은 방법은
   '공개 상수' 해시 다이제스트 사용:
 
   ```
   bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
   ```
 
  역할은 권한 집합을 나타내는 데 사용할 수 있습니다. 함수 호출에 대한 액세스를 제한하려면 {hasRole}을(를) 사용하십시오.
 
   ```
   function foo() public {
       require(hasRole(MY_ROLE, msg.sender));
       ...
   }
   ```
 
  {grantRole}을(를) 통해 역할을 동적으로 부여 및 취소할 수 있습니다.
  {revokeRole} 함수입니다. 각 역할에는 연결된 관리자 역할만 있습니다.
  역할의 관리자 역할이 있는 계정은 {grantRole} 및 {revokeRole}을(를) 호출할 수 있습니다.
 
  기본적으로 모든 역할의 관리자 역할은 'DEFAULT_ADMIN_ROLE'이며, 이는 다음을 의미한다.
  이 역할을 가진 계정만 다른 계정을 허가하거나 취소할 수 있습니다.
  배역할 다음을 통해 보다 복잡한 역할 관계를 만들 수 있습니다.
  {_setRoleAdmin}.
 
  WARNING: 'DEFAULT_ADMIN_ROLE'도 자체 관리자이며, 다음과 같은 권한이 있습니다.
  이 역할을 부여 및 취소합니다. 보안을 위해 추가 예방 조치를 취해야 합니다.
  그것을 허가받은 account
*/

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev 
        'newAdminRole'이 '이전 AdminRole' 대신 '역할'의 관리자 역할로 설정될 때 방출됩니다.
        'DEFAULT_ADMIN_ROLE'은 모든 역할의 시작 관리자이지만 이 신호를 보내는 {RoleAdminChanged}이(가) 내보내지지 않습니다.
        _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
       @dev 
        계정'에 '역할'이 부여될 때 방출됩니다.
        'sender'는 {_setupRole}을(를) 사용하는 경우를 제외하고 관리자 역할 전달자인 계약 호출을 시작한 계정입니다.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
       @dev 
       계정'이 '역할' 취소될 때 방출됩니다.
      
       통화는 계약 콜의 발단이 된 계정이다.
        - revokeRole을 사용하는 경우 관리자 역할 전달자입니다.
        - renounceRole을 사용할 경우 역할 전달자(예: 계정)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
      @dev 계정에 특정 역할이 있는지 확인하는 수정자. 필요한 역할을 포함한 표준화된 메시지로 돌아갑니다.
     
      되돌리기 사유 형식은 다음 정규식으로 제공됩니다 :
     
       /^AccessControl: account (0x[0-9a-f]{20}) is missing role (0x[0-9a-f]{32})$/
     
      _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
      @dev 
      account에 role이 없으면 표준 메시지로 되돌립니다.
      되돌리기 사유 형식은 다음 정규식으로 제공됩니다.
     
       /^AccessControl: account (0x[0-9a-f]{20}) is missing role (0x[0-9a-f]{32})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if(!hasRole(role, account)) {
            revert(string(abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(uint160(account), 20),
                " is missing role ",
                Strings.toHexString(uint256(role), 32)
            )));
        }
    }

    /**
       @dev 
       '역할'을 제어하는 관리자 역할을 반환합니다. {grantRole} 및 {revokeRole}을(를) 참조하십시오.
       역할의 관리자를 변경하려면 {_setRoleAdmin}을(를) 사용하십시오.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
       @dev 
        '계정'에 '역할'을 부여합니다.

        'account'에 아직 'role'이 부여되지 않은 경우 {RoleGranted}을(를) 내보냅니다.
        사건을 일으키다

        요구사항:

        - 발신자는 ''역할''의 관리자 역할이 있어야 합니다.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
       @dev 
        account에서 '역할'을 취소합니다.
        'account'에 'role'이 부여된 경우 {RoleRevoked} 이벤트를 발생시킵니다.
        require: - 발신자는 ''역할''의 관리자 역할이 있어야 합니다.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
       @dev 
        호출 계정에서 '역할'을 취소합니다.

        역할은 종종 {grantRole} 및 {revokeRole}을(를) 통해 관리됨: 이 함수의
        목적은 계정이 그들의 특권을 잃는 메커니즘을 제공하는 것이다.
        손상된 경우(예: 신뢰할 수 있는 장치가 잘못 배치된 경우).

        호출 계정에 '역할'이 부여된 경우 {RoleRevoked}을(를) 내보냅니다.
        사건을 일으키다

        require:

        - 발신자는 반드시 'account'
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
       @dev 
       '계정'에 'role'을 부여합니다.

        'account'에 아직 'role'이 부여되지 않은 경우 {RoleGranted}을(를) 내보냅니다.
        사건을 일으키다 {grantRole}과 달리 이 함수는 어떤 작업도 수행하지 않습니다.
        착신 계좌 수표

        [WARNING]
        ====
        이 함수는 설정할 때만 생성자에서 호출해야 합니다.
        시스템의 초기 역할을 수행합니다.

        이 기능을 다른 방법으로 사용하면 관리자를 효과적으로 우회할 수 있습니다.
        시스템이 {AccessControl}에 의해 부과되었습니다.
        ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
       @dev 
        adminRole을 ''역할''의 관리자 역할로 설정합니다.
        {RoleAdminChanged} 이벤트를 내보냅니다.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}
