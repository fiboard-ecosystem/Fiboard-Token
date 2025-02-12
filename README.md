# Fiboard Token

Fiboard is a token built on the Binance Smart Chain (BNB), developed using Solidity and managed with Hardhat for smart contract deployment and testing.

## Features

- **Blockchain:** Binance Smart Chain (BSC)
- **Programming Language:** Solidity
- **Development Framework:** Hardhat

## Prerequisites

Before getting started, make sure you have the following installed:

- [Node.js](https://nodejs.org/) (version 12 or later)
- [npm](https://www.npmjs.com/) or [Yarn](https://yarnpkg.com/)

## Installation

Clone the repository and install dependencies:

```bash
git clone https://github.com/FBDtoken/FBDtoken.git
cd FBDtoken
npm install
```

## Configuration
```
Add mnemonic to ignition/modules Token.js

```

**Note:** Your private key is used to sign transactions; do not share it with anyone.

## Compilation

To compile the smart contracts, run:

```bash
npx hardhat compile
```

## Deployment

To deploy the contract on the testnet or mainnet BSC, run:

```bash
npx hardhat run scripts/deploy.js --network mainnet
npx hardhat run scripts/deploy.js --network testnet
```

Networks are configured in the `hardhat.config.js` file.

## Testing

To run tests, execute:

```bash
npx hardhat test
```

## Resources

- [Official Fiboard Website](https://fiboard.org/)
- [Hardhat Documentation](https://hardhat.org/getting-started/)

## Contribution

Contributions are welcome! Please open an Issue before submitting a Pull Request to discuss proposed changes.

## License

This project is licensed under the MIT License. For more details, see the [LICENSE](LICENSE) file.
