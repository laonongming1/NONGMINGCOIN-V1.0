// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// 农民币团队矿池 - 正式版合约

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
}

interface IERC1155 {
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
}

contract TeamPool {
    IERC20 public immutable nmToken = IERC20(0x7cd04a5132fAa672314aCA0d063c90C0EA3747d4);
    IERC1155 public immutable nftContract = IERC1155(0xBB91925dafA50E91C8aD1416B5c452F9b156EF73);

    uint256 public constant NFT_ID = 1;
    uint256 public constant INITIAL_RATE = 0.01 ether;
    uint256 public constant REDUCE_STEP = 270000 * 1e18;

    struct StakeInfo {
        uint256 stakedAmount;
        uint256 lastClaimTime;
        uint256 totalClaimed;
        bool active;
    }

    mapping(address => StakeInfo) public stakes;
    uint256 public totalClaimed;

    event Staked(address indexed user, uint256 amount);
    event Claimed(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);

    function stake() external {
        require(!stakes[msg.sender].active, "Already staking");

        uint256 amount = nftContract.balanceOf(msg.sender, NFT_ID);
        require(amount > 0, "No NFT");

        nftContract.safeTransferFrom(msg.sender, address(this), NFT_ID, amount, "");

        stakes[msg.sender] = StakeInfo({
            stakedAmount: amount,
            lastClaimTime: block.timestamp,
            totalClaimed: 0,
            active: true
        });

        emit Staked(msg.sender, amount);
    }

    function claim() public {
        StakeInfo storage user = stakes[msg.sender];
        require(user.active, "Not staking");

        uint256 elapsed = block.timestamp - user.lastClaimTime;
        uint256 hoursPassed = elapsed / 3600;
        require(hoursPassed > 0, "Wait for full hour");

        uint256 rate = getCurrentRate();
        uint256 reward = user.stakedAmount * rate * hoursPassed;

        require(nmToken.transfer(msg.sender, reward), "Transfer failed");

        user.lastClaimTime += hoursPassed * 3600;
        user.totalClaimed += reward;
        totalClaimed += reward;

        emit Claimed(msg.sender, reward);
    }

    function unstake() external {
        StakeInfo storage user = stakes[msg.sender];
        require(user.active, "Not staking");

        claim();

        uint256 amount = user.stakedAmount;
        user.active = false;
        user.stakedAmount = 0;

        nftContract.safeTransferFrom(address(this), msg.sender, NFT_ID, amount, "");

        emit Unstaked(msg.sender, amount);
    }

    function getCurrentRate() public view returns (uint256) {
        uint256 cuts = totalClaimed / REDUCE_STEP;
        return INITIAL_RATE >> cuts;
    }

    function getPendingReward(address userAddr) external view returns (uint256) {
        StakeInfo memory user = stakes[userAddr];
        if (!user.active) return 0;

        uint256 elapsed = block.timestamp - user.lastClaimTime;
        uint256 hoursPassed = elapsed / 3600;
        if (hoursPassed == 0) return 0;

        uint256 rate = getCurrentRate();
        return user.stakedAmount * rate * hoursPassed;
    }

    // 必须实现以接收 NFT
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}