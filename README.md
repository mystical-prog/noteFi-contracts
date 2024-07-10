# noteFi Smart Contracts

*Your Gateway to Truly Decentralized Options Trading on Canto*

## Overview
**noteFi** is a decentralized options protocol allowing users to create and trade option contracts with full customizability, supporting both CALL and PUT options.

# Getting Started

## Requirements

- git
- npm
- foundry

## Basic Setup

The below steps are sufficient enough for compiling the contracts on your local machine -

```sh
git clone https://github.com/PsyCodeLabs/noteFi-contracts.git
cd noteFi-contracts
npm install
forge build
```

## Tests

In order to run tests that have been written in the `test` folder - 

```sh
cp .env.example .env
```
*NOTE: The tests are designed for fork-testing on Canto Testnet only.*
You just need to add your wallet's private key inside the `.env` file and fund it with some testnet CANTO.
```sh
source .env
chmod +x updatePrice.sh
bash updatePrice.sh
forge test --fork-url $RPC
```

## Roles
These are the 3 broad types of users that will be interacting with the smart contracts.
- Writer: The user who wants to create/write a new option contract and has sufficient funds to do so.
- Buyer: The user who wants to buy an option contract directly from a writer or a seller.
- Seller: The user who is currently holding an option contract which is not written by him/her, and wants to resell it.

*Disclaimer: The code in this repo is unaudited, interact or use it at your own risk*