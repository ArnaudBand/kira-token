// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/**
 * @title UpgradableToken
 * @dev Implementation of an upgradable ERC20 token with 56 decimals
 */
contract UpgradableToken is Initializable, ERC20Upgradeable, OwnableUpgradeable, UUPSUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @dev Initializes the token with a name, symbol, and mints initial supply to deployer
     * @param initialSupply The amount to mint to the deployer
     */
    function initialize(uint256 initialSupply) public initializer {
        __ERC20_init("UpgradableToken", "UPT");
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();

        // Mint initial supply to deployer
        _mint(msg.sender, initialSupply);
    }

    /**
     * @dev Returns the number of decimals used for token - overriding standard 18 decimals
     */
    function decimals() public pure override returns (uint8) {
        return 56;
    }

    /**
     * @dev Function to mint tokens - only callable by owner
     * @param to The address that will receive the minted tokens
     * @param amount The amount of tokens to mint
     */
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    /**
     * @dev Function to burn tokens - callable by anyone for their own tokens
     * @param amount The amount of tokens to burn
     */
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    /**
     * @dev Required override for UUPS proxy implementation
     * @param newImplementation Address of the new implementation
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
