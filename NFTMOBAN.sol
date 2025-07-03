// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract ArchiveNFT is ERC721URIStorage {
    string public description;
    string public tags;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory description_,
        string memory tags_,
        address receiver,
        string memory archivePointer,
        uint256 amount
    ) ERC721(name_, symbol_) {
        require(amount > 0, "Amount must be > 0");

        description = description_;
        tags = tags_;

        for (uint256 i = 1; i <= amount; i++) {
            _mint(receiver, i);
            _setTokenURI(i, archivePointer);
        }
    }
}

contract ArchiveNFTFactory {
    address[] public allNFTs;

    event NewNFT(
        address indexed nft,
        address indexed creator,
        string tokenURI,
        uint256 totalMinted,
        string description,
        string tags
    );

    function createNFT(
        string memory name,
        string memory symbol,
        string memory description,
        string memory tags,
        address receiver,
        string memory archivePointer,
        uint256 amount
    ) external returns (address nftAddr) {
        require(amount > 0, "Amount must be > 0");

        ArchiveNFT nft = new ArchiveNFT(
            name,
            symbol,
            description,
            tags,
            receiver,
            archivePointer,
            amount
        );

        allNFTs.push(address(nft));
        emit NewNFT(address(nft), msg.sender, archivePointer, amount, description, tags);
        return address(nft);
    }

    function getAllNFTs() external view returns (address[] memory) {
        return allNFTs;
    }
}
