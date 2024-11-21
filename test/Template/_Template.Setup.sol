// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Template} from "../../src/Template.sol";
import {TestUtils} from "../TestUtils.sol";

contract TemplateTestSetup is TestUtils {
    Template public template;

    function _setUp() internal override {
        template = new Template();
        template.setNumber(0);
    }
}
