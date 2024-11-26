// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "./_.TokenWithVesting.Setup.sol";
import {TokenWithVesting} from "src/TokenWithVesting.sol";

contract CreateVestingTest is Test, TokenWithVestingSetup {
    function setUp() public override {
        super.setUp();
        _receiver = userB;
    }

    function testFuzz_createVesting(uint8 amount) public {
        vm.startPrank(owner);

        tokenWithVesting.assignVested(
            _receiver,
            amount,
            _start,
            _cliff,
            _vested,
            _revokable
        );

        vm.sleep(25);

        assertEq(tokenWithVesting.balanceOf(userB), amount);
        assertEq(tokenWithVesting.vestingsLengths(userB), 1);
    }

    function test_RevertIf_ReceiverIsTokenContract() public {
        vm.startPrank(owner);
        _receiver = address(tokenWithVesting);

        // expecting custom error
        vm.expectRevert(TokenWithVesting.VestingToTM.selector);
        tokenWithVesting.assignVested(
            _receiver,
            _amount,
            _start,
            _cliff,
            _vested,
            _revokable
        );
    }

    function test_RevertIf_TooManyVestings() public {
        vm.startPrank(owner);

        // creating 5 vestings and 1 more for error (MAX_VESTINGS = 5)
        for (
            uint i = 0;
            i <= tokenWithVesting.MAX_VESTINGS_PER_ADDRESS();
            i++
        ) {
            if (i == 5) {
                vm.expectRevert(TokenWithVesting.TooManyVestings.selector);
            }

            tokenWithVesting.assignVested(
                _receiver,
                _amount,
                _start,
                _cliff,
                _vested,
                _revokable
            );
        }
    }

    function test_RevertIf_CliffIsGreaterThanVested() public {
        vm.startPrank(owner);

        _cliff = 25; // _cliff > _vested, expecting error

        vm.expectRevert(TokenWithVesting.WrongCliffDate.selector);
        tokenWithVesting.assignVested(
            _receiver,
            _amount,
            _start,
            _cliff,
            _vested,
            _revokable
        );
    }
    function test_RevertIf_CliffIsGreaterThanStart() public {
        vm.startPrank(owner);

        _cliff = 9; // _cliff < _start, expecting error

        vm.expectRevert(TokenWithVesting.WrongCliffDate.selector);
        tokenWithVesting.assignVested(
            _receiver,
            _amount,
            _start,
            _cliff,
            _vested,
            _revokable
        );
    }

    function test_RevertIf_ReceiverIsZeroAddress() public {
        vm.startPrank(owner);

        _receiver = address(0);

        vm.expectRevert(TokenWithVesting.WrongAddress.selector);
        tokenWithVesting.assignVested(
            _receiver,
            _amount,
            _start,
            _cliff,
            _vested,
            _revokable
        );
    }
}
