// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/primary/Factory.sol";

contract NewFactory is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("DEV_PRIVATE_KEY");

        vm.startBroadcast(privateKey);
        OptionsFactory factory = new OptionsFactory(0x03F734Bd9847575fDbE9bEaDDf9C166F880B5E5f);

        factory.setPriceOracle(0x04a72466De69109889Db059Cb1A4460Ca0648d9D, 0x3b5dAAE6d0a1B98EF8B2E6B65206c93c8cE55841);
        factory.setPriceOracle(0xCa03230E7FB13456326a234443aAd111AC96410A, 0xc302BD52985e75C1f563a47f2b5dfC4e2b5C6C7E);

        vm.stopBroadcast();
    }
}

contract SetFactoryOracles is Script {
    OptionsFactory factory;

    function setUp() public {
        factory = OptionsFactory(0x21AEd57A31E985894536481233BD7d2Df8b91ffB);
    }

    function run() public {
        uint256 privateKey = vm.envUint("DEV_PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        factory.setPriceOracle(0x04a72466De69109889Db059Cb1A4460Ca0648d9D, 0x3b5dAAE6d0a1B98EF8B2E6B65206c93c8cE55841);
        factory.setPriceOracle(0xCa03230E7FB13456326a234443aAd111AC96410A, 0xc302BD52985e75C1f563a47f2b5dfC4e2b5C6C7E);

        vm.stopBroadcast();
    }
}
