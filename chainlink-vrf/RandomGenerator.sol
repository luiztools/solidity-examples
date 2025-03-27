// SPDX-License-Identifier: MIT

pragma solidity ^0.8.29;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

contract RandomGenerator is VRFConsumerBaseV2Plus {
    uint256 s_subscriptionId;
    address vrfCoordinator = 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B;
    bytes32 s_keyHash = 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;
    uint32 callbackGasLimit = 40000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;

    uint constant private MAX = 100;
    mapping(uint256 => address) public s_requests;
    mapping(address => uint256) public s_results;

    constructor(uint256 subscriptionId) VRFConsumerBaseV2Plus(vrfCoordinator) {
        s_subscriptionId = subscriptionId;
    }

    function random(address requester) public onlyOwner returns (uint256 requestId) {
       requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: s_keyHash,
                subId: s_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                // use nativePayment como true se quiser pagar com a moeda nativa da rede
                extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
            })
        );

        s_requests[requestId] = requester;
        s_results[requester] = 0;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        uint256 randomValue = (randomWords[0] % MAX) + 1;
        s_results[s_requests[requestId]] = randomValue;
    }

    function pseudoRandom(uint256 seed, uint256 max)
        public
        view
        returns (uint256)
    {
        return
            uint256(keccak256(abi.encodePacked(block.timestamp, seed))) % max;
    }
}
