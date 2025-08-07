pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/access/Ownable.sol";
import "https://github.com/chainlink/chainlink-evm-contracts/contracts/src/v0.8/VRFConsumerBase.sol";

contract llui_create_a_data_dAppNotifier {
    // Mapping of user addresses to their notification settings
    mapping (address => NotificationSettings) public userSettings;

    // Struct to hold notification settings
    struct NotificationSettings {
        bool newDataAvailable;
        uint256 lastCheckedBlock;
        uint256 notificationInterval;
    }

    // Event emitted when new data is available
    event NewDataAvailable(address user, uint256 blockNumber);

    // VRF (Verifiable Random Function) for generating random numbers
    VRFConsumerBase internal immutable vrf;

    // Constructor
    constructor(address vrfCoordinator, address linkToken) public {
        vrf = VRFConsumerBase(vrfCoordinator, linkToken);
    }

    // Function to update notification settings
    function setNotificationSettings(bool newDataAvailable, uint256 notificationInterval) public {
        userSettings[msg.sender] = NotificationSettings(newDataAvailable, block.number, notificationInterval);
    }

    // Function to check for new data and send notifications
    function checkForNewData() public {
        // Iterate over user settings
        for (address user in userSettings) {
            // Check if new data is available and user has not been notified recently
            if (userSettings[user].newDataAvailable && block.number - userSettings[user].lastCheckedBlock > userSettings[user].notificationInterval) {
                // Generate a random number using VRF
                uint256 randomness = vrf.requestRandomWords();
                // Emit event to notify user
                emit NewDataAvailable(user, block.number);
                // Update last checked block
                userSettings[user].lastCheckedBlock = block.number;
            }
        }
    }
}