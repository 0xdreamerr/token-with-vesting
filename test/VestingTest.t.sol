// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test} from "forge-std/Test.sol";
import {Script, console} from "forge-std/Script.sol";
import {TokenWithVesting} from "src/TokenWithVesting.sol";

contract VestingTest is Test {
    TokenWithVesting public tokenWithVesting;
    address private owner;
    address private userB;

    string name;
    string symbol;
    uint256 totalSupply;

    function setUp() public {
        owner = address(0x1);
        userB = address(0x2);
        name = "DREAMERR";
        symbol = "DRMR";
        totalSupply = 100000;

        vm.startPrank(owner);
        tokenWithVesting = new TokenWithVesting(name, symbol, totalSupply);
        vm.stopPrank();
    }

    function testFuzz_createVesting(uint8 amount) public {
        address receiver = address(userB);
        uint64 start = 10;
        uint64 cliff = 10;
        uint64 vested = 20;
        bool revokable = false;

        vm.startPrank(owner);
        tokenWithVesting.assignVested(
            receiver,
            amount,
            start,
            cliff,
            vested,
            revokable
        );
        vm.stopPrank();

        vm.warp(25);

        assertEq(amount, tokenWithVesting.balanceOf(userB));
        assertEq(1, tokenWithVesting.vestingsLengths(userB));
    }

    function test_revokeVesting() public {
        address receiver = address(userB);
        uint amount = 1000;
        uint64 start = 10;
        uint64 cliff = 10;
        uint64 vested = 20;
        bool revokable = true;

        vm.startPrank(owner);
        tokenWithVesting.assignVested(
            receiver,
            amount,
            start,
            cliff,
            vested,
            revokable
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

    function test_transferBeforeCliff() public {
        address receiver = address(userB);
        uint amount = 5000;
        uint64 start = 10;
        uint64 cliff = 20;
        uint64 vested = 40;
        bool revokable = true;

        vm.startPrank(owner);
        tokenWithVesting.assignVested(
            receiver,
            amount,
            start,
            cliff,
            vested,
            revokable
        );

        vm.warp(15);

        // waiting for custom error
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
        address receiver = address(userB);
        uint64 start = 10;
        uint64 cliff = 20;
        uint64 vested = 40;
        bool revokable = true;

        vm.startPrank(owner);
        tokenWithVesting.assignVested(
            receiver,
            amount,
            start,
            cliff,
            vested,
            revokable
        );

        vm.warp(45);

        vm.startPrank(userB);
        tokenWithVesting.transfer(owner, amount);

        assertEq(tokenWithVesting.balanceOf(userB), 0);
        assertEq(tokenWithVesting.balanceOf(owner), amount);
    }

    function testFuzz_mint(uint128 amount) public {
        uint256 initialBalance = tokenWithVesting.balanceOf(userB);

        vm.startPrank(owner);
        tokenWithVesting.mint(userB, amount);

        uint256 finalBalance = tokenWithVesting.balanceOf(userB);

        assert(finalBalance == initialBalance + amount);
    }
}
