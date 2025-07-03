// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title 公共信息馆
/// @notice 任何人都能创建归档，分块写入，每块内容写入后不可更改，永久保存，去中心化
contract PublicImmutableArchiveHall {
    struct Archive {
        uint256 totalChunks;      // 总分块数
        bytes32 fileHash;         // 全文件的压缩哈希（前端负责压缩、hash）
        address uploader;         // 创建者
        bool exists;
    }

    // 归档ID => 归档元数据
    mapping(uint256 => Archive) public archives;
    // 归档ID => 分块序号 => 分块内容
    mapping(uint256 => mapping(uint256 => bytes)) public chunks;
    uint256 public nextId;

    event ArchiveCreated(uint256 indexed id, address indexed creator, uint256 totalChunks, bytes32 fileHash);
    event ChunkUploaded(uint256 indexed id, uint256 index);

    /// @notice 创建归档，返回编号
    function createArchive(uint256 totalChunks, bytes32 fileHash) external returns (uint256 id) {
        require(totalChunks > 0, "Chunk count must be > 0");
        id = nextId++;
        archives[id] = Archive({
            totalChunks: totalChunks,
            fileHash: fileHash,
            uploader: msg.sender,
            exists: true
        });
        emit ArchiveCreated(id, msg.sender, totalChunks, fileHash);
    }

    /// @notice 上传分块（写入后不可更改）
    function uploadChunk(uint256 id, uint256 index, bytes calldata data) external {
        require(archives[id].exists, "Archive does not exist");
        require(index < archives[id].totalChunks, "Index out of range");
        require(chunks[id][index].length == 0, "Chunk already written");
        chunks[id][index] = data;
        emit ChunkUploaded(id, index);
    }

    /// @notice 查询分块内容
    function getChunk(uint256 id, uint256 index) external view returns (bytes memory) {
        return chunks[id][index];
    }

    /// @notice 查询归档元信息
    function getArchiveInfo(uint256 id) external view returns (uint256, bytes32, address, uint256) {
        Archive memory a = archives[id];
        require(a.exists, "Archive does not exist");
        return (a.totalChunks, a.fileHash, a.uploader, id);
    }

    /// @notice 查询归档总数（归档编号范围：0 ~ archiveCount-1）
    function archiveCount() external view returns (uint256) {
        return nextId;
    }
}
