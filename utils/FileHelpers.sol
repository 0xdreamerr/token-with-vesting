// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Vm} from "forge-std/Vm.sol";
import {console2} from "forge-std/console2.sol";

contract FileUtilsState {
    Vm internal vm =
        Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    string public pathToContracts = "deployments/Contracts.json";

    string public mainObjKey = "main key";
}

contract FileWriteUtils is FileUtilsState {
    ///@dev Write contract address to file, rewrite if exist
    function writeContractAddress(
        uint32 chainId,
        address contractAddress,
        string memory contractName
    ) public {
        string memory chainObjKey = string.concat(".", vm.toString(chainId));

        string memory json = _getOrCreateJsonFile();

        json = _writeChainIfNotExist(json, chainObjKey, chainId);

        _writeAddress(json, chainObjKey, contractName, contractAddress);
    }

    function _getOrCreateJsonFile() internal returns (string memory) {
        bool isFileExist = vm.exists(pathToContracts);

        if (!isFileExist) vm.writeJson("{}", pathToContracts);

        string memory file = vm.readFile(pathToContracts);
        if (bytes(file).length == 0) vm.writeJson("{}", pathToContracts);

        file = vm.readFile(pathToContracts);
        string memory json = vm.serializeJson(mainObjKey, file);

        return json;
    }

    function _writeAddress(
        string memory json,
        string memory chainObjKey,
        string memory contractName,
        address contractAddress
    ) internal {
        string memory chainObj;

        string[] memory keysOfChainObj = vm.parseJsonKeys(json, chainObjKey);

        for (uint256 i = 0; i < keysOfChainObj.length; i++) {
            address addressOfContract = vm.parseJsonAddress(
                json,
                string.concat(chainObjKey, ".", keysOfChainObj[i])
            );

            chainObj = vm.serializeAddress(
                chainObjKey,
                keysOfChainObj[i],
                addressOfContract
            );
        }

        chainObj = vm.serializeAddress(
            chainObjKey,
            contractName,
            contractAddress
        );

        vm.writeJson(chainObj, pathToContracts, chainObjKey);
    }

    function _writeChainIfNotExist(
        string memory json,
        string memory chainObjKey,
        uint32 chainId
    ) internal returns (string memory newJson) {
        bool isChainExist = vm.keyExistsJson(json, chainObjKey);

        if (isChainExist) return json;

        string memory mainObj = vm.serializeString(
            mainObjKey,
            vm.toString(chainId),
            "{}"
        );

        vm.writeJson(mainObj, pathToContracts);

        newJson = _getOrCreateJsonFile();
    }
}

contract FileReadUtils is FileUtilsState {
    function readContractAddress(
        uint32 chainId,
        string memory contractName
    ) public returns (address) {
        _checkFileExist();

        string memory chainObjKey = string.concat(".", vm.toString(chainId));

        string memory file = vm.readFile(pathToContracts);

        _checkChainExist(chainObjKey, file, chainId);

        _checkContractExist(chainObjKey, contractName, file, chainId);

        address contractAddress = vm.parseJsonAddress(
            file,
            string.concat(chainObjKey, ".", contractName)
        );

        return contractAddress;
    }

    function _checkFileExist() internal {
        bool isFileExist = vm.exists(pathToContracts);

        require(
            isFileExist,
            string.concat("File with path ", pathToContracts, " does not exist")
        );
    }

    function _checkChainExist(
        string memory chainObjKey,
        string memory json,
        uint32 chainId
    ) internal {
        bool isChainExist = vm.keyExistsJson(json, chainObjKey);

        require(
            isChainExist,
            string.concat("Chain ", vm.toString(chainId), " does not exist")
        );
    }

    function _checkContractExist(
        string memory chainObjKey,
        string memory contractName,
        string memory json,
        uint32 chainId
    ) internal {
        bool isContractExist = vm.keyExistsJson(
            json,
            string.concat(chainObjKey, ".", contractName)
        );

        require(
            isContractExist,
            string.concat(
                "Contract ",
                contractName,
                " does not exist on chain ",
                vm.toString(chainId)
            )
        );
    }
}

contract FileUtils is FileReadUtils, FileWriteUtils {}
