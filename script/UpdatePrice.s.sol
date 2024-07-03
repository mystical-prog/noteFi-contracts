// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {IPyth} from "@pythnetwork/pyth-sdk-solidity/IPyth.sol";

contract UpdatePrice is Script {
    IPyth pyth;
    uint256 fee;
    bytes[] priceUpdateArray;

    function setUp() public {
        pyth = IPyth(vm.envAddress("PYTH_ADDRESS"));
        priceUpdateArray = new bytes[](1);
        priceUpdateArray[0] = vm.envBytes("PRICE_UPDATE");
        fee = pyth.getUpdateFee(priceUpdateArray);
    }

    function run() external {
        uint256 privateKey = vm.envUint("DEV_PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        pyth.updatePriceFeeds{value: fee}(priceUpdateArray);

        vm.stopBroadcast();
    }
}
