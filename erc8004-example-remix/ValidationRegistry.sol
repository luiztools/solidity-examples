// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC8004IdentityRegistry {
    function exists(uint256 agentId) external view returns (bool);

    function ownerOf(uint256 agentId) external view returns (address);
}

contract ERC8004ValidationRegistry {
    struct ValidationRequest {
        uint256 agentId;
        address validatorAddress;
        string requestURI;
        bytes32 requestHash;
        uint256 timestamp;
    }

    struct ValidationResponse {
        bytes32 requestHash;
        uint8 response;
        string responseURI;
        bytes32 responseHash;
        string tag;
        uint256 lastUpdate;
    }

    IERC8004IdentityRegistry private _identityRegistry;
    mapping(bytes32 => ValidationRequest) public validationRequests;
    mapping(bytes32 => ValidationResponse) public validationResponses;
    mapping(uint256 => bytes32[]) public agentValidationRequests;
    mapping(address => bytes32[]) public validatorValidationRequests;

    event ValidationRequest(
        address indexed validatorAddress,
        uint256 indexed agentId,
        string requestURI,
        bytes32 indexed requestHash
    );

    event ValidationResponse(
        address indexed validatorAddress,
        uint256 indexed agentId,
        bytes32 indexed requestHash,
        uint8 response,
        string responseURI,
        bytes32 responseHash,
        string tag
    );

    function initialize(address identityRegistry) external {
        require(
            address(_identityRegistry) == address(0),
            "Already initialized"
        );
        require(identityRegistry != address(0), "Invalid address");

        _identityRegistry = IERC8004IdentityRegistry(identityRegistry);
    }

    function getIdentityRegistry() external view returns (address) {
        return address(_identityRegistry);
    }

    function validationRequest(
        address validatorAddress,
        uint256 agentId,
        string calldata requestURI,
        bytes32 requestHash
    ) external {
        require(address(_identityRegistry) != address(0), "Not initialized");
        require(
            validationRequests[requestHash].agentId == 0,
            "Request already exists"
        );
        require(_identityRegistry.exists(agentId), "Unknown agent");
        require(
            _identityRegistry.ownerOf(agentId) == msg.sender,
            "Cannot request validation for other agent"
        );
        require(
            validatorAddress != address(0) && validatorAddress != msg.sender,
            "Invalid validator"
        );
        require(
            requestURI.length == 0 || requestHash != bytes32(0),
            "Hash required with URI"
        );

        validationRequests[requestHash] = ValidationRequest({
            agentId: agentId,
            validatorAddress: validatorAddress,
            requestURI: requestURI,
            requestHash: requestHash,
            timestamp: block.timestamp,
        });

        agentValidationRequests[agentId].push(requestHash);
        validatorValidationRequests[validatorAddress].push(requestHash);

        emit ValidationRequest(
            validatorAddress,
            agentId,
            requestURI,
            requestHash
        );
    }

    function validationResponse(
        bytes32 requestHash,
        uint8 response,
        string responseURI,
        bytes32 responseHash,
        string tag
    ) external {
        require(address(_identityRegistry) != address(0), "Not initialized");
        ValidationRequest memory request = validationRequests[requestHash];
        require(request.agentId != 0, "Unknown request");
        require(request.validatorAddress == msg.sender, "Not validator");
        require(response >= 0 && response <= 100, "Invalid response");

        if (bytes(responseURI).length == 0) {
            require(responseHash == bytes32(0), "Hash without URI");
        }

        validationResponses[requestHash] = ValidationResponse({
            requestHash: requestHash,
            response: response,
            responseURI: responseURI,
            responseHash: responseHash,
            lastUpdate: block.timestamp,
            tag: tag
        });

        emit ValidationResponse(
            msg.sender,
            request.agentId,
            requestHash,
            response,
            responseURI,
            responseHash,
            tag
        );
    }

    function getValidationStatus(
        bytes32 requestHash
    )
        external
        view
        returns (
            address validatorAddress,
            uint256 agentId,
            uint8 response,
            bytes32 responseHash,
            string tag,
            uint256 lastUpdate
        )
    {
        ValidationRequest memory request = validationRequests[requestHash];
        require(request.agentId != 0, "Unknown request");

        ValidationResponse memory response = validationResponses[requestHash];

        return (
            request.validatorAddress,
            request.agentId,
            response.response,
            response.responseHash,
            response.tag,
            response.lastUpdate
        );
    }

    function getSummary(
        uint256 agentId,
        address[] calldata validatorAddresses,
        string tag
    ) external view returns (uint64 count, uint8 averageResponse) {
        require(address(_identityRegistry) != address(0), "Not initialized");
        require(_identityRegistry.exists(agentId), "Unknown agent");

        bytes32[] memory requests = agentValidationRequests[agentId];

        bool validatorFilter = validatorAddresses.length > 0;
        bool tagFilter = bytes(tag).length > 0;
        uint256 totalResponse = 0;
        count = 0;

        for (uint256 i = 0; i < requests.length; i++) {
            ValidationResponse memory response = validationResponses[requests[i]];
            ValidationRequest memory request = validationRequests[requests[i]];

            if (
                response.lastUpdate != 0 &&
                (!validatorFilter || contains(validatorAddresses, request.validatorAddress)) &&
                (!tagFilter || keccak256(bytes(response.tag)) == keccak256(bytes(tag)))
            ) {
                totalResponse += response.response;
                count++;
            }
        }

        averageResponse = count > 0 ? uint8(totalResponse / count) : 0;
    }

    function getAgentValidations(uint256 agentId) external view returns (bytes32[] memory requestHashes){
        require(address(_identityRegistry) != address(0), "Not initialized");
        require(_identityRegistry.exists(agentId), "Unknown agent");
        return agentValidationRequests[agentId];
    }

    function getValidatorRequests(address validatorAddress) external view returns (bytes32[] memory requestHashes){
        require(address(_identityRegistry) != address(0), "Not initialized");
        require(validatorAddress != address(0), "Invalid address");
        return validatorValidationRequests[validatorAddress];
    }
}
