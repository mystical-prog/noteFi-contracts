// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {CallOption} from "./Call.sol";
import {PutOption} from "./Put.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title OptionsFactory
 * @author PsyCode Labs
 *
 * Contract that handles the logic and implementation of a factory contract which is responsible
 * for creating new options and keeping a list of all options
 *
 */
contract OptionsFactory is Ownable {

    /* ============ State Variables ============ */

    // address of NOTE
    address public premiumToken;
    // array to store addresses of all deployed call options
    address[] public callOptions;
    // array to store addresses of all deployed put options
    address[] public putOptions;

    // mapping which stores addresses of price oracles corresponding to token address of an asset token
    mapping(address => address) public priceOracles;

    /* ============ Events ============ */

    event CallOptionCreated(
        address indexed optionAddress,
        address indexed asset,
        uint256 premium,
        uint256 strikePrice,
        uint256 quantity,
        uint256 expiration
    );

    event PutOptionCreated(
        address indexed optionAddress,
        address indexed asset,
        uint256 premium,
        uint256 strikePrice,
        uint256 quantity,
        uint256 expiration
    );

    /* ============ Constructor ============ */

    constructor(address _premiumToken) Ownable(msg.sender) {
        premiumToken = _premiumToken;
    }

    /* ============ Functions ============ */

    /**
     * Setting Price Oracle - this function adds/updates the address of price oracles corresponding to
     *     asset tokens in the priceOracles mapping
     *
     * @param _asset - address of an asset token
     * @param _priceOracle - address of price oracle corresponding to asset token
     */
    function setPriceOracle(address _asset, address _priceOracle) external onlyOwner {
        priceOracles[_asset] = _priceOracle;
    }

    /**
     * Creating Call Option - this function creates a new call option and adds the address of this newly
     *     created option in the callOptions array
     *
     * @param _asset - address of asset token
     * @param _premium - price/premium amount in order to buy the option
     * @param _strikePrice - price at or above which option becomes in the money
     * @param _quantity - amount of asset token
     * @param _expiration - timestamp on which the option expires
     */
    function createCallOption(
        address _asset,
        uint256 _premium,
        uint256 _strikePrice,
        uint256 _quantity,
        uint256 _expiration
    ) external {
        address priceOracle = priceOracles[_asset];
        require(priceOracle != address(0), "Price oracle not set for this asset");
        require(_quantity > 0, "Quantity cannot be zero");
        require(_premium > 0, "Premium cannot be zero");
        require(_quantity > 0, "Quantity cannot be zero");
        require(_strikePrice > 0, "Strike price cannot be zero");
        require(_expiration > block.timestamp, "Timestamp cannot be less than current block timestamp");

        CallOption _newCallOption = new CallOption(
            _asset, msg.sender, _premium, _strikePrice, _quantity, _expiration, premiumToken, priceOracle
        );
        callOptions.push(address(_newCallOption));

        emit CallOptionCreated(address(_newCallOption), _asset, _premium, _strikePrice, _quantity, _expiration);
    }

    /**
     * Creating Put Option - this function creates a new put option and adds the address of this newly
     *     created option in the putOptions array
     *
     * @param _asset - address of asset token
     * @param _premium - price/premium amount in order to buy the option
     * @param _strikePrice - price at or above which option becomes in the money
     * @param _quantity - amount of asset token
     * @param _expiration - timestamp on which the option expires
     */
    function createPutOption(
        address _asset,
        uint256 _premium,
        uint256 _strikePrice,
        uint256 _quantity,
        uint256 _expiration
    ) external {
        address priceOracle = priceOracles[_asset];
        require(priceOracle != address(0), "Price oracle not set for this asset");
        require(_quantity > 0, "Quantity cannot be zero");
        require(_premium > 0, "Premium cannot be zero");
        require(_quantity > 0, "Quantity cannot be zero");
        require(_strikePrice > 0, "Strike price cannot be zero");
        require(_expiration > block.timestamp, "Timestamp cannot be less than current block timestamp");

        PutOption _newPutOption =
            new PutOption(_asset, msg.sender, _premium, _strikePrice, _quantity, _expiration, premiumToken, priceOracle);
        putOptions.push(address(_newPutOption));

        emit PutOptionCreated(address(_newPutOption), _asset, _premium, _strikePrice, _quantity, _expiration);
    }

    /**
     * Call Options Getter - this function returns a complete list (addresses) of call options created till date
     */
    function getCallOptions() external view returns (address[] memory) {
        return callOptions;
    }

    /**
     * Put Options Getter - this function returns a complete list (addresses) of put options created till date
     */
    function getPutOptions() external view returns (address[] memory) {
        return putOptions;
    }
}
