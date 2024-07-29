// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import "../src/primary/Call.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../src/primary/interfaces/AggregatorV3Interface.sol";
import "../src/secondary/Offer.sol";
import "../src/secondary/OfferFactory.sol";

contract OfferTest is Test {
    address noteToken = 0x03F734Bd9847575fDbE9bEaDDf9C166F880B5E5f; // 18 decimals
    address ethToken = 0xCa03230E7FB13456326a234443aAd111AC96410A; // 18 decimals
    address priceOracle = 0xc302BD52985e75C1f563a47f2b5dfC4e2b5C6C7E; // 8 decimals
    CallOption callOption;
    Offer offer;
    OfferFactory public offerFactory;

    ERC20 ethERC20 = ERC20(ethToken);
    ERC20 noteERC20 = ERC20(noteToken);


    address seller = makeAddr("seller");
    address buyer = makeAddr("buyer");
    address newBuyer = makeAddr("newBuyer");
    uint256 ask = 15e18;

    
    function setUp() public {

        offerFactory = new OfferFactory(noteToken);

        uint256 premium = 10e18;
        uint256 strikePrice = 1500e8;
        uint256 quantity = 1e16;
        uint256 expiration = block.timestamp + 1 weeks;

        vm.prank(seller);
        callOption = new CallOption(0xCa03230E7FB13456326a234443aAd111AC96410A, seller, premium, strikePrice, quantity, expiration, noteToken, priceOracle);
    }


    function testBuyAndAccept() public {
        assertEq(callOption.executed(), false);

        deal(ethToken, seller, 10e16);

        // initialise callOption contract
        vm.startPrank(seller);
        ethERC20.approve(address(callOption), 10e16);
        callOption.init();
        vm.stopPrank();

        assertEq(callOption.inited(), true);
        assertEq(callOption.buyer() != address(0), false);

        deal(noteToken, buyer, 100e18);

        // call buy from callOption contract, by doing this you set the buyer for the Option
        vm.startPrank(buyer);
        noteERC20.approve(address(callOption), 10e18);
        callOption.buy();

        assertEq(callOption.buyer() != address(0), true);
        assertEq(callOption.executed(), false);
        assertEq(callOption.buyer(), buyer);
        assertEq(callOption.strikeValue(), 15e18);

        // create offer for callOption
        offerFactory.createOffer(address(callOption), ask);
        uint256 lastOffer = offerFactory.getOffersCount() - 1;
        offer = Offer(offerFactory.offers(lastOffer));

        // transfer the buyer right to the offer contract
        noteERC20.approve(address(offer), 10e18);
        callOption.transfer(address(offer));

        assertEq(callOption.buyer(), address(offer));
        vm.stopPrank();
        assertEq(offer.executed(), false);
        deal(noteToken, newBuyer, offer.ask());

        // The seller accept the offer and tranfer the Option to the new buyer
        vm.startPrank(newBuyer);
        noteERC20.approve(address(offer), offer.ask());
        offer.accept();
        assertEq(callOption.buyer(), newBuyer);

    }

    function testCancel() public {
        assertEq(callOption.executed(), false);

        deal(ethToken, seller, 10e16);

        // initialise callOption contract
        vm.startPrank(seller);
        ethERC20.approve(address(callOption), 10e16);
        callOption.init();
        vm.stopPrank();

        assertEq(callOption.inited(), true);
        assertEq(callOption.buyer() != address(0), false);

        deal(noteToken, buyer, 100e18);

        // call buy from callOption contract, by doing this you set the buyer for the Option
        vm.startPrank(buyer);
        noteERC20.approve(address(callOption), 10e18);
        callOption.buy();

        assertEq(callOption.buyer() != address(0), true);
        assertEq(callOption.executed(), false);
        assertEq(callOption.buyer(), buyer);
        assertEq(callOption.strikeValue(), 15e18);

        // create offer for callOption
        offerFactory.createOffer(address(callOption), ask);
        uint256 lastOffer = offerFactory.getOffersCount() - 1;
        offer = Offer(offerFactory.offers(lastOffer));

        // transfer the buyer right to the offer contract
        noteERC20.approve(address(offer), 10e18);
        callOption.transfer(address(offer));

        //assertEq(callOption.buyer(), address(offer));
        vm.stopPrank();
        assertEq(offer.executed(), false);
        deal(noteToken, newBuyer, offer.ask());


        vm.startPrank(buyer);
        noteERC20.approve(address(offer), 10e18);
        offer.cancel();

       assertEq(callOption.buyer(), buyer);
    }

    function testCancelFails() public {
        assertEq(callOption.executed(), false);

        deal(ethToken, seller, 10e16);

        // initialise callOption contract
        vm.startPrank(seller);
        ethERC20.approve(address(callOption), 10e16);
        callOption.init();
        vm.stopPrank();

        assertEq(callOption.inited(), true);
        assertEq(callOption.buyer() != address(0), false);

        deal(noteToken, buyer, 100e18);

        // call buy from callOption contract, by doing this you set the buyer for the Option
        vm.startPrank(buyer);
        noteERC20.approve(address(callOption), 10e18);
        callOption.buy();

        assertEq(callOption.buyer() != address(0), true);
        assertEq(callOption.executed(), false);
        assertEq(callOption.buyer(), buyer);
        assertEq(callOption.strikeValue(), 15e18);

        // create offer for callOption
        offerFactory.createOffer(address(callOption), ask);
        uint256 lastOffer = offerFactory.getOffersCount() - 1;
        offer = Offer(offerFactory.offers(lastOffer));

        // transfer the buyer right to the offer contract
        noteERC20.approve(address(offer), 10e18);
        callOption.transfer(address(offer));

        assertEq(callOption.buyer(), address(offer));
        vm.stopPrank();
        assertEq(offer.executed(), false);
        deal(noteToken, newBuyer, offer.ask());

        // The seller accept the offer and tranfer the Option to the new buyer
        vm.startPrank(newBuyer);
        noteERC20.approve(address(offer), offer.ask());
        offer.accept();
        assertEq(callOption.buyer(), newBuyer);

        // transfer the buyer right to the offer contract
        noteERC20.approve(address(offer), 10e18);
        callOption.transfer(address(offer));
        assertEq(offer.executed(), true);
        vm.stopPrank();

        vm.startPrank(buyer);
        noteERC20.approve(address(offer), 10e18);
        offer.cancel();

       assertEq(callOption.buyer(), buyer);
    }

}