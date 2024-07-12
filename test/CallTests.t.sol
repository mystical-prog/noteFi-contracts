// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import "../src/primary/Factory.sol";
import "../src/primary/Call.sol";
import "../src/primary/Put.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../src/primary/AggregatorV3Interface.sol";

contract CallOptionTest is Test {
    OptionsFactory public factory;
    address noteToken = 0x03F734Bd9847575fDbE9bEaDDf9C166F880B5E5f; // 18 decimals
    address ethToken = 0xCa03230E7FB13456326a234443aAd111AC96410A; // 18 decimals
    address priceOracle = 0xc302BD52985e75C1f563a47f2b5dfC4e2b5C6C7E; // 8 decimals
    CallOption callOption;

    address creator = makeAddr("creator");
    address buyer = makeAddr("buyer");

    function setUp() public {
        factory = OptionsFactory(0xA5192B03B520aF7214930936C958CF812e361CD3);
        uint256 premium = 10e18;
        uint256 strikePrice = 3500e8;
        uint256 quantity = 1e16;
        uint256 expiration = block.timestamp + 1 weeks;

        vm.prank(creator);
        factory.createCallOption(ethToken, premium, strikePrice, quantity, expiration);

        address[] memory callOptions = factory.getCallOptions();
        callOption = CallOption(callOptions[callOptions.length - 1]);
    }

    function testBuyAndExecute() public {
        assertEq(callOption.inited(), false);

        ERC20 ethERC20 = ERC20(ethToken);
        ERC20 noteERC20 = ERC20(noteToken);

        deal(ethToken, creator, 1e16);

        vm.startPrank(creator);
        ethERC20.approve(address(callOption), 1e16);
        callOption.init();
        vm.stopPrank();

        assertEq(callOption.inited(), true);
        assertEq(callOption.bought(), false);

        deal(noteToken, buyer, 100e18);

        vm.startPrank(buyer);
        noteERC20.approve(address(callOption), 10e18);
        callOption.buy();

        assertEq(callOption.bought(), true);
        assertEq(callOption.executed(), false);
        assertEq(callOption.buyer(), buyer);
        assertEq(callOption.strikeValue(), 35e18);

        noteERC20.approve(address(callOption), callOption.strikeValue());
        callOption.execute();
        vm.stopPrank();

        assertEq(ethERC20.balanceOf(buyer), callOption.quantity());
        assertEq(noteERC20.balanceOf(buyer), 55e18);
        assertEq(noteERC20.balanceOf(creator), 45e18);
        assertEq(callOption.executed(), true);
    }

    function testCancel() public {
        assertEq(callOption.inited(), false);

        ERC20 ethERC20 = ERC20(ethToken);

        deal(ethToken, creator, 1e16);

        vm.startPrank(creator);
        ethERC20.approve(address(callOption), 1e16);
        callOption.init();

        assertEq(callOption.inited(), true);
        assertEq(callOption.executed(), false);
        assertEq(ethERC20.balanceOf(address(callOption)), 1e16);

        skip(5 days);
        callOption.cancel();
        vm.stopPrank();

        assertEq(callOption.executed(), true);
        assertEq(ethERC20.balanceOf(address(callOption)), 0);
        assertEq(ethERC20.balanceOf(creator), 1e16);
    }

    function testWithdraw() public {
        assertEq(callOption.inited(), false);

        ERC20 ethERC20 = ERC20(ethToken);
        ERC20 noteERC20 = ERC20(noteToken);

        deal(ethToken, creator, 1e16);

        vm.startPrank(creator);
        ethERC20.approve(address(callOption), 1e16);
        callOption.init();
        vm.stopPrank();

        assertEq(callOption.inited(), true);
        assertEq(callOption.bought(), false);

        deal(noteToken, buyer, 100e18);

        vm.startPrank(buyer);
        noteERC20.approve(address(callOption), 10e18);
        callOption.buy();
        vm.stopPrank();

        assertEq(callOption.bought(), true);
        assertEq(callOption.executed(), false);
        assertEq(callOption.buyer(), buyer);
        assertEq(callOption.strikeValue(), 35e18);

        vm.warp(block.timestamp + 8 days);
        vm.prank(creator);
        callOption.withdraw();

        assertEq(ethERC20.balanceOf(creator), 1e16);
        assertEq(noteERC20.balanceOf(buyer), 90e18);
        assertEq(noteERC20.balanceOf(creator), 10e18);
        assertEq(callOption.executed(), true);
    }

    function testExecuteFails() public {
        uint256 _premium = 10e18;
        uint256 _strikePrice = 3800e8;
        uint256 _quantity = 1e16;
        uint256 _expiration = block.timestamp + 1 weeks;

        vm.prank(creator);
        factory.createCallOption(ethToken, _premium, _strikePrice, _quantity, _expiration);

        address[] memory _callOptions = factory.getCallOptions();
        CallOption callOption2 = CallOption(_callOptions[_callOptions.length - 1]);

        assertEq(callOption2.inited(), false);

        ERC20 ethERC20 = ERC20(ethToken);
        ERC20 noteERC20 = ERC20(noteToken);

        deal(ethToken, creator, 1e16);

        vm.startPrank(creator);
        ethERC20.approve(address(callOption2), 1e16);
        callOption2.init();
        vm.stopPrank();

        assertEq(callOption2.inited(), true);
        assertEq(callOption2.bought(), false);

        deal(noteToken, buyer, 100e18);

        vm.startPrank(buyer);
        noteERC20.approve(address(callOption2), 10e18);
        callOption2.buy();

        assertEq(callOption2.bought(), true);
        assertEq(callOption2.executed(), false);
        assertEq(callOption2.buyer(), buyer);
        assertEq(callOption2.strikeValue(), 38e18);

        noteERC20.approve(address(callOption2), callOption2.strikeValue());
        vm.expectRevert();
        callOption2.execute();
        vm.stopPrank();

        assertEq(ethERC20.balanceOf(buyer), 0);
        assertEq(noteERC20.balanceOf(buyer), 90e18);
        assertEq(noteERC20.balanceOf(creator), 10e18);
        assertEq(callOption2.executed(), false);
    }
}
