// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "./_.TokenWithVesting.Setup.sol";
import {TokenWithVesting} from "src/TokenWithVesting.sol";

contract TokenTest is Test, TokenWithVestingSetup {
    function setUp() public override {
        super.setUp();
        _receiver = userB;
    }

    function testFuzz_RevertIf_TransferBeforeCliff(uint8 amount) public {
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

        skip(9);

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

    function testFuzz_transferAfterVested(uint8 amount) public {
        vm.startPrank(owner);
        tokenWithVesting.assignVested(
            _receiver,
            amount,
            _start,
            _cliff,
            _vested,
            _revokable
        );

        skip(20);

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

    function test_RevertIf_ReceiverIsZeroAddress() public {
        vm.startPrank(owner);
        tokenWithVesting.assignVested(
            _receiver,
            _amount,
            _start,
            _cliff,
            _vested,
            _revokable
        );

        skip(20);

        vm.startPrank(userB);
        vm.expectRevert(TokenWithVesting.WrongAddress.selector);
        tokenWithVesting.transfer(address(0), _amount);
    }

    function test_RevertIf_MintOnZeroAddress() public {
        vm.startPrank(owner);

        vm.expectRevert(TokenWithVesting.WrongAddress.selector);
        tokenWithVesting.mint(address(0), _amount);
    }

    function test_transferBetweenCliffAndVested() public {
        vm.startPrank(owner);

        tokenWithVesting.assignVested(
            _receiver,
            _amount,
            _start,
            _cliff,
            _vested,
            _revokable
        );

        skip(14);

        // Unlocked Tokens should be 500 (_start = 10, _vested = 20)
        vm.startPrank(userB);
        vm.expectRevert(
            abi.encodeWithSignature(
                "NotEnoughUnlockedTokens(address,uint256)",
                userB,
                _amount / 2
            )
        );
        tokenWithVesting.transfer(owner, _amount);
    }

    function test_transferWhenCliff() public {
        vm.startPrank(owner);

        tokenWithVesting.assignVested(
            _receiver,
            _amount,
            _start,
            _cliff,
            _vested,
            _revokable
        );

        skip(10);

        // Unlocked Tokens should be 100 (_start = 10, _cliff = 11, _vested = 20)
        vm.startPrank(userB);
        vm.expectRevert(
            abi.encodeWithSignature(
                "NotEnoughUnlockedTokens(address,uint256)",
                userB,
                _amount / 10
            )
        );
        tokenWithVesting.transfer(owner, _amount);
    }

    function testFuzz_transferWhenVested(uint8 amount) public {
        vm.startPrank(owner);

        tokenWithVesting.assignVested(
            _receiver,
            amount,
            _start,
            _cliff,
            _vested,
            _revokable
        );

        skip(19);

        // Unlocked Tokens should be 1000 (_vested = 20)
        vm.startPrank(userB);
        uint initialBalance = tokenWithVesting.balanceOf(userB);
        tokenWithVesting.transfer(owner, amount);
        uint finalBalance = tokenWithVesting.balanceOf(userB);

        assertEq(initialBalance, finalBalance + amount);
        assertEq(tokenWithVesting.balanceOf(owner), amount);
    }

    /*  transferableTokens           _x
     *   |                         x/--------   vestedTokens
     *   |                       _/|
     *   |                     _/  |
     *   |                   x/    |            x - test cases
     *   |                 _/      |
     *   |               x/        |
     *   |              .|         |
     *   |            .  |         |
     *   |          x    |         |
     *   |        .      |         |
     *   |      .        |         |
     *   |    .          |         |
     *   +===+===========+---------+----------> time
     *      Start       Cliff    Vested
     */
}
