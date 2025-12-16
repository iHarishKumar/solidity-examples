// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {MyOwnableContract} from "../src/Ownable2/MyOwnableContract.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MyOwnableContractTest is Test {
    MyOwnableContract public ownableContract;
    address public owner = address(0x1);
    address public newOwner = address(0x2);
    address public nonOwner = address(0x3);

    event OwnershipTransferStarted(
        address indexed previousOwner,
        address indexed newOwner
    );
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function setUp() public {
        vm.startPrank(owner);
        ownableContract = new MyOwnableContract();
        vm.stopPrank();
    }

    function test_InitialState() view public {
        assertEq(ownableContract.owner(), owner);
        assertEq(ownableContract.pendingOwner(), address(0));
        assertEq(ownableContract.message(), "Hello, world!");
    }

    function test_SetMessage_AsOwner() public {
        string memory newMessage = "New message";
        vm.prank(owner);
        ownableContract.setMessage(newMessage);

        assertEq(ownableContract.message(), newMessage);
    }

    function test_SetMessage_RevertIfNotOwner() public {
        string memory newMessage = "Should fail";
        vm.prank(nonOwner);

        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                nonOwner
            )
        );
        ownableContract.setMessage(newMessage);
    }

    function test_TransferOwnership() public {
        // Start ownership transfer
        vm.prank(owner);
        ownableContract.transferOwnership(newOwner);

        assertEq(ownableContract.owner(), owner);
        assertEq(ownableContract.pendingOwner(), newOwner);

        // Accept ownership
        vm.prank(newOwner);
        vm.expectEmit(true, true, false, true);
        emit OwnershipTransferred(owner, newOwner);
        ownableContract.acceptOwnership();

        assertEq(ownableContract.owner(), newOwner);
        assertEq(ownableContract.pendingOwner(), address(0));
    }

    function test_TransferOwnership_RevertIfNotOwner() public {
        vm.prank(nonOwner);
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                nonOwner
            )
        );
        ownableContract.transferOwnership(newOwner);
    }

    function test_AcceptOwnership_RevertIfNotPendingOwner() public {
        // Start transfer
        vm.prank(owner);
        ownableContract.transferOwnership(newOwner);

        // Try to accept from wrong address
        vm.prank(nonOwner);
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                nonOwner
            )
        );
        ownableContract.acceptOwnership();
    }

    function test_RenounceOwnership() public {
        vm.prank(owner);
        ownableContract.renounceOwnership();

        assertEq(ownableContract.owner(), address(0));
    }

    function test_RenounceOwnership_RevertIfNotOwner() public {
        vm.prank(nonOwner);
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                nonOwner
            )
        );
        ownableContract.renounceOwnership();
    }
}
