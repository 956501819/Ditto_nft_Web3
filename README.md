# Ditto_nft_Web3
This is an NFT project developed based on Solidity（这是一个基于solidity开发的nft项目）

# <div align="center">🪙 MyToken NFT Collection</div>

<p align="center">
  <img src="https://via.placeholder.com/120" width="120" alt="Project Logo" />
</p>

<p align="center">
  <b>A minimal, secure, ERC-721 NFT smart contract built with Solidity & OpenZeppelin.</b>
  <br />
  Fully compatible with OpenSea, Blur, and all major NFT marketplaces.
</p>

<p align="center">
  <a href="#"><img src="https://img.shields.io/badge/Smart%20Contract-ERC721-blue"></a>
  <a href="#"><img src="https://img.shields.io/badge/License-MIT-green"></a>
  <a href="#"><img src="https://img.shields.io/badge/Solidity-^0.8.0-black"></a>
  <a href="#"><img src="https://img.shields.io/badge/OpenZeppelin-Security-blueviolet"></a>
</p>

---

## 🚀 Overview

MyToken 是一个基于 **ERC-721 标准** 的去中心化 NFT 项目，旨在提供：

* 极简、干净的 NFT 合约架构
* 高度兼容性（OpenSea / Blur / LooksRare）
* 安全可靠的 OpenZeppelin 实现
* 可扩展的元数据管理（支持 IPFS）

适合作为：

* NFT 收藏品项目
* Web3 教程与学习示例
* 游戏 / 票券 / 数字资产 模块基础
* 更大型项目的 NFT 组件

---

## ✨ Features

* **🔐 基于 OpenZeppelin 的安全实现**
* **🧩 支持动态 `baseURI` 与 metadata 管理**
* **🛠 易扩展、结构清晰**
* **🛒 支持所有主流 NFT 市场**
* **📦 简单部署，无需额外依赖**

---

## 🧱 Contract Structure

```
MyToken.sol
│
├── constructor(string _baseURI)     # 初始化设置基础 URI
├── _baseURI()                       # 返回基URI
├── mint(address to, uint256 id)     # 铸造 NFT
└── tokenURI(uint256 id)             # 生成 metadata 地址
```

---

## 🛠 Tech Stack

| Component               | Usage    |
| ----------------------- | -------- |
| **Solidity**            | 主合约开发    |
| **OpenZeppelin ERC721** | NFT 标准实现 |
| **Hardhat / Foundry**   | 编译、测试、部署 |
| **IPFS / Filecoin**     | NFT 内容存储 |
| **Ethers.js**           | 与链交互     |

---

## 📦 Installation

```bash
git clone <your-repo-url>
cd MyToken
npm install
```

---

## ⚙️ Compile

```bash
npx hardhat compile
```

---

## 🚀 Deploy (Example)

Hardhat 部署示例：

```javascript
const hre = require("hardhat");

async function main() {
  const MyToken = await hre.ethers.getContractFactory("MyToken");
  const nft = await MyToken.deploy("ipfs://<your-folder-cid>/");

  await nft.waitForDeployment();
  console.log("MyToken deployed to:", await nft.getAddress());
}

main();
```

部署后你会获得：

```
MyToken deployed to: 0x1234...abcd
```

即可在 OpenSea 输入合约地址查看 NFT。

---

## 🗂 Metadata (IPFS)

你的 metadata 文件结构应如下：

```
metadata/
  ├── 1.json
  ├── 2.json
  └── 3.json
```

示例 `1.json`：

```json
{
  "name": "MyToken #1",
  "description": "My first NFT",
  "image": "ipfs://<image-cid>/1.png"
}
```

上传到 Pinata / Web3.storage 后获得 CID，并作为 `baseURI` 传入合约。

---

## 📤 Example NFT Image

<p align="center">
  <img src="https://via.placeholder.com/300x300?text=NFT+Preview" width="260" />
</p>

---

## 🧪 Test

```bash
npx hardhat test
```

---

## 📜 License

This project is licensed under the **MIT License**.

---

## 🤝 Contribute

欢迎提出 PR / Issue，一起让合约更强大！

---

## ⭐ Support

如果你觉得项目不错，欢迎给个 **Star ⭐**！

---

如果你想，我可以继续为你定制：

🔹 **带 Logo 的品牌版 README**
🔹 **英文 / 中英双语 README**
🔹 **加入白名单 mint / 上链流程 / FAQ 的高级版 README**
🔹 **更像顶级 NFT 项目的版式（如 Azuki、BAYC 风格）**


需要我升级哪个版本？

