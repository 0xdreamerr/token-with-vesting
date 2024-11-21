// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {TemplateTestSetup} from "./_Template.Setup.sol";

contract TemplateExternalFunctionsTesting is TemplateTestSetup {
    function test_Increment() public {
        template.increment();
        assertEq(template.number(), 1);
    }

    function testFuzz_SetNumber(uint256 x) public {
        template.setNumber(x);
        assertEq(template.number(), x);
    }
}
