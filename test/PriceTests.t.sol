// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/primary/AggregatorV3Interface.sol";

contract PriceTest is Test {
    AggregatorV3Interface public cantoOracle;
    AggregatorV3Interface public atomOracle;
    AggregatorV3Interface public ethOracle;

    address caller = makeAddr("caller");

    function setUp() public {
        cantoOracle = AggregatorV3Interface(0x3b5dAAE6d0a1B98EF8B2E6B65206c93c8cE55841);
        atomOracle = AggregatorV3Interface(0x31D8eFBeD8F097365D49010CA45D6c7C47A0714b);
        ethOracle = AggregatorV3Interface(0xc302BD52985e75C1f563a47f2b5dfC4e2b5C6C7E);
    }

    function testPrices() public view {
        (, int256 cantoPrice,,,) = cantoOracle.latestRoundData();
        console.logInt(cantoPrice);
        (, int256 atomPrice,,,) = atomOracle.latestRoundData();
        console.logInt(atomPrice);
        (, int256 ethPrice,,,) = ethOracle.latestRoundData();
        console.logInt(ethPrice);
    }
}
