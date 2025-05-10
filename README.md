# FundMe

A Solidity smart contract that allows users to fund a project with ETH. Uses Chainlink price feeds to ensure a minimum funding amount in USD.

## Overview

FundMe is a decentralized funding smart contract built with Solidity and tested using Foundry. The contract allows users to:

- Fund the contract with ETH (minimum 5 USD equivalent)
- Contract owner can withdraw all funds
- Automatically converts ETH to USD using Chainlink price feeds

## Features

- **Minimum Funding Amount**: Ensures contributors send at least 5 USD worth of ETH
- **Multi-Network Support**: Works on mainnet, testnets (Sepolia), and local development networks
- **Automatic ETH/USD Conversion**: Uses Chainlink price feeds to get the latest ETH/USD price
- **Gas-Efficient Withdrawals**: Includes a cheaper withdrawal function to optimize gas costs
- **Comprehensive Test Suite**: Unit tests for all major functionality

## Project Structure

```
.
├── script/
│   ├── DeployFundMe.s.sol     # Deployment script
│   └── HelperConfig.s.sol     # Network configuration helper
├── src/
│   ├── FundMe.sol             # Main contract
│   └── PriceConverter.sol     # ETH to USD conversion library
└── test/
    ├── FundMe.t.sol           # Test suite
    └── mocks/
        └── MockV3Aggregator.sol # Mock for local testing
```

## Getting Started

### Prerequisites

- [Foundry](https://getfoundry.sh/)

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd fund-me
```

2. Install dependencies
```bash
forge install
```

### Deployment

To deploy to a local Anvil chain:

```bash
forge script script/DeployFundMe.s.sol --rpc-url http://localhost:8545 --private-key <your-private-key> --broadcast
```

To deploy to Sepolia testnet:

```bash
forge script script/DeployFundMe.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
```

### Testing

Run the tests:

```bash
forge test
```

Run with verbosity for more details:

```bash
forge test -vvv
```

Run gas reports:

```bash
forge test --gas-report
```

## Contract Functionality

### Funding

Users can fund the contract with ETH. The contract ensures that the ETH amount is equivalent to at least 5 USD.

```solidity
// Example
fundMe.fund{value: 1e18}(); // Sending 1 ETH
```

### Withdrawing

Only the contract owner can withdraw the funds.

```solidity
// Example
fundMe.withdraw(); // Regular withdrawal
fundMe.cheapWithdraw(); // Gas-optimized withdrawal
```

## Networks and Configuration

The contract can be deployed to:
- Ethereum Mainnet
- Sepolia Testnet
- Local Anvil Chain (with automatic mock deployment)

The `HelperConfig.s.sol` script automatically selects the correct price feed address based on the network.

## License

This project is licensed under the MIT License.



