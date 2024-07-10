# Primary Contracts

This folder contains all the logic that is necessary for primary writing and buying of an option contract.

## Factory

This contract is responsible for creating / writing new options and keeping track of all the options created in past. The usage of factory contract makes sure that the logic of the created option contracts is not altered.

## Call

The buyer of the call option has the right to execute the trade of assets (as defined in the contract) (the buyer of the option can buy the asset from the writer at the strike price) if the price of the asset is at or above the strike price. The writer must lock in the specified amount of the asset in the contract.

## Put

The buyer of the put option has the right to execute the trade of assets (as defined in the contract) (the buyer of the option can sell the asset to the writer at the strike price) if the price of the asset is at or below the strike price. The writer must lock in the specified amount of premium token in the contract.

## AggregatorV3Interface

This is an interface file for the Oracle that we are using for fetching prices. We have deployed V3 Pyth Aggregators for the required price feeds on Canto Testnet. Since it works on the on-demand model, we need to update the Aggregators with the latest price, as both  `Call.sol` and `Put.sol` makes a check that the price timestamp of the fetched price need not be older than 2 minutes.

*For detailed understanding of option contracts, check out [Investopedia](https://www.investopedia.com/terms/o/optionscontract.asp).*