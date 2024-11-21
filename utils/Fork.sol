// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Vm} from "forge-std/Vm.sol";
import {console} from "forge-std/console.sol";

contract Fork {
    Vm private vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    mapping(uint32 chainId => string envString) private forkAliases;

    mapping(uint32 chainId => ForkData) private _forkId;

    mapping(uint32 chainId => uint256) internal defaultForkBlockNumber;

    // Created because forkId can be 0 and cannot be used to prove fork existence
    struct ForkData {
        uint forkId;
        bool exists;
    }

    constructor() {
        _configureForkAlias();
        _configureDefaultForkBlockNumber();
    }

    function fork(uint32 chainId) public {
        ForkData memory forkData = _forkId[chainId];
        uint forkId = forkData.forkId;

        if (forkData.exists) {
            bool isForkActive = vm.activeFork() == forkData.forkId;

            if (isForkActive) return;

            vm.selectFork(forkId);
            return;
        }

        // Create new fork
        string memory forkAlias = forkAliases[chainId];
        uint blockNumber = defaultForkBlockNumber[chainId];

        if (blockNumber != 0) forkId = vm.createFork(forkAlias, blockNumber);
        else forkId = vm.createFork(forkAlias);

        _forkId[chainId] = ForkData(forkId, true);

        vm.selectFork(forkId);
    }

    function isForkAvailable(uint32 chainId) public view returns (bool) {
        bytes32 _fork = keccak256(abi.encode(forkAliases[chainId]));
        bytes32 emptyString = keccak256(abi.encode(""));
        return _fork != emptyString;
    }

    function _configureForkAlias() internal virtual {
        forkAliases[1] = "mainnet";
        forkAliases[10] = "optimism";
        forkAliases[56] = "bsc";
        forkAliases[137] = "polygon";
        forkAliases[1088] = "metis";
        forkAliases[5000] = "mantle";
        forkAliases[8453] = "base";
        forkAliases[42161] = "arbitrum";
        forkAliases[43114] = "avalanche";
        forkAliases[1329] = "sei";
    }

    function _configureDefaultForkBlockNumber() internal virtual {
        // defaultForkBlockNumber[1] = 20540766; // 16 aug 2024
        // defaultForkBlockNumber[10] = 124104713; // 16 aug 2024
        // defaultForkBlockNumber[56] = 41411949; // 16 aug 2024
        // defaultForkBlockNumber[137] = 60657859; // 16 aug 2024
        // defaultForkBlockNumber[5000] = 67856441; // 16 aug 2024
        // defaultForkBlockNumber[8453] = 18509444; // 16 aug 2024
        // defaultForkBlockNumber[42161] = 243590872; // 16 aug 2024
    }
}
