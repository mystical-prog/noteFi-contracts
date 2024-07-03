// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {PythAggregatorV3} from "@pythnetwork/pyth-sdk-solidity/PythAggregatorV3.sol";

contract PythAggregatorV3Deployment is Script {
    function run() external {
        uint256 privateKey = vm.envUint("DEV_PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        address pythPriceFeedsContract = vm.envAddress("PYTH_ADDRESS");

        bytes32 cantoFeedId = 0x972776d57490d31c32279c16054e5c01160bd9a2e6af8b58780c82052b053549;
        bytes32 atomFeedId = 0xb00b60f88b03a6a625a8d1c048c3f66653edf217439983d037e7222c4e612819;
        bytes32 ethFeedId = 0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace;

        // 0x3b5dAAE6d0a1B98EF8B2E6B65206c93c8cE55841
        PythAggregatorV3 cantoAggregator = new PythAggregatorV3(pythPriceFeedsContract, cantoFeedId);
        // 0x31D8eFBeD8F097365D49010CA45D6c7C47A0714b
        PythAggregatorV3 atomAggregator = new PythAggregatorV3(pythPriceFeedsContract, atomFeedId);
        // 0xc302BD52985e75C1f563a47f2b5dfC4e2b5C6C7E
        PythAggregatorV3 ethAggregator = new PythAggregatorV3(pythPriceFeedsContract, ethFeedId);

        vm.stopBroadcast();
    }
}
