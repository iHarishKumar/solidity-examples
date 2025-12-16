// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {RoleBasedContract} from "../src/AccessControl/RoleBasedContract.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

contract RoleBasedContractTest is Test {
    RoleBasedContract public roleBasedContract;
    address public admin = address(1);
    address public manager = address(2);
    address public user = address(3);

    // Events to test for
    event RoleGranted(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    function setUp() public {
        // Deploy the contract with admin as the initial admin
        vm.startPrank(admin);
        roleBasedContract = new RoleBasedContract(admin);
        vm.stopPrank();
    }

    // Test initial setup
    function test_InitialSetup() public view {
        // Check that admin has DEFAULT_ADMIN_ROLE
        assertTrue(
            roleBasedContract.hasRole(
                roleBasedContract.DEFAULT_ADMIN_ROLE(),
                admin
            )
        );

        // Check that initial value is 0
        assertEq(roleBasedContract.value(), 0);
    }

    // Test setting value with manager role
    function test_SetValueAsManager() public {
        // Grant manager role to manager address
        vm.startPrank(admin);
        roleBasedContract.grantManager(manager);
        vm.stopPrank();

        // Set value as manager
        uint256 newValue = 42;
        vm.startPrank(manager);
        roleBasedContract.setValue(newValue);
        vm.stopPrank();

        // Check if value was updated
        assertEq(roleBasedContract.value(), newValue);
    }

    // Test setting value without manager role should revert
    function test_SetValueWithoutManagerRole() public {
        // Try to set value as non-manager (user)
        vm.startPrank(user);
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector,
                user,
                roleBasedContract.MANAGER_ROLE()
            )
        );
        roleBasedContract.setValue(42);
        vm.stopPrank();
    }

    // Test granting manager role as admin
    function test_GrantManagerRole() public {
        // Grant manager role to manager address
        vm.startPrank(admin);

        // Expect RoleGranted event to be emitted
        vm.expectEmit(true, true, true, true);
        emit RoleGranted(roleBasedContract.MANAGER_ROLE(), manager, admin);

        roleBasedContract.grantManager(manager);

        // Check if manager has the role
        assertTrue(
            roleBasedContract.hasRole(roleBasedContract.MANAGER_ROLE(), manager)
        );
    }

    // Test granting manager role as non-admin should revert
    function test_GrantManagerRoleAsNonAdmin() public {
        // Try to grant manager role as non-admin (user)
        vm.startPrank(user);
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector,
                user,
                roleBasedContract.DEFAULT_ADMIN_ROLE()
            )
        );
        roleBasedContract.grantManager(manager);
        vm.stopPrank();
    }

    // Test setting value after being granted and then revoked manager role
    function test_SetValueAfterRoleRevocation() public {
        // Grant manager role
        vm.startPrank(admin);
        roleBasedContract.grantManager(manager);
        vm.stopPrank();

        // Revoke manager role
        vm.startPrank(admin);
        roleBasedContract.revokeRole(roleBasedContract.MANAGER_ROLE(), manager);
        vm.stopPrank();

        // Try to set value after role revocation
        vm.startPrank(manager);
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector,
                manager,
                roleBasedContract.MANAGER_ROLE()
            )
        );
        roleBasedContract.setValue(42);
        vm.stopPrank();
    }

    // Test that admin can directly grant roles using AccessControl
    function test_AdminCanGrantRolesDirectly() public {
        // Admin grants manager role directly using AccessControl
        vm.startPrank(admin);
        roleBasedContract.grantRole(roleBasedContract.MANAGER_ROLE(), manager);
        vm.stopPrank();

        // Manager should be able to set value
        vm.startPrank(manager);
        roleBasedContract.setValue(100);

        assertEq(roleBasedContract.value(), 100);
        vm.stopPrank();
    }
}
