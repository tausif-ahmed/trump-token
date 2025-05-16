# Trump Token Smart Contract

This is a Solana-based token contract implementing the Trump Token ($TRUMP) with various features including tax mechanism, minting, burning, and transfer functionality.

## Features

- **Token Information**
  - Name: Trump Token
  - Symbol: TRUMP
  - Decimals: 18
  - Max Supply: 1,000,000,000 TRUMP
  - Initial Supply: 100,000,000 TRUMP

- **Tax Mechanism**
  - Buy Tax: 2% (configurable up to 10%)
  - Sell Tax: 2% (configurable up to 10%)
  - Tax distribution: 50% to treasury, 50% to marketing wallet

- **Key Functions**
  - Minting (owner only)
  - Burning
  - Transfer with tax
  - Tax rate updates (owner only)
  - Wallet updates (owner only)
  - Tax exclusion for specific addresses
  - Pause/Unpause functionality

## Security Features

- OpenZeppelin contracts integration
- Pausable functionality
- Owner-only administrative functions
- Tax rate limits
- Zero address checks
- Supply cap enforcement

## Dependencies

- OpenZeppelin Contracts v4.x
- Solidity ^0.8.0

## Usage

1. Deploy the contract with treasury and marketing wallet addresses
2. Initial supply will be minted to the deployer
3. Configure tax rates and excluded addresses as needed
4. Start trading!

## License

MIT
