//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;
    uint8 public constant Decimal = 8;
    int256 constant Initial_Value = 2000e8;

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaConfigEth();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetConfigEth();
        } else {
            activeNetworkConfig = getAnvilConfigEth();
        }
    }

    function getSepoliaConfigEth() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainnetConfigEth() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ethconfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethconfig;
    }

    function getAnvilConfigEth() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockpricefeed = new MockV3Aggregator(
            Decimal,
            Initial_Value
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilconfig = NetworkConfig({
            priceFeed: address(mockpricefeed)
        });
        return anvilconfig;
    }
}
