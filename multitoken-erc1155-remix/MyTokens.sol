// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.2/contracts/utils/Strings.sol";

interface ERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

interface ERC1155 {
    event TransferSingle(
        address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256 _id,
        uint256 _value
    );

    event TransferBatch(
        address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256[] _ids,
        uint256[] _values
    );

    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    event URI(string _value, uint256 indexed _id);

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) external;

    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) external;

    function balanceOf(address _owner, uint256 _id)
        external
        view
        returns (uint256);

    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids)
        external
        view
        returns (uint256[] memory);

    function setApprovalForAll(address _operator, bool _approved) external;

    function isApprovedForAll(address _owner, address _operator)
        external
        view
        returns (bool);
}

interface ERC1155TokenReceiver {
    function onERC1155Received(
        address _operator,
        address _from,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) external returns (bytes4);

    function onERC1155BatchReceived(
        address _operator,
        address _from,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) external returns (bytes4);
}

interface ERC1155Metadata_URI {
    function uri(uint256 _id) external view returns (string memory);
}

contract MyTokens is ERC1155, ERC165, ERC1155Metadata_URI {
    mapping(uint256 => mapping(address => uint256)) private _balances; //tokenId => (owner => balance)
    mapping(address => mapping(address => bool)) private _approvals; //owner => (operator => approved)

    uint private constant NFT_1 = 0;
    uint private constant NFT_2 = 1;
    uint private constant NFT_3 = 2;

    uint[] public _currentSupply = [50, 50, 50];

    uint public _tokenPrice = 0.01 ether;

    function balanceOf(address _owner, uint256 _id)
        external
        view
        returns (uint256)
    {
        require(_id < 3, "This token does not exists");
        return _balances[_id][_owner];
    }

    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids)
        external
        view
        returns (uint256[] memory)
    {
        require(
            _owners.length == _ids.length,
            "The array params must be equals in length"
        );
        uint256[] memory result = new uint256[](_owners.length);
        for (uint256 i = 0; i < _owners.length; i++) {
            require(_ids[i] < 3, "This token does not exists");
            result[i] = _balances[_ids[i]][_owners[i]];
        }
        return result;
    }

    function _isApprovedOrOwner(address _owner, address _spender)
        private
        view
        returns (bool)
    {
        return _owner == _spender || _approvals[_owner][_spender];
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) external {
        require(_isApprovedOrOwner(_from, msg.sender), "Not authorized");
        require(_from != address(0), "The from address must not be zero");
        require(_to != address(0), "The to address must not be zero");
        require(_from != _to, "The from and to addresses must be different");
        require(_value > 0, "The value must not be zero");
        require(_balances[_id][_from] >= _value, "Insufficient balance");

        _balances[_id][_from] -= _value;
        _balances[_id][_to] += _value;

        emit TransferSingle(msg.sender, _from, _to, _id, _value);

        require(
            _to.code.length == 0 ||
                ERC1155TokenReceiver(_to).onERC1155Received(
                    msg.sender,
                    _from,
                    _id,
                    _value,
                    _data
                ) ==
                ERC1155TokenReceiver.onERC1155Received.selector,
            "unsafe recipient"
        );
    }

    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) external {
        require(_isApprovedOrOwner(_from, msg.sender), "Not authorized");
        require(_from != address(0), "The from address cannot be zero");
        require(_to != address(0), "The to address cannot be zero");
        require(_from != _to, "The from and to addresses cannot be equal");
        require(
            _ids.length == _values.length,
            "The array params length must be equals"
        );

        for (uint256 i = 0; i < _ids.length; i++) {
            require(
                _balances[_ids[i]][_from] >= _values[i],
                "Insufficient balance"
            );

            _balances[_ids[i]][_from] -= _values[i];
            _balances[_ids[i]][_to] += _values[i];
        }

        emit TransferBatch(msg.sender, _from, _to, _ids, _values);

        require(
            _to.code.length == 0 ||
                ERC1155TokenReceiver(_to).onERC1155BatchReceived(
                    msg.sender,
                    _from,
                    _ids,
                    _values,
                    _data
                ) ==
                ERC1155TokenReceiver.onERC1155BatchReceived.selector,
            "unsafe recipient"
        );
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        require(_operator != address(0), "The operator address cannot be zero");

        _approvals[msg.sender][_operator] = _approved;

        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function isApprovedForAll(address _owner, address _operator)
        external
        view
        returns (bool)
    {
        return _approvals[_owner][_operator];
    }

    function supportsInterface(bytes4 interfaceID)
        external
        pure
        returns (bool)
    {
        return
            interfaceID == 0x01ffc9a7 || // ERC-165 support (i.e. `bytes4(keccak256('supportsInterface(bytes4)'))`).
            interfaceID == 0x4e2312e0 || // ERC-1155 `ERC1155TokenReceiver` support (i.e. `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)")) ^ bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`).
            interfaceID == 0x0e89341c;//ERC1155Metadata_URI 
    }

    function mint(uint _tokenId) external payable {
        require(_tokenId < 3, "Invalid token id");
        require(_currentSupply[_tokenId] > 0, "Max supply reached");
        require(msg.value >= _tokenPrice, "Insufficient payment");

        _balances[_tokenId][msg.sender] = 1;
        _currentSupply[_tokenId] -= 1;

        emit TransferSingle(msg.sender, address(0), msg.sender, _tokenId, 1);

        require(
            msg.sender.code.length == 0 ||
                ERC1155TokenReceiver(msg.sender).onERC1155Received(
                    msg.sender,
                    address(0),
                    _tokenId,
                    1,
                    ""
                ) ==
                ERC1155TokenReceiver.onERC1155Received.selector,
            "unsafe recipient"
        );
    }

    function burn(
        address _from,
        uint256 _tokenId
    ) public {
        require(_from != address(0), "ERC1155: burn from the zero address");
        require(_tokenId < 3, "This token does not exists");
        require(_balances[_tokenId][_from] >= 1, "Insufficient balance" );
        require(_isApprovedOrOwner(_from, msg.sender), "You do not have permission");

        _balances[_tokenId][_from] -= 1;

        emit TransferSingle(msg.sender, _from, address(0), _tokenId, 1);
    }

    function uri(uint256 _tokenId) external pure returns (string memory) {
        require(_tokenId < 3, "This token does not exists");
        return string.concat("https://www.luiztools.com.br/", Strings.toString(_tokenId), ".json");
    }
}
