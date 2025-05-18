# Upgradable ERC20 Token - Foundry Implementation

This project implements an upgradable ERC20 token using the Foundry development framework and the UUPS (Universal Upgradeable Proxy Standard) proxy pattern from OpenZeppelin.

## Features

- Fully upgradable ERC20 token using the UUPS proxy pattern
- Standard ERC20 functionality with transfer and transferFrom
- ERC20Permit for gasless approvals
- Owner-controlled minting and burning
- Version tracking for implementations
- Storage gap for future extensions
- Example V2 implementation with:
  - Blacklisting functionality
  - Pausable transfers
  - Transfer with callback

## Project Structure

```
.
├── foundry.toml           # Foundry configuration file
├── lib                    # Dependencies
│   ├── forge-std
│   ├── openzeppelin-contracts
│   └── openzeppelin-contracts-upgradeable
├── script                 # Deployment scripts
│   ├── DeployToken.s.sol
│   └── UpgradeToken.s.sol
├── src                    # Source code
│   ├── UpgradableToken.sol
│   ├── UpgradableTokenV2.sol
│   └── TokenProxy.sol
└── test                   # Test files
    └── UpgradableToken.t.sol
```

## Getting Started

### Prerequisites

1. Install Foundry:
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. Clone the repository:
   ```bash
   git clone <repository-url>
   cd upgradable-token
   ```

3. Install dependencies:
   ```bash
   forge install
   ```

### Install Dependencies

```bash
forge install OpenZeppelin/openzeppelin-contracts
forge install OpenZeppelin/openzeppelin-contracts-upgradeable
```

### Compile

```bash
forge build
```

### Test

```bash
forge test
```

To see more detailed test output:

```bash
forge test -vvv
```

## Deployment

### Setup Environment

Create a `.env` file with your private key and RPC URL:

```
PRIVATE_KEY=your_private_key_here
MAINNET_RPC_URL=your_mainnet_rpc_url
SEPOLIA_RPC_URL=your_sepolia_rpc_url
ETHERSCAN_API_KEY=your_etherscan_api_key
```

Load the environment:

```bash
source .env
```

### Deploy to Testnet (Sepolia)

```bash
forge script script/DeployToken.s.sol:DeployToken --rpc-url $SEPOLIA_RPC_URL --broadcast --verify
```

This script will:
1. Deploy the implementation contract
2. Deploy the proxy contract
3. Initialize the token with name, symbol, and initial supply
4. Output the addresses of the implementation and proxy contracts

Save the proxy address for future upgrades!

### Upgrading to V2

Set the proxy address in your environment:

```bash
export PROXY_ADDRESS=0x...  # Replace with your proxy address
```

Then run the upgrade script:

```bash
forge script script/UpgradeToken.s.sol:UpgradeToken --rpc-url $SEPOLIA_RPC_URL --broadcast --verify
```

This script will:
1. Deploy the V2 implementation contract
2. Upgrade the proxy to point to the new implementation
3. Initialize the V2 functionality

## Contract Details

### UpgradableToken (V1)

The base token implementation with standard ERC20 functionality:

- **Name & Symbol**: Set during initialization
- **Decimals**: 18 (ERC20 default)
- **Total Supply**: Set during initialization, can be increased by minting
- **Owner**: The deployer address
- **Functions**:
  - `transfer`: Standard ERC20 transfer
  - `transferFrom`: Standard ERC20 transferFrom
  - `mint`: Create new tokens (owner only)
  - `burn`: Destroy tokens (owner only)
  - `upgradeTo`: Upgrade to a new implementation (owner only)

### UpgradableTokenV2

An extended version that adds:

- **Blacklisting**: Block specific addresses from sending or receiving tokens
- **Pausability**: Pause all transfers in emergency situations
- **Callback**: Support for callback on transfer for integration with other contracts

## Security Considerations

1. **Upgradeability Risks**: The contract owner has full control to upgrade the implementation. This is a significant centralization risk.

2. **Storage Layout**: When creating new versions, never modify the storage layout of existing variables.

3. **Storage Gaps**: Storage gaps are included to allow for future storage variables without affecting compatibility.

4. **Owner Control**: The owner can mint unlimited tokens, so trust in the owner is essential.

5. **Testing**: Always thoroughly test upgrades before deploying to mainnet.

## License

This project is licensed under the MIT License - see the LICENSE file for details.