// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test} from "forge-std/Test.sol";
import {Script, console} from "forge-std/Script.sol";
import {TokenWithVesting} from "src/TokenWithVesting.sol";

contract TokenWithVestingSetup is Test {
    TokenWithVesting public tokenWithVesting;
    address internal owner;
    address internal userB;

    string name;
    string symbol;
    uint256 totalSupply;

    // base options for all test vestings
    uint64 public _amount = 1000;
    uint64 public _start = 10;
    uint64 public _cliff = 11;
    uint64 public _vested = 20;
    bool public _revokable = true;
    address public _receiver;

    function setUp() public virtual {
        owner = address(0x1);
        userB = address(0x2);
        name = "DREAMERR";
        symbol = "DRMR";
        totalSupply = 100000;

        vm.startPrank(owner);
        tokenWithVesting = new TokenWithVesting(name, symbol, totalSupply);
        vm.stopPrank();
    }
}
