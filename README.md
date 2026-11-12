# DSH Purge Desktop（社区整合版）

面向 Apple Silicon Mac 的 DeepSeek Harness 社区整合包，预装 Purge Community 和联网搜索插件。下载应用后，用自己的模型账号或 API Key 配置即可开始使用。本项目与 DeepSeek、Purge 项目和 WorkBuddy 均无官方关联。

> **安全提示**：Purge 会修改提示词与本地工具权限。此版本可能以“完全权限”模式执行本地命令或读写文件；使用前请确认你信任项目、插件及工作目录，审阅首次启动提示，并只在有授权的环境中操作。模型提供商的限制仍然可能生效，不能保证所有请求都会成功。

## 下载和第一次使用

1. 打开 [Releases](https://github.com/FelixDemon1/dsh-purge-desktop/releases)，下载 `DSH-Purge-Desktop-mac-arm64.zip` 和 `SHA256SUMS.txt`。这是 Apple 芯片（M 系列）的版本，不适用于 Intel Mac 或 Windows。
2. 双击 ZIP 解压，将 `DeepSeek Harness.app` 拖到「应用程序」。如果已经安装官方同名应用，请先重命名其中一个，避免覆盖。此整合版的数据位于 `~/.dsh-purge-desktop`，与官方默认的 `~/.dsh` 分开。
3. 首次打开后选择「添加 API Key」，输入自己的 DeepSeek API Key；也可先选择「稍后配置」。进入后阅读 Purge 的首次使用须知，由使用者自行决定是否接受。
4. 选择一个可用模型，新建会话并发送问题。接入其他兼容服务时，在 DSH 的模型设置中填写该服务提供的地址、模型名和密钥。
5. 需要联网时可询问「请联网搜索……并给出来源」。是否真正触发工具取决于模型的工具调用能力、插件、搜索服务和网络；请检查工具调用记录和引用，不要仅凭模型声称搜索过就认定它已经联网。

此构建使用临时自签名，**没有 Apple 开发者公证**，macOS 可能阻止或提示风险；应先核实来源、校验下载文件并自行决定是否运行。在终端切换到下载文件所在目录后执行 `shasum -a 256 -c SHA256SUMS.txt` 可核对文件完整性；该校验本身不能证明发布者身份。

## 包含什么

| 组件 | 版本 | 用途 |
| --- | --- | --- |
| [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) 桌面版 | 0.2.1-rc.2 | 主程序 |
| [Purge Community](https://github.com/kingcharleslzy-ai/dsh-purge) | 1.6.88 | 提示词和补丁、相关预设 |
| [dsh-web-search](https://github.com/fangchenghao/dsh-web-search) | 0.24.0 | 搜索插件，默认配置为 Bing |

整合包不包含任何人的 API Key、登录状态、对话、WorkBuddy 账号或个人数据；不能继承打包者的模型额度。Purge、模型和搜索服务各自的版本与行为可能变化。本构建关闭了 DSH 原有的自动更新入口，避免官方更新覆盖补丁；需要更新时请等待整合包的新版本。

## WorkBuddy Manager 与逆向工具

- 需要 WorkBuddy 模型时，必须自行部署 [WorkBuddy Manager](https://github.com/ithtelab/workbuddy-manager)，使用自己的账号授权，并按其文档把它提供的 API 地址、模型名及密钥填入 DSH；仅有普通 DeepSeek API Key 不能替代 WorkBuddy 账号。Manager 本身不在此应用包中。
- 本版**没有预装** [REA](https://github.com/morluto/rea)、Ghidra 或 [Reverse Skill](https://github.com/zhaoxuya520/reverse-skill)。Purge 自带的预设不等于已完成 REA 接入。需要逆向时请先阅读各项目文档、安装依赖并自行配置；它们的可用性和平台支持需要单独验证。

## 常见问题

- **没有模型 / 认证失败**：检查自己的 API Key、余额或额度、服务地址和模型名称；不要把密钥贴到 Issue 或截图中。
- **搜索不到或没有联网**：先确认联网搜索插件启用、网络可以连接搜索服务，再确认所选模型及网关支持工具调用。更换模型不一定能修复搜索服务故障。
- **打开时提示无法验证开发者**：这是重新打包且未公证的版本；请先检查项目源码、下载来源和校验值，再自行决定是否信任。
- **想清除本版本数据**：先备份需要的会话与配置，然后自行删除 `~/.dsh-purge-desktop`。这会删除本版本保存的密钥和聊天记录。

## 从源码构建

在 Apple Silicon Mac 上安装 Node.js 和 npm 后，在本仓库目录运行：

```bash
./scripts/build.sh
```

脚本下载指定版本的官方 DSH 和 Purge，检查下载哈希及原始 DSH 签名，安装固定版本的搜索插件，应用补丁并在 `dist/` 生成 ZIP 和校验文件。构建后的应用经过修改，签名不是 DeepSeek 官方签名。构建过程需要联网，依赖上游下载地址和 npm 可用。

## 许可与来源

构建脚本见本仓库 [LICENSE](LICENSE)。第三方组件保留各自许可、版权和声明；参见 [licenses](licenses/) 和各上游仓库。Purge 的使用须知由其上游插件提供。
