// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0 (注意：你原代码中是 ^5.4.0，但 ^5.0.0 是更通用的兼容版本；如果需要特定版本，可调整)
pragma solidity ^0.8.20;  // 更新到更稳定的版本，避免潜在兼容问题

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";  // 导入 ERC721 标准，用于 NFT 核心功能
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";  // 导入 Ownable，用于所有者访问控制
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";  // 新增：导入 Pausable，用于合约暂停功能，提高安全性（路径更新为 utils/）
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";  // 新增：导入 ReentrancyGuard，防止重入攻击，尤其在 payable 函数中（路径更新为 utils/）
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";  // 新增：导入 Strings 库，用于 uint256 到 string 转换，替换自定义 _toString



/**
 * @title DittoNft
 * @dev 这是一个基于 ERC721 标准的 NFT 合约，支持白名单 mint、供应量限制和元数据存储。
 *      总供应量固定为 100 张 NFT，使用 IPFS/Filecoin 存储元数据。
 *      合约继承 Ownable（所有者控制）、Pausable（可暂停）和 ReentrancyGuard（防重入）。
 *      白名单用户可以自行 mint（免费或付费），owner 可以批量管理。
 */
contract DittoNft is ERC721, Ownable, Pausable, ReentrancyGuard {
    uint256 private _tokenIdCounter = 1;  // 私有计数器，从 1 开始递增，用于自动生成 token ID
    uint256 public constant MAX_SUPPLY = 10;  // 常量：最大供应量，不可更改

    // 白名单映射：地址 => 是否允许 mint
    mapping(address => bool) public whitelist;

    string private _baseURI2;  // 私有变量：存储元数据 base URI（IPFS 链接）

    uint256 public mintPrice = 0;  // 新增：mint 价格，默认 0（免费），单位 wei；owner 可调整为付费 mint

    // 事件：记录 mint 操作，便于链下追踪
    event Minted(address indexed to, uint256 indexed tokenId);
    // 事件：白名单更新
    event WhitelistUpdated(address indexed user, bool allowed);

    /**
     * @dev 构造函数：初始化 NFT 名称、符号、初始 owner 和 base URI。
     * @param initialOwner 初始所有者地址，通常为部署者。
     */
    constructor(address initialOwner)
        ERC721("Ditto", "Dit")  // 设置 NFT 集合名称和符号
        Ownable(initialOwner)  // 设置初始 owner
    {
        _baseURI2 = "https://indigo-implicit-tortoise-200.mypinata.cloud/ipfs/bafybeig3h4kq3afgeoil4ojrvzlz2up7nse6xhzkyrnysoyaio6md2fjyq/metadata/";  // 初始化 base URI（指向 IPFS/Filecoin 元数据文件夹）
    }

    /**
     * @dev 重写 _baseURI2 函数，返回元数据根目录链接。
     *      用于生成每个 token 的完整 URI（如 baseURI + tokenId + ".json"）。
     * @return string 元数据 base URI。
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURI2;
    }

    /**
     * @dev Owner 可以更新 base URI（例如，如果 IPFS CID 变化）。
     * @param newBaseURI 新的 base URI 字符串。
     */
    function setBaseURI(string memory newBaseURI) public onlyOwner {
        _baseURI2 = newBaseURI;
    }

    /**
     * @dev 设置单个用户的白名单状态。
     *      仅 owner 可调用。
     * @param user 用户地址。
     * @param allowed 是否允许（true/false）。
     */
    function setWhitelist(address user, bool allowed) external onlyOwner {
        whitelist[user] = allowed;
        emit WhitelistUpdated(user, allowed);  // 发射事件记录更新
    }

    /**
     * @dev 批量添加白名单用户。
     *      仅 owner 可调用，提高效率。
     * @param users 地址数组。
     */
    function batchAddWhitelist(address[] calldata users) external onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            whitelist[users[i]] = true;
            emit WhitelistUpdated(users[i], true);  // 发射事件
        }
    }

    /**
     * @dev Owner 可以设置 mint 价格（单位 wei）。
     * @param newPrice 新价格。
     */
    function setMintPrice(uint256 newPrice) external onlyOwner {
        mintPrice = newPrice;
    }

    /**
     * @dev 公共 mint 函数：白名单用户可调用，需支付价格（如果 >0）。
     *      检查暂停状态、白名单、供应量和支付金额。
     *      使用 nonReentrant 防重入。
     */
    function mint() public payable nonReentrant whenNotPaused {
        require(whitelist[msg.sender], "Not whitelisted");  // 检查白名单
        require(_tokenIdCounter <= MAX_SUPPLY, "Max supply reached");  // 检查供应量
        require(msg.value >= mintPrice, "Insufficient payment");  // 检查支付（如果免费，msg.value 可为 0）

        uint256 tokenId = _tokenIdCounter;  // 获取当前 ID
        _tokenIdCounter++;  // 递增计数器
        _safeMint(msg.sender, tokenId);  // 安全 mint 到调用者
        emit Minted(msg.sender, tokenId);  // 发射事件

        // 如果有支付，剩余 ETH 退回（使用 call 更安全）
        if (msg.value > mintPrice) {
            (bool success, ) = payable(msg.sender).call{value: msg.value - mintPrice}("");
            require(success, "Refund failed");
        }
    }

    /**
     * @dev Owner 专用的批量 mint 函数：可 mint 到指定地址。
     *      用于初始发行或空投。
     * @param recipients 接收者地址数组。
     */
    function batchMint(address[] calldata recipients) external onlyOwner {
        uint256 length = recipients.length;
        require(_tokenIdCounter + length - 1 <= MAX_SUPPLY, "Max supply reached");  // 检查总供应

        for (uint256 i = 0; i < length; i++) {
            uint256 tokenId = _tokenIdCounter;
            _tokenIdCounter++;
            _safeMint(recipients[i], tokenId);
            emit Minted(recipients[i], tokenId);
        }
    }

    /**
     * @dev 查询当前总供应量（已 mint 的 NFT 数量）。
     * @return uint256 已 mint 数量。
     */
    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter - 1;  // 因为计数器从 1 开始，减 1 得到实际数量
    }

    /**
     * @dev 重写 tokenURI：返回完整元数据 URI。
     * @param tokenId NFT 的 token ID。
     * @return string 完整 URI（如 baseURI + tokenId + ".json"）。
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        // _requireMinted(tokenId);  
        // require(_exists(tokenId), "ERC721: invalid token ID"); 
        require(ownerOf(tokenId) != address(0), "ERC721: invalid token ID");
        // require(_exists(tokenId), "ERC721: invalid token ID");// 检查 token 是否存在
        string memory base = _baseURI();
        string memory tokenIdStr = (tokenId < 10)
        ? string.concat("0", Strings.toString(tokenId))
        : Strings.toString(tokenId);
        return string(abi.encodePacked(base, tokenIdStr, ".json"));  // 拼接 URI，使用 Strings.toString
    }

    /**
     * @dev 暂停合约：停止 mint 和转移（继承 Pausable）。
     *      仅 owner 可调用。
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev 恢复合约。
     *      仅 owner 可调用。
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev Owner 提取合约余额（如果有 mint 付费）。
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");
        (bool success, ) = payable(owner()).call{value: balance}("");  // 使用 call 代替 transfer，更安全
        require(success, "Withdrawal failed");
    }

    // 重写：确保暂停时转移也受限（可选，根据需求）
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
    {
        _beforeTokenTransfer(from, to, tokenId);
    }
}