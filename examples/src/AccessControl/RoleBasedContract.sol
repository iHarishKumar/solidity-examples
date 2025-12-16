// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract RoleBasedContract is AccessControl {
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    uint256 public value;

    constructor(address admin) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }

    function setValue(uint256 _value) external onlyRole(MANAGER_ROLE) {
        value = _value;
    }

    function grantManager(address account)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _grantRole(MANAGER_ROLE, account);
    }
}
