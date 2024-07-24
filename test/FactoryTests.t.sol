// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import "../src/primary/Factory.sol";

contract FactoryTests is Test {
    OptionsFactory public factory;
    address noteToken = 0x03F734Bd9847575fDbE9bEaDDf9C166F880B5E5f;
    address ethToken = 0xCa03230E7FB13456326a234443aAd111AC96410A;
    address atomToken = 0x40E41DC5845619E7Ba73957449b31DFbfB9678b2;
    address priceOracle = 0xc302BD52985e75C1f563a47f2b5dfC4e2b5C6C7E;
    address priceOracle2 = 0x31D8eFBeD8F097365D49010CA45D6c7C47A0714b;

    address creator = makeAddr("creator");
    address owner = makeAddr("owner");

    function setUp() public {
        vm.startPrank(owner);
        factory = new OptionsFactory(noteToken);
        factory.setPriceOracle(ethToken, priceOracle);
        factory.setPriceOracle(atomToken, priceOracle2);
        vm.stopPrank();
    }

    function testCreateCallOption() public {
        uint256 premium = 1e18;
        uint256 strikePrice = 6e8;
        uint256 quantity = 1e5;
        uint256 expiration = block.timestamp + 1 weeks;

        vm.prank(creator);
        factory.createCallOption(atomToken, premium, strikePrice, quantity, expiration);

        // assertEq(factory.callOptions.length, 1);

        CallOption callOption = CallOption(factory.callOptions(0));
        assertEq(callOption.asset(), address(atomToken));
        assertEq(callOption.premium(), premium);
        assertEq(callOption.strikePrice(), strikePrice);
        assertEq(callOption.quantity(), quantity);
        assertEq(callOption.expiration(), expiration);
        assertEq(callOption.strikeValue(), 6e17);
    }

    function testCreatePutOption() public {
        uint256 premium = 100e18;
        uint256 strikePrice = 3500e8;
        uint256 quantity = 1e18;
        uint256 expiration = block.timestamp + 1 weeks;

        vm.prank(creator);
        factory.createPutOption(ethToken, premium, strikePrice, quantity, expiration);

        // assertEq(putOptions.length, 1);

        PutOption putOption = PutOption(factory.putOptions(0));
        assertEq(putOption.asset(), ethToken);
        assertEq(putOption.premium(), premium);
        assertEq(putOption.strikePrice(), strikePrice);
        assertEq(putOption.quantity(), quantity);
        assertEq(putOption.expiration(), expiration);
    }

    function testGasSanity() public {
        deal(creator, 100e18);
        uint256 premium = 100e18;
        uint256 strikePrice = 3500e8;
        uint256 quantity = 1e18;
        uint256 expiration = block.timestamp + 1 weeks;

        vm.startPrank(creator);

        uint256 firstCreateStart = gasleft();
        factory.createCallOption(ethToken, premium, strikePrice, quantity, expiration);
        uint256 firstCreateCost = firstCreateStart - gasleft();

        uint256 firstPutStart = gasleft();
        factory.createPutOption(ethToken, premium, strikePrice, quantity, expiration);
        uint256 putCreateCost = firstPutStart - gasleft();

        console2.log("Gas Cost Call First: %s", firstCreateCost);
        console2.log("Gas Cost Put First: %s", putCreateCost);

        for (uint i = 0; i < 10; i++) {
            factory.createCallOption(ethToken, premium, strikePrice, quantity, expiration);
            factory.createPutOption(ethToken, premium, strikePrice, quantity, expiration);
        }

        uint256 lastCreateStart = gasleft();
        factory.createCallOption(ethToken, premium, strikePrice, quantity, expiration);
        uint256 lastCreateCost = lastCreateStart - gasleft();

        uint256 lastPutCreateStart = gasleft();
        factory.createPutOption(ethToken, premium, strikePrice, quantity, expiration);
        uint256 lastPutCreateCost = lastPutCreateStart - gasleft();

        console2.log("Gas Cost Call Last: %s", lastCreateCost);
        console2.log("Gas Cost Call Last: %s", lastPutCreateCost);
    
        vm.stopPrank();
    }

    function testSetPriceOracleFails() public {
        vm.startPrank(creator);
        vm.expectRevert();
        factory.setPriceOracle(ethToken, address(0));
        vm.stopPrank();
    }

    function testSetPriceOracle() public {
        vm.startPrank(owner);
        factory.setPriceOracle(ethToken, address(0));
        vm.stopPrank();   
    }
}