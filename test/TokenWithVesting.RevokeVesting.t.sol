// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "./_.TokenWithVesting.Setup.sol";
import {TokenWithVesting} from "src/TokenWithVesting.sol";

contract RevokeVestingTest is Test, TokenWithVestingSetup {
    function setUp() public override {
        super.setUp();
        _receiver = userB;
    }

    function test_revokeVesting() public {
        vm.startPrank(owner);
        tokenWithVesting.assignVested(
            _receiver,
            _amount,
            _start,
            _cliff,
            _vested,
            _revokable
        );

        uint initialVestingCount = tokenWithVesting.vestingsLengths(userB);
        vm.warp(15);

        tokenWithVesting.revokeVesting(userB, 0);

        uint finalVestingCount = tokenWithVesting.vestingsLengths(userB);
        uint userBalance = tokenWithVesting.balanceOf(userB);

        assertEq(finalVestingCount, initialVestingCount - 1);
        assertEq(userBalance, 500);
        assertEq(
            tokenWithVesting.balanceOf(address(tokenWithVesting)),
            totalSupply - 500
        );
    }

    function test_vestingNotExist() public {
        // expecting custom error
        vm.expectRevert(TokenWithVesting.NoVesting.selector);
        tokenWithVesting.revokeVesting(userB, 0);
    }

    function test_notRevokable() public {
        _revokable = false;

        vm.startPrank(owner);
        tokenWithVesting.assignVested(
            _receiver,
            _amount,
            _start,
            _cliff,
            _vested,
            _revokable
        );

        vm.expectRevert(TokenWithVesting.VestingNotRevokable.selector);
        tokenWithVesting.revokeVesting(userB, 0);
    }
}
