// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol";

interface ERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

interface ERC721 {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address owner) external view returns (uint balance);

    function ownerOf(uint tokenId) external view returns (address owner);

    function safeTransferFrom(address from, address to, uint tokenId) external payable;

    function safeTransferFrom(
        address from,
        address to,
        uint tokenId,
        bytes calldata data
    ) external payable;

    function transferFrom(address from, address to, uint tokenId) external payable;

    function approve(address to, uint tokenId) external;

    function getApproved(uint tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns (bool);
}

interface ERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

interface ERC721Metadata {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 _tokenId) external view returns (string memory);
}

interface ERC721Enumerable {
    function totalSupply() external view returns (uint256);

    function tokenByIndex(uint256 _index) external view returns (uint256);

    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
}

contract MyNFT is ERC721, ERC165, ERC721Metadata, ERC721Enumerable {

    mapping(uint => address) internal _ownerOf; //tokenId => owner

    mapping(address => uint) internal _balanceOf; //owner => number of tokens

    mapping(uint => address) internal _approvals; //tokenId => operator

    mapping(address => mapping(address => bool)) public isApprovedForAll; //owner => (operator => isApprovedForAll)

    function supportsInterface(
        bytes4 interfaceId
    ) external pure returns (bool) {
        return
            interfaceId == 0x80ac58cd || //ERC721
            interfaceId == 0x01ffc9a7 || //ERC165
            interfaceId == 0x5b5e139f || //ERC721Metadata
            interfaceId == 0x780e9d63;//ERC721Enumerable
    }

    function ownerOf(uint id) external view returns (address owner) {
        owner = _ownerOf[id];
        require(owner != address(0), "token doesn't exist");
    }

    function balanceOf(address owner) external view returns (uint) {
        require(owner != address(0), "owner = zero address");
        return _balanceOf[owner];
    }

    function setApprovalForAll(address operator, bool approved) external {
        isApprovedForAll[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function approve(address spender, uint id) external {
        address owner = _ownerOf[id];
        require(
            msg.sender == owner || isApprovedForAll[owner][msg.sender],
            "not authorized"
        );

        _approvals[id] = spender;

        emit Approval(owner, spender, id);
    }

    function getApproved(uint id) external view returns (address) {
        require(_ownerOf[id] != address(0), "token doesn't exist");
        return _approvals[id];
    }

    function _isApprovedOrOwner(
        address owner,
        address spender,
        uint id
    ) internal view returns (bool) {
        return (spender == owner ||
            isApprovedForAll[owner][spender] ||
            spender == _approvals[id]);
    }

    function _transferFrom(address from, address to, uint id) internal {
        require(from == _ownerOf[id], "from != owner");
        require(to != address(0), "transfer to zero address");

        require(_isApprovedOrOwner(from, msg.sender, id), "not authorized");

        _balanceOf[from]--;
        _balanceOf[to]++;
        _ownerOf[id] = to;

        delete _approvals[id];

        emit Transfer(from, to, id);
        emit Approval(from, address(0), id);
    }

    function transferFrom(address from, address to, uint id) external payable {
        _transferFrom(from, to, id);
    }

    function safeTransferFrom(address from, address to, uint id) external payable {
        _transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    id,
                    ""
                ) ==
                ERC721Receiver.onERC721Received.selector,
            "unsafe recipient"
        );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint id,
        bytes calldata data
    ) external payable {
        _transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    id,
                    data
                ) ==
                ERC721Receiver.onERC721Received.selector,
            "unsafe recipient"
        );
    }

    uint internal _lastId;

    function mint() public {
        _lastId += 1;
        _balanceOf[msg.sender]++;
        _ownerOf[_lastId] = msg.sender;

        _uris[_lastId] = string.concat(
            "https://www.luiztools.com.br/nfts/",
            Strings.toString(_lastId),
            ".json"
        );

        _allTokens.push(_lastId);
        _allTokensIndex[_lastId] = _allTokens.length - 1;
        _ownedTokens[msg.sender][_balanceOf[msg.sender] - 1] = _lastId;
        _ownedTokensIndex[_lastId] = _balanceOf[msg.sender] - 1;
        
        emit Transfer(address(0), msg.sender, _lastId);
    }

    function burn(uint tokenId) public {
        address lastOwner = _ownerOf[tokenId];
        require(lastOwner != address(0), "Not minted");
        require(
            _isApprovedOrOwner(lastOwner, msg.sender, tokenId),
            "Not permitted"
        );

        _balanceOf[lastOwner]--;
        _ownerOf[tokenId] = address(0);
        delete _uris[tokenId];
        delete _approvals[tokenId];
        
        //descobre qual index global deve ser removido
        uint removedIndex = _allTokensIndex[tokenId];
        //copia o último elemento pra posição excluída
        _allTokens[removedIndex]  = _allTokens[_allTokens.length - 1];
        //remove a cópia do final do array, simulando movimentação
        _allTokens.pop();
        //remove do índice de tokens
        delete _allTokensIndex[tokenId];

        //descobre qual owner index deve ser removido
        uint removedOwnerIndex = _ownedTokensIndex[tokenId];
        //sobrescreve o mapping de tokens do owner com cópia do último (balance porque já foi decrementado)
        _ownedTokens[msg.sender][removedOwnerIndex] = _ownedTokens[msg.sender][_balanceOf[msg.sender]];
        //exclui o último que está duplicado (balance porque já foi decrementado)
        delete _ownedTokens[msg.sender][_balanceOf[msg.sender]];
        //exclui do índice de tokens por owner
        delete _ownedTokensIndex[tokenId];

        emit Transfer(lastOwner, address(0), tokenId);
        emit Approval(lastOwner, address(0), tokenId);
    }

    function name() external pure returns (string memory) {
        return "MyNFT Collection";
    }

    function symbol() external pure returns (string memory) {
        return "MFC";
    }

    mapping(uint => string) internal _uris;

    function tokenURI(uint256 _tokenId) external view returns (string memory) {
        require(_ownerOf[_tokenId] != address(0), "Not minted");
        return _uris[_tokenId];
    }

    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;//owner => (owner index => tokenId)

    mapping(uint256 => uint256) private _ownedTokensIndex;//tokenId => owner index

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;//tokenId => global idnex

    function totalSupply() external view returns (uint256) {
        return _allTokens.length;
    }

    function tokenByIndex(uint256 _index) external view returns (uint256){
        require(_index < _allTokens.length, "Global index out of bounds");
        return _allTokens[_index];
    }

    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256){
        require(_index < _balanceOf[_owner], "Owner index out of bounds");
        return _ownedTokens[_owner][_index];
    }
}
