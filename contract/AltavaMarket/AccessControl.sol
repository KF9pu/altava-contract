// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
import '@openzeppelin/contracts/utils/Context.sol';
import '@openzeppelin/contracts/utils/introspection/ERC165.sol';
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

abstract contract AccessControl is IAccessControl, Context, ERC165 {
  struct RoleData {
    mapping (address => bool) members;
    bytes32 adminRole;
  }

  /* 
    Role => RoleData mapping
  */
  mapping (bytes32 => RoleData) private _roles;

  /** 
    @dev
      msg.sender 가 role권한을 가지고 있는지 확인
  */
  modifier onlyRole(bytes32 role) {
    _checkRole(role, _msgSender());
    _;
  }

  
  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return interfaceId == type(IAccessControl).interfaceId
      || super.supportsInterface(interfaceId);
  }
  function _checkRole(bytes32 role, address account) 
    public
  {

  }

  function hasRole(bytes32 role, address account)
    public
    view
    override
    returns (bool)
  {

  }

  function getRoleAdmin(bytes32 role)
    public
    view
    override
    returns (bytes32)
  {
    
  }
  
  function grantRole(bytes32 role, address account) 
    public
    view
    override
  {

  }
  function revokeRole(bytes32 role, address account)
    public
    view
    override
  {

  }
  function renounceRole(bytes32 role, address account)
    public
    view
    override
  {

  }
}