// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import "../src/primary/Factory.sol";
import "../src/primary/Call.sol";
import "../src/primary/Put.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../src/primary/interfaces/AggregatorV3Interface.sol";

contract OptionsFactoryTest is Test {
    OptionsFactory public factory;
    address noteToken = 0x03F734Bd9847575fDbE9bEaDDf9C166F880B5E5f;
    address ethToken = 0xCa03230E7FB13456326a234443aAd111AC96410A;
    address priceOracle = 0xc302BD52985e75C1f563a47f2b5dfC4e2b5C6C7E;

    address creator = makeAddr("creator");
    address buyer = makeAddr("buyer");

    function setUp() public {
        factory = new OptionsFactory(noteToken);
        factory.setPriceOracle(ethToken, priceOracle);
    }

    function testCreateCallOption() public {
        uint256 premium = 100e18;
        uint256 strikePrice = 3500e8;
        uint256 quantity = 1e18;
        uint256 expiration = block.timestamp + 1 weeks;

        vm.prank(creator);
        factory.createCallOption(ethToken, premium, strikePrice, quantity, expiration);

        address[] memory callOptions = factory.getCallOptions();
        assertEq(callOptions.length, 1);

        CallOption callOption = CallOption(callOptions[0]);
        assertEq(callOption.asset(), address(ethToken));
        assertEq(callOption.premium(), premium);
        assertEq(callOption.strikePrice(), strikePrice);
        assertEq(callOption.quantity(), quantity);
        assertEq(callOption.expiration(), expiration);
    }

    function testCreatePutOption() public {
        uint256 premium = 100e18;
        uint256 strikePrice = 3500e8;
        uint256 quantity = 1e18;
        uint256 expiration = block.timestamp + 1 weeks;

        vm.prank(creator);
        factory.createPutOption(ethToken, premium, strikePrice, quantity, expiration);

        address[] memory putOptions = factory.getPutOptions();
        assertEq(putOptions.length, 1);

        PutOption putOption = PutOption(putOptions[0]);
        assertEq(putOption.asset(), ethToken);
        assertEq(putOption.premium(), premium);
        assertEq(putOption.strikePrice(), strikePrice);
        assertEq(putOption.quantity(), quantity);
        assertEq(putOption.expiration(), expiration);
    }
}
