// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/MemeFactory.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("Deploying contracts with account:", deployer);
        console.log("Account balance:", deployer.balance);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy MemeFactory
        MemeFactory factory = new MemeFactory();
        
        vm.stopBroadcast();
        
        console.log("MemeFactory deployed to:", address(factory));
        console.log("Implementation address:", factory.implementation());
        console.log("Factory owner:", factory.owner());
        
        // Save deployment info
        string memory deploymentInfo = string.concat(
            "MemeFactory deployed at: ",
            vm.toString(address(factory)),
            "\nImplementation: ",
            vm.toString(factory.implementation()),
            "\nOwner: ",
            vm.toString(factory.owner())
        );
        
        vm.writeFile("deployment.txt", deploymentInfo);
        console.log("Deployment info saved to deployment.txt");
    }
}
