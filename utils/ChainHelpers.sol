// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ChainHelpers {
    enum Chains {
        ethereum,
        arbitrum,
        polygon,
        optimism,
        base,
        avalanche,
        linea,
        bsc,
        mantle,
        fantom,
        metis,
        sei
    }

    mapping(uint256 chainId => uint32 eid) internal _eids;

    mapping(Chains => uint32 chainId) internal _chains;

    constructor() {
        _setChainIds();
        _setChainEid();
    }

    function _setChainIds() private {
        _chains[Chains.ethereum] = 1;
        _chains[Chains.arbitrum] = 42161;
        _chains[Chains.polygon] = 137;
        _chains[Chains.optimism] = 10;
        _chains[Chains.base] = 8453;
        _chains[Chains.avalanche] = 43114;
        _chains[Chains.linea] = 59144;
        _chains[Chains.bsc] = 56;
        _chains[Chains.mantle] = 5000;
        _chains[Chains.fantom] = 250;
        _chains[Chains.metis] = 1088;
        _chains[Chains.sei] = 1329;
    }

    function _setChainEid() private {
        _eids[getChainId(Chains.ethereum)] = 30101;
        _eids[getChainId(Chains.bsc)] = 30102;
        _eids[getChainId(Chains.polygon)] = 30109;
        _eids[getChainId(Chains.arbitrum)] = 30110;
        _eids[getChainId(Chains.optimism)] = 30111;
        _eids[getChainId(Chains.avalanche)] = 30106;
        _eids[getChainId(Chains.base)] = 30184;
        // _eids[getChainId(Chains.linea)] = 30183;
        _eids[getChainId(Chains.mantle)] = 30181;
        // _eids[getChainId(Chains.fantom)] = 40112;
        _eids[getChainId(Chains.metis)] = 30151;
        _eids[getChainId(Chains.sei)] = 30280;
    }

    error ChainIdNotFound(Chains chain);

    function getChainId(Chains chain) public view returns (uint32 chainId) {
        chainId = _chains[chain];

        if (chainId == 0) revert ChainIdNotFound(chain);
    }

    function getEid(uint32 chainId) public view returns (uint32) {
        require(
            _eids[chainId] != 0,
            string(bytes.concat("eid not found: ", bytes4(chainId)))
        );
        return _eids[chainId];
    }
}
