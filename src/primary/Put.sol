// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "./AggregatorV3Interface.sol";

/**
 * @title PutOption
 * @author PsyCode Labs
 *
 * Contract that handles the logic and implementation of put options, this contract represents
 * a single put option
 */
contract PutOption {
    
    /* ============ State Variables ============ */

    // address of the token on which option is being created, eg. ETH, WCANTO
    address public asset;
    // address of the creator/writer of the contract
    address public creator;
    // address of the current buyer who holds the right to execute the option
    address public buyer;

    // cost of buying the option (in NOTE)
    uint256 public premium;
    // price below which the option is executable
    uint256 public strikePrice;
    // amount of asset token
    uint256 public quantity;
    // timestamp after which the option expires
    uint256 public expiration;
    // price at which the option was executed, if executed
    uint256 public executedPrice;

    // boolean to check whether the creator/writer has transferred required assets
    bool public inited;
    // boolean to check whether the option has been bought by anyone or not
    bool public bought;
    // boolean to check whether the option has been executed or not
    bool public executed;

    // quote token (NOTE)
    IERC20 public premiumToken;

    // oracle to call for asset/NOTE price feed
    AggregatorV3Interface public priceOracle;

    /* ============ Constructor ============ */

    constructor(
        address _asset,
        address _creator,
        uint256 _premium,
        uint256 _strikePrice,
        uint256 _quantity,
        uint256 _expiration,
        address _premiumToken,
        address _priceOracle
    ) {
        asset = _asset;
        creator = _creator;
        premium = _premium;
        strikePrice = _strikePrice;
        quantity = _quantity;
        expiration = _expiration;
        buyer = address(0);
        bought = false;
        executed = false;
        inited = false;
        premiumToken = IERC20(_premiumToken);
        priceOracle = AggregatorV3Interface(_priceOracle);
    }

    /* ============ Modifiers ============ */

    /**
     * Throws if option has not been initialized
     */
    modifier isInited() {
        require(inited, "Contract has not been inited by the creator!");
        _;
    }

    /**
     * Throws if option has already been bought
     */
    modifier notBought() {
        require(!bought, "Contract has been bought!");
        _;
    }

    /**
     * Throws if option has already been executed
     */
    modifier notExecuted() {
        require(!executed, "Contract has been executed!");
        _;
    }

    /**
     * Throws if function is called by any address other than buyer
     */
    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only the buyer can call this function!");
        _;
    }

    /**
     * Throws if function is called by any address other than creator
     */
    modifier onlyCreator() {
        require(msg.sender == creator, "Only the creator can call this function!");
        _;
    }

    /**
     * Throws if the current block timestamp is greater than expiration timestamp of the option
     */
    modifier notExpired() {
        require(block.timestamp <= expiration, "Option expired");
        _;
    }

    /* ============ Functions ============ */

    /**
     * Initializes Option - the creator locks in required amount of NOTE tokens
     */
    function init() external onlyCreator {
        require(inited == false, "Option contract has already been initialized");
        inited = true;
        require(premiumToken.transferFrom(creator, address(this), strikeValue()), "Transfer failed");
    }

    /**
     * Buying Option - this function is called by a buyer who is interested, this function can be
     *     only called once, after that the role of buyer can only be transferred using 'transfer'
     */
    function buy() external notBought isInited notExpired {
        require(msg.sender != creator, "Creator cannot buy their own option");
        bought = true;
        buyer = msg.sender;
        require(premiumToken.transferFrom(msg.sender, creator, premium), "Premium transfer failed");
    }

    /**
     * Transferring Buyer Role
     *
     * @param newBuyer - address of the new buyer
     */
    function transfer(address newBuyer) external onlyBuyer isInited notExpired {
        buyer = newBuyer;
    }

    /**
     * Executing Option - this function can be only called when the price of the asset is equal to or
     *     lower than the strike price, upon doing so, the contract will transfer locked-in NOTE
     *     tokens to the buyer and in return buyer will pay asset tokens to the creator
     */
    function execute() external onlyBuyer notExecuted isInited notExpired {
        require(_checkPosition(), "Option is out of the money");
        executed = true;
        uint256 amountToTransfer = strikeValue();
        require(premiumToken.transfer(buyer, amountToTransfer), "Asset transfer failed");
        require(IERC20(asset).transferFrom(buyer, creator, quantity), "Payment failed");
    }

    /**
     * Oracle Call - this is a helper function which calls the oracle contract to get the latest price
     *     data and returns a bool indicating whether the current asset price is equal or lower than
     *     the strike price, it also sets the value of executedPrice to the latest price
     */
    function _checkPosition() internal returns (bool) {
        (, int256 price,, uint256 updatedAt,) = priceOracle.latestRoundData();
        require(updatedAt + 2 minutes > block.timestamp, "Price needs to be updated first");
        executedPrice = uint256(price);
        return uint256(price) <= strikePrice;
    }

    /**
     * Cancelling Option - this function can be called only by the creator if the option has been
     *     initialized and there has been no buyer, which means the creator still can withdraw
     *     his NOTE tokens and cancel this contract
     */
    function cancel() external onlyCreator notBought isInited notExpired {
        executed = true;
        require(premiumToken.transfer(creator, strikeValue()), "Asset transfer failed");
    }

    /**
     * Withdraw Assets - this function can be called only by the creator after the option has expired
     *     and if it was not executed by the buyer, this results in the creator receiving back his
     *     locked-in NOTE tokens
     */
    function withdraw() external onlyCreator isInited {
        require(block.timestamp > expiration, "Option not expired yet");
        require(!executed, "Option already executed");
        executed = true;
        require(premiumToken.transfer(creator, strikeValue()), "Asset transfer failed");
    }

    /**
     * Adjusting Premium - this function can be called only by the creator if the option has been
     *     initialized and there has been no buyer, this results in adjusting the price/premium for
     *     the option, a creator might want to make use of this function if there has been a sudden
     *     change in the market dynamics and re-evaluate his/her position
     *
     * @param newPremium - new amount in NOTE
     */
    function adjustPremium(uint256 newPremium) external onlyCreator notBought notExpired {
        premium = newPremium;
    }

    /**
     * Strike Value - this is a helper function which returns amount in NOTE that is to be paid by
     *     the buyer if he/she executes the option
     */
    function strikeValue() public view returns (uint256) {
        return (strikePrice * quantity) / (10 ** priceOracle.decimals());
    }
}
