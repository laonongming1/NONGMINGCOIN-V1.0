// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

contract NFTSale is IERC1155Receiver {
    address public constant NFT_CONTRACT = 0x1f09E222fb8F81c6D41415822a63C9C4Ef448dcF;
    address public constant USDC_CONTRACT = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; 
    address public constant RECEIVER = 0x6B46E77eC6d70712d1E0C8e180a1f44775AF4b52;

    uint256 public constant TOKEN_ID = 1;
    uint256 public constant PRICE = 5 * 10**6; // USDC 是 6 位精度

    function buy() external {
        // 1. 用户将 5 USDC 授权给合约
        require(
            IERC20(USDC_CONTRACT).transferFrom(msg.sender, RECEIVER, PRICE),
            "USDC transfer failed"
        );

        // 2. 检查合约是否拥有 NFT
        uint256 balance = IERC1155(NFT_CONTRACT).balanceOf(address(this), TOKEN_ID);
        require(balance > 0, "NFT sold out");

        // 3. 转出 1 个 NFT 给用户
        IERC1155(NFT_CONTRACT).safeTransferFrom(
            address(this),
            msg.sender,
            TOKEN_ID,
            1,
            ""
        );
    }

    // 实现接收 ERC-1155 NFT 所需接口
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    function supportsInterface(bytes4 interfaceId) public pure override returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId;
    }
}
