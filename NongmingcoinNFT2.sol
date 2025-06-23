// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract TeamNFT is ERC1155 {
    string public name = "NM Team NFT";
    string public symbol = "TeamNMNFT";

    constructor() ERC1155("") {
        address receiver = 0x6B46E77eC6d70712d1E0C8e180a1f44775AF4b52;
        _mint(receiver, 1, 3000, "");
    }

    function uri(uint256) public pure override returns (string memory) {
        return "ipfs://bafkreifj6so2mcdjaie7eszbgsughez7n75k6jjpsh7c6zi4wfoj66cb7u";
    }
}
