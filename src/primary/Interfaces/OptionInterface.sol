// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface OptionInterface {

        /* ============ Events ============ */

    // buy function event
    event buyEvent(address indexed buyer, uint256 indexed premiumPaid);

    // execute function event
    event executeEvent(address indexed buyer, uint256 indexed quantity, uint256 amountPaid);

    // cancel function event
    event cancelEvent(address indexed writer, uint256 indexed quantity);

    // withdraw function event
    event withdrawEvent(address indexed writer, uint256 indexed quantity);

    // adjustPremium function event
    event adjustPremiumEvent(uint256 indexed oldPremium, uint256 indexed newPremium);

    // tranfer function event, event for when buyer is being tranferred to a new buyer
    event transferBuyerRoleEvent(address indexed oldBuyer, address indexed newBuyer);


    function init() external;

    function buy() external;

    function transfer(address buyer) external;

    function execute() external;

    function cancel() external;

    function withdraw() external;

    function adjustPremium(uint256 premium) external;

}