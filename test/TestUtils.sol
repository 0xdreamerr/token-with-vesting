// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Fork} from "../utils/Fork.sol";

contract TestUtils is Fork, Test {
    function _configureDefaultForkBlockNumber() internal override {
        defaultForkBlockNumber[1] = 20540766; // 16 aug 2024
        defaultForkBlockNumber[10] = 124104713; // 16 aug 2024
        defaultForkBlockNumber[56] = 41411949; // 16 aug 2024
        defaultForkBlockNumber[137] = 60657859; // 16 aug 2024
        defaultForkBlockNumber[5000] = 67856441; // 16 aug 2024
        defaultForkBlockNumber[8453] = 18509444; // 16 aug 2024
        defaultForkBlockNumber[42161] = 243590872; // 16 aug 2024
    }

    function setUp() public {
        _setUp();
        _afterSetup();
    }

    function _setUp() internal virtual {}

    function _afterSetup() internal virtual {}
}
