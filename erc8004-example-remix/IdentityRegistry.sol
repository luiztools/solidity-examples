// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

// OpenZeppelin imports
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract IdentityRegistry is ERC721URIStorage, Ownable {
    uint256 private _nextId;
    mapping(uint256 => bool) private _active;

    event Registered(
        uint256 indexed agentId,
        string agentURI,
        address indexed owner
    );

    constructor()
        ERC721("ERC8004 Agent Identity", "AGENT")
        Ownable(msg.sender)
    {}

    function register(
        string calldata agentURI
    ) external onlyOwner returns (uint256 agentId) {
        agentId = _nextId++;

        _safeMint(msg.sender, agentId);
        _setTokenURI(agentId, agentURI);

        _active[agentId] = true;

        emit Registered(agentId, agentURI, msg.sender);
    }

    function resolve(
        uint256 agentId
    )
        external
        view
        returns (address owner, string memory metadataURI, bool active)
    {
        require(_ownerOf(agentId) != address(0), "Agent does not exist");

        return (ownerOf(agentId), tokenURI(agentId), _active[agentId]);
    }

    function deactivate(uint256 agentId) external onlyOwner {
        _active[agentId] = false;
    }

    function exists(uint256 agentId) external view returns (bool) {
        return _ownerOf(agentId) != address(0);
    }

    function approve(address, uint256) public pure override(ERC721, IERC721) {
        revert("Soulbound: approvals disabled");
    }

    function setApprovalForAll(
        address,
        bool
    ) public pure override(ERC721, IERC721) {
        revert("Soulbound: approvals disabled");
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override(ERC721, IERC721) {
        revert("Soulbound: transfers disabled");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public override(ERC721, IERC721) {
        revert("Soulbound: transfers disabled");
    }
}
