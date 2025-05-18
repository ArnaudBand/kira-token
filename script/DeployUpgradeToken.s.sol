// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import "forge-std/Script.sol";
import "../src/UpgradableToken.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

/**
 * @title DeployUpgradableToken
 * @dev Foundry script to deploy the upgradable token
 */
contract DeployUpgradableToken is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the implementation contract
        UpgradableToken implementation = new UpgradableToken();
        
        // Encode initialization function call
        bytes memory initData = abi.encodeWithSelector(
            UpgradableToken.initialize.selector,
            1_000_000 * 10**56 // 1 million tokens with 56 decimals
        );
        
        // Deploy the proxy contract pointing to the implementation
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            initData
        );
        
        // The token is now accessible at the proxy address
        UpgradableToken token = UpgradableToken(address(proxy));
        
        console.log("UpgradableToken deployed at:", address(token));
        console.log("Implementation deployed at:", address(implementation));

        vm.stopBroadcast();
    }
}