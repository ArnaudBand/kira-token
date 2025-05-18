// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import "forge-std/Test.sol";
import "../src/UpgradableToken.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

/**
 * @title UpgradableTokenV2
 * @dev Example of an upgraded version of the token with new functionality
 */
contract UpgradableTokenV2 is UpgradableToken {
    uint256 public maxSupply;
    bool public tradingEnabled;
    mapping(address => bool) public blacklisted;

    /**
     * @dev Initializes the V2 specific state variables
     * @param _maxSupply The maximum supply of tokens
     */
    function initializeV2(uint256 _maxSupply) public reinitializer(2) {
        maxSupply = _maxSupply;
        tradingEnabled = true;
    }

    /**
     * @dev Enables or disables trading
     * @param _enabled Whether trading should be enabled
     */
    function setTradingEnabled(bool _enabled) public onlyOwner {
        tradingEnabled = _enabled;
    }

    /**
     * @dev Blacklists or unblacklists an address
     * @param account The address to blacklist
     * @param isBlacklisted Whether the address should be blacklisted
     */
    function setBlacklisted(address account, bool isBlacklisted) public onlyOwner {
        blacklisted[account] = isBlacklisted;
    }

    /**
     * @dev Overrides the transfer function to check if trading is enabled and if addresses are blacklisted
     */
    function _transfer(address from, address to, uint256 amount) internal override {
        require(tradingEnabled, "Trading is disabled");
        require(!blacklisted[from], "Sender is blacklisted");
        require(!blacklisted[to], "Recipient is blacklisted");
        super._transfer(from, to, amount);
    }

    /**
     * @dev Overrides the mint function to check if max supply would be exceeded
     */
    function mint(address to, uint256 amount) public override onlyOwner {
        if (maxSupply > 0) {
            require(totalSupply() + amount <= maxSupply, "Max supply exceeded");
        }
        super.mint(to, amount);
    }
}

/**
 * @title UpgradableTokenTest
 * @dev Test contract for the upgradable token
 */
contract UpgradableTokenTest is Test {
    UpgradableToken public token;
    address public owner;
    address public user1;
    address public user2;
    uint256 public initialSupply = 1_000_000 * 10**56; // 1 million tokens with 56 decimals
    
    function setUp() public {
        owner = address(this);
        user1 = address(0x1);
        user2 = address(0x2);
        
        // Deploy implementation
        UpgradableToken implementation = new UpgradableToken();
        
        // Encode initialization data
        bytes memory initData = abi.encodeWithSelector(
            UpgradableToken.initialize.selector,
            initialSupply
        );
        
        // Deploy proxy
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            initData
        );
        
        // Get token instance
        token = UpgradableToken(address(proxy));
    }
    
    function testInitialState() public {
        assertEq(token.name(), "UpgradableToken");
        assertEq(token.symbol(), "UPT");
        assertEq(token.decimals(), 56);
        assertEq(token.totalSupply(), initialSupply);
        assertEq(token.balanceOf(owner), initialSupply);
    }
    
    function testTransfer() public {
        uint256 amount = 1000 * 10**56;
        token.transfer(user1, amount);
        assertEq(token.balanceOf(user1), amount);
        assertEq(token.balanceOf(owner), initialSupply - amount);
    }
    
    function testMint() public {
        uint256 amount = 500 * 10**56;
        token.mint(user2, amount);
        assertEq(token.balanceOf(user2), amount);
        assertEq(token.totalSupply(), initialSupply + amount);
    }
    
    function testBurn() public {
        uint256 amount = 300 * 10**56;
        token.burn(amount);
        assertEq(token.balanceOf(owner), initialSupply - amount);
        assertEq(token.totalSupply(), initialSupply - amount);
    }
    
    function testUpgrade() public {
        // Deploy new implementation
        UpgradableTokenV2 newImplementation = new UpgradableTokenV2();
        
        // Upgrade
        token.upgradeToAndCall(address(newImplementation), "");
        
        // Cast to V2
        UpgradableTokenV2 tokenV2 = UpgradableTokenV2(address(token));
        
        // Initialize V2 specific state
        tokenV2.initializeV2(10_000_000 * 10**56); // 10 million max supply
        
        // Test V2 functionality
        assertEq(tokenV2.maxSupply(), 10_000_000 * 10**56);
        assertEq(tokenV2.tradingEnabled(), true);
        
        // Test original functionality still works
        assertEq(tokenV2.balanceOf(owner), initialSupply - 300 * 10**56); // Adjusted for previous burn
        
        // Test new functionality
        tokenV2.setTradingEnabled(false);
        assertEq(tokenV2.tradingEnabled(), false);
        
        tokenV2.setBlacklisted(user1, true);
        assertEq(tokenV2.blacklisted(user1), true);
        
        // Re-enable trading for transfer test
        tokenV2.setTradingEnabled(true);
        
        // Test transfer with blacklist
        vm.expectRevert("Recipient is blacklisted");
        tokenV2.transfer(user1, 100 * 10**56);
    }
}