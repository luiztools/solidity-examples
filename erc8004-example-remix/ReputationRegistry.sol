// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC8004IdentityRegistry {
    function exists(uint256 agentId) external view returns (bool);
    function ownerOf(uint256 agentId) external view returns (address);
}

contract ReputationRegistry {
    event NewFeedback(
        uint256 indexed agentId,
        address indexed clientAddress,
        uint64 feedbackIndex,
        int128 value,
        uint8 valueDecimals
    );

    event FeedbackRevoked(uint256 indexed agentId, address indexed clientAddress, uint64 indexed feedbackIndex);

    event ResponseAppended(uint256 indexed agentId, address indexed clientAddress, uint64 feedbackIndex, address indexed responder, string responseURI, bytes32 responseHash);

    struct Feedback {
        uint256 agentId;
        address from;
        int128 value;
        uint8 valueDecimals;
        uint256 timestamp;
        bool revoked;
    }

    struct Response {
        address responder;
        string responseURI;
        bytes32 responseHash;
        uint256 timestamp;
    }

    struct Aggregate {
        int256 sum;
        uint256 count;
        uint256 avg;
    }

    uint8 constant DECIMALS = 2;
    IERC8004IdentityRegistry private _identityRegistry;
    mapping(uint256 => Feedback[]) private _feedbacks;
    mapping(uint256 => mapping(uint256 => Response[])) public responses;
    mapping(uint256 => Aggregate) public aggregate;
    mapping(uint256 => mapping(address => bool)) private _feedbackAuthorizations;

    function initialize(address identityRegistry) external {
        require(address(_identityRegistry) == address(0), "Already initialized");
        require(identityRegistry != address(0), "Invalid address");

        _identityRegistry = IERC8004IdentityRegistry(identityRegistry);
    }

    function getIdentityRegistry() external view returns (address) {
        return address(_identityRegistry);
    }

    function authorizeFeedback(uint256 agentId, address clientAddress) external {
        require(address(_identityRegistry) != address(0), "Not initialized");
        require(_identityRegistry.exists(agentId), "Unknown agent");
        require(_identityRegistry.ownerOf(agentId) == msg.sender, "Only agent owner can authorize");

        _feedbackAuthorizations[agentId][clientAddress] = true;
    }

    function giveFeedback(
        uint256 agentId,
        int128 value,
        uint8 valueDecimals
    ) external {
        require(address(_identityRegistry) != address(0), "Not initialized");
        require(_identityRegistry.exists(agentId), "Unknown agent");
        require(valueDecimals == DECIMALS, "Invalid decimals");

        require(_feedbackAuthorizations[agentId][msg.sender] && _identityRegistry.ownerOf(agentId) != msg.sender, "Not authorized to give feedback");
        _feedbackAuthorizations[agentId][msg.sender] = false; // Revoke authorization to prevent reentrancy

        _feedbacks[agentId].push(
            Feedback({
                agentId: agentId,
                from: msg.sender,
                value: value,
                valueDecimals: DECIMALS,
                timestamp: block.timestamp,
                revoked: false
            })
        );

        Aggregate storage agg = aggregate[agentId];
        agg.sum += value;
        agg.count += 1;
        agg.avg = agg.sum / agg.count;

        emit NewFeedback(
            agentId,
            msg.sender,
            _feedbacks[agentId].length - 1,
            value,
            DECIMALS
        );
    }

    function revokeFeedback(uint256 agentId, uint64 feedbackIndex) external {
        require(address(_identityRegistry) != address(0), "Not initialized");
        require(_identityRegistry.exists(agentId), "Unknown agent");
        require(feedbackIndex < _feedbacks[agentId].length, "Invalid index");

        Feedback memory feedback = _feedbacks[agentId][feedbackIndex];
        require(feedback.from == msg.sender, "Not feedback author");

        // Update aggregate before removing feedback
        Aggregate storage agg = aggregate[agentId];
        agg.sum -= feedback.value;
        agg.count -= 1;
        agg.avg = agg.count > 0 ? agg.sum / agg.count : int256(0);

        _feedbacks[agentId][feedbackIndex].revoked = true; // Mark as revoked instead of removing to maintain indices

        emit FeedbackRevoked(agentId, msg.sender, feedbackIndex);
    }

    function appendResponse(uint256 agentId, address clientAddress, uint64 feedbackIndex, string calldata responseURI, bytes32 responseHash) external {
        require(address(_identityRegistry) != address(0), "Not initialized");
        require(_identityRegistry.exists(agentId), "Unknown agent");
        require(feedbackIndex < _feedbacks[agentId].length, "Invalid index");

        bool isAgentOwner = clientAddress == msg.sender && _identityRegistry.ownerOf(agentId) == msg.sender;
        bool isClient = clientAddress == msg.sender && clientAddress == _feedbacks[agentId][feedbackIndex].from;
        require(isAgentOwner || isClient, "Only agent owner or feedback author can respond");

        responses[agentId][feedbackIndex].push(
            Response({
                responder: msg.sender,
                responseURI: responseURI,
                responseHash: responseHash,
                timestamp: block.timestamp
            })
        );

        emit ResponseAppended(
            agentId,
            clientAddress,
            feedbackIndex,
            msg.sender,
            responseURI,
            responseHash
        );
    }

    function contains(address[] memory addrSet, address addr) private pure returns (bool){
        for(uint256 i=0; i < addrSet.length; i++){
            if(addr == addrSet[i]) return true;
        }
        return false;
    }

    function getSummary(uint256 agentId, address[] calldata clientAddresses, string tag1, string tag2) external view returns (uint64 count, int128 summaryValue, uint8 summaryValueDecimals){
        require(clientAddresses.length > 0, "clientAddresses is required");
        require(address(_identityRegistry) != address(0), "Not initialized");
        require(_identityRegistry.exists(agentId), "Unknown agent");

        count = 0;
        summaryValue = 0;
        summaryValueDecimals = DECIMALS;

        for (uint256 i = 0; i < _feedbacks[agentId].length; i++) {
            Feedback memory feedback = _feedbacks[agentId][i];
            if (!feedback.revoked && contains(clientAddresses, feedback.from)) {
                summaryValue += feedback.value;
                count++;
            }
        }

        summaryValue = count > 0 ? summaryValue / count : int128(0);   
    }

    function readFeedback(uint256 agentId, address clientAddress, uint64 feedbackIndex) external view returns (int128 value, uint8 valueDecimals, string tag1, string tag2, bool isRevoked) {
        require(feedbackIndex < _feedbacks[agentId].length, "Invalid index");
        
        Feedback memory feedback;
        if(clientAddress != address(0)) {
            uint64 aux = 0;
            for(uint64 i = 0; i < _feedbacks[agentId].length; i++) {
                if(_feedbacks[agentId][i].from == clientAddress){
                    if(aux == feedbackIndex) {
                        feedback = _feedbacks[agentId][i];
                        break;
                    }
                    else aux++;
                } 
            }
            require(feedback.from == clientAddress, "Feedback not found for specified client");
        } else {
             feedback = _feedbacks[agentId][feedbackIndex];
        } 

        value = feedback.value;
        valueDecimals = feedback.valueDecimals;
        tag1 = ""; // Placeholder, as tags are not implemented in this example
        tag2 = ""; // Placeholder, as tags are not implemented in this example
        isRevoked = feedback.revoked;
    }

    function readAllFeedback(uint256 agentId, address[] calldata clientAddresses, string tag1, string tag2, bool includeRevoked) external view returns (address[] memory clients, uint64[] memory feedbackIndexes, int128[] memory values, uint8[] memory valueDecimals, string[] memory tag1s, string[] memory tag2s, bool[] memory revokedStatuses){
        require(clientAddresses.length > 0, "clientAddresses is required");
        require(address(_identityRegistry) != address(0), "Not initialized");
        require(_identityRegistry.exists(agentId), "Unknown agent");

        // For simplicity, this example does not implement tag-based filtering. In a real implementation, you would need to store tags in the Feedback struct and filter accordingly.
        uint64 count = 0;
        for (uint64 i = 0; i < _feedbacks[agentId].length; i++) {
            Feedback memory feedback = _feedbacks[agentId][i];
            if ((includeRevoked || !feedback.revoked) && (clientAddresses.length == 0 || contains(clientAddresses, feedback.from))) {
                count++;
            }
        }

        clients = new address[](count);
        feedbackIndexes = new uint64[](count);
        values = new int128[](count);
        valueDecimals = new uint8[](count);
        tag1s = new string[](count);
        tag2s = new string[](count);
        revokedStatuses = new bool[](count);

        uint64 index = 0;
        for (uint64 i = 0; i < _feedbacks[agentId].length; i++) {
            Feedback memory feedback = _feedbacks[agentId][i];
            if ((includeRevoked || !feedback.revoked) && (clientAddresses.length == 0 || contains(clientAddresses, feedback.from))) {
                clients[index] = feedback.from;
                feedbackIndexes[index] = i;
                values[index] = feedback.value;
                valueDecimals[index] = feedback.valueDecimals;
                tag1s[index] = ""; // Placeholder, as tags are not implemented in this example
                tag2s[index] = ""; // Placeholder, as tags are not implemented in this example
                revokedStatuses[index] = feedback.revoked;
                index++;
            }
        }
    }

    function getResponseCount(uint256 agentId, address clientAddress, uint64 feedbackIndex, address[] responders) external view returns (uint64 count){
        require(address(_identityRegistry) != address(0), "Not initialized");
        require(_identityRegistry.exists(agentId), "Unknown agent");
        count = 0;

        bool clientFilter = clientAddress != address(0);
        bool responderFilter = responders.length > 0;

        if(clientFilter){
            uint64 aux = 0;
            for (uint64 i = 0; i < _feedbacks[agentId].length; i++) {
                if (_feedbacks[agentId][i].from == clientAddress) {
                    if(aux == feedbackIndex) {
                        for (uint64 j = 0; j < responses[agentId][i].length; j++) {
                            Response memory response = responses[agentId][i][j];
                            if (!responderFilter || contains(responders, response.responder)) {
                                count++;
                            }
                        }
                    }
                    else aux++;
                }
            }
        }
        else {
            for (uint64 i = 0; i < responses[agentId][feedbackIndex].length; i++) {
                Response memory response = responses[agentId][feedbackIndex][i];
                if (!responderFilter || contains(responders, response.responder)) {
                    count++;
                }
            }
        }
    }

    function getClients(uint256 agentId) external view returns (address[] memory){
        require(address(_identityRegistry) != address(0), "Not initialized");
        require(_identityRegistry.exists(agentId), "Unknown agent");

        uint256 count = _feedbacks[agentId].length;
        address[] memory clients = new address[](count);
        for(uint256 i=0; i < count; i++){
            clients[i] = _feedbacks[agentId][i].from;
        }
        return clients;
    }

    function getLastIndex(uint256 agentId, address clientAddress) external view returns (uint256){
        require(address(_identityRegistry) != address(0), "Not initialized");
        require(_identityRegistry.exists(agentId), "Unknown agent");
        require(clientAddress != address(0), "Invalid client address");

        for (uint256 i = _feedbacks[agentId].length - 1; i >= 0; i--) {
            if (_feedbacks[agentId][i].from == clientAddress && !_feedbacks[agentId][i].revoked) {
                return i;
            }
        }
        revert("No feedback from this client");
    }
}