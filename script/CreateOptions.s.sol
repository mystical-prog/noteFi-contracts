// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/primary/Factory.sol";
import "../src/primary/Call.sol";
import "../src/primary/Put.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title CreateOption Script
 * @author PsyCode Labs
 *
 * This is a testing script which is used to create an option on Canto testnet
 */
contract CreateOption is Script {
    OptionsFactory factory;
    address asset;

    function setUp() public {
        // initing factory from deployed address
        factory = OptionsFactory(0xA5192B03B520aF7214930936C958CF812e361CD3);
        // Ethereum token address on canto testnet
        asset = 0xCa03230E7FB13456326a234443aAd111AC96410A;
    }

    function run() public {
        // setting up wallet
        uint256 privateKey = vm.envUint("DEV_PRIVATE_KEY");

        // parameters for an option
        uint256 premium = 10e18;
        uint256 strikePrice = 65000e8;
        uint256 quantity = 1e16;
        uint256 expiration = block.timestamp + 2 weeks;

        vm.startBroadcast(privateKey);

        // creating a Put option
        factory.createPutOption(asset, premium, strikePrice, quantity, expiration);

        vm.stopBroadcast();
    }
}

/**
 * @title InitOption Script
 * @author PsyCode Labs
 *
 * This is a testing script which is used to init a deployed option on Canto testnet
 */
contract InitOption is Script {
    PutOption putOption;
    ERC20 note;

    function setUp() public {
        // initing a Put option from a deployed address
        putOption = PutOption(0x2DE7f048E4D99784983CfE24193B6e8818F91503);
        // NOTE token address on Canto testnet
        note = ERC20(0x03F734Bd9847575fDbE9bEaDDf9C166F880B5E5f);
    }

    function run() public {
        // setting up wallet
        uint256 privateKey = vm.envUint("DEV_PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        // approving NOTE tokens to option contract
        note.approve(address(putOption), putOption.strikeValue());
        // calling init function which transfers the above approved NOTE tokens into option contract
        putOption.init();
        
        vm.stopBroadcast();
    }
}
