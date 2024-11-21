// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {FileUtils} from "../utils/FileHelpers.sol";

contract ReadWriteExample is Script {
    FileUtils fileUtils = new FileUtils();

    function run() public {
        fileUtils.writeContractAddress(1, address(0x111), "newContract");

        address contractAddress = fileUtils.readContractAddress(
            1,
            "newContract"
        );

        console.log("contractAddress", contractAddress);
    }
}
