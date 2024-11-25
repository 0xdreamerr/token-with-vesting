// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "./_.TokenWithVesting.Setup.sol";
import {TokenWithVesting} from "src/TokenWithVesting.sol";

contract TokenTest is Test, TokenWithVestingSetup {
    function setUp() public override {
        super.setUp();
        _receiver = userB;
    }

    function testFuzz_transferBeforeCliff(uint8 amount) public {
        vm.assume(amount > 0);

        vm.startPrank(owner);
        tokenWithVesting.assignVested(
            _receiver,
            _amount,
            _start,
            _cliff,
            _vested,
            _revokable
        );

        vm.warp(10);

        // trying to transfer tokens before _cliff
        vm.startPrank(userB);
        vm.expectRevert(
            abi.encodeWithSignature(
                "NotEnoughUnlockedTokens(address,uint256)",
                userB,
                0
            )
        );

        tokenWithVesting.transfer(owner, amount);
    }

    function testFuzz_transferAfterCliff(uint8 amount) public {
        vm.startPrank(owner);
        tokenWithVesting.assignVested(
            _receiver,
            _amount,
            _start,
            _cliff,
            _vested,
            _revokable
        );

        vm.warp(21);

        vm.startPrank(userB);
        uint initialBalance = tokenWithVesting.balanceOf(userB);
        tokenWithVesting.transfer(owner, amount);
        uint finalBalance = tokenWithVesting.balanceOf(userB);

        assertEq(initialBalance, finalBalance + amount);
        assertEq(tokenWithVesting.balanceOf(owner), amount);
    }

    function testFuzz_mint(uint8 amount) public {
        uint256 initialBalance = tokenWithVesting.balanceOf(userB);

        vm.startPrank(owner);
        tokenWithVesting.mint(userB, amount);

        uint256 finalBalance = tokenWithVesting.balanceOf(userB);

        assert(finalBalance == initialBalance + amount);
    }

    function testFuzz_zeroAddress(uint8 amount) public {
        vm.startPrank(owner);
        tokenWithVesting.assignVested(
            _receiver,
            _amount,
            _start,
            _cliff,
            _vested,
            _revokable
        );

        vm.warp(21);

        vm.startPrank(userB);
        vm.expectRevert(TokenWithVesting.WrongAddress.selector);
        tokenWithVesting.transfer(address(0), amount);
    }

    function testFuzz_mintOnZeroAddress(uint8 amount) public {
        vm.startPrank(owner);

        vm.expectRevert(TokenWithVesting.WrongAddress.selector);
        tokenWithVesting.mint(address(0), amount);
    }
}
