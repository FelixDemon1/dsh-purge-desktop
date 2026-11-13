# DSH Purge Desktop（社区整合版）

这是面向 **Apple 芯片（M 系列）、macOS 13.5 或更新版本**的 DeepSeek Harness 社区整合包，预装 Purge、联网搜索、WorkBuddy Manager、REA、Ghidra、Reverse Skill 和 Craft Anything。软件及配置来自各自的上游项目，本项目与它们无官方关联。Windows 和 Intel Mac 不适用。

整合包不含发布者的 API Key、WorkBuddy 登录信息、聊天记录或个人文件。每位使用者需要自己的模型服务账号及密钥；使用 WorkBuddy 还需要安装并启动 Docker Desktop，并亲自扫码授权。

> Purge 会调整提示词和工具权限。完全权限模式下，程序可能读取或修改本地文件、执行命令。请先阅读插件首次启动时的说明，只在自己有权操作的目录、软件和网络中使用。模型服务商的限制仍可能生效，不能保证每项请求都成功。

## 一、下载和打开

1. 在 [Releases](https://github.com/FelixDemon1/dsh-purge-desktop/releases) 找完整包版本，下载 `DSH-Purge-Desktop-Full-mac-arm64.zip` 和 `SHA256SUMS-FULL.txt`。文件较大，确保磁盘有充足空间。
2. 可在「终端」进入下载目录，执行 `shasum -a 256 -c SHA256SUMS-FULL.txt` 验证 ZIP 是否与校验文件一致。校验不能单独证明发布者身份。
3. 双击 ZIP 解压，保留文件夹内的应用和 `Start WorkBuddy Manager.command`；可以把**整个文件夹**移到方便的位置。打开 `DSH Purge Desktop.app`。它不会覆盖你已有的官方 DSH。
4. 应用经过重新打包和临时签名，**没有 Apple 开发者公证**，macOS 可能提示无法验证开发者；请先核对下载来源和源码，再自行决定是否在系统设置中允许运行。
5. 第一次打开时可填自己的 DeepSeek API Key，也可选「稍后配置」。进入应用后阅读 Purge 的用户须知，自行决定是否接受。
6. 选择可用模型、新建会话并输入问题。只有自己的 API Key 及对应额度才能调用模型。

本整合版数据默认保存在 `~/.dsh-purge-desktop-full`，与官方默认的 `~/.dsh` 分离；其中可能含个人密钥和会话，不应上传或分享。重新打包后的应用不会自动跟随官方更新；更新时请使用本项目的新版本并先备份数据。

## 二、使用 WorkBuddy Manager 模型

WorkBuddy Manager 是管理账号和提供模型接口的服务，DSH 是聊天客户端；它们需要同时运行。整合包自带 Manager 所需的两个镜像，但 Docker Desktop 本身需要另行安装。

1. 从 [Docker 官网](https://www.docker.com/products/docker-desktop/)安装适用于 Apple 芯片的 Docker Desktop，启动并等待 Docker 显示运行中。根据 Docker 的条款使用它。
2. 至少打开一次本整合版 DSH，完成数据初始化。然后双击解压文件夹中的 `Start WorkBuddy Manager.command`。首次运行会导入随包镜像，可能要等待数分钟。窗口提示成功后，浏览器打开 `http://127.0.0.1:18864`。
3. 管理员用户名是 `admin`；首次启动会生成随机密码，保存在 `~/.dsh-purge-desktop-full/manager/admin-password.txt`。在 Finder 按 `Command+Shift+G`，粘贴该路径并打开文件查看。**不要分享该密码或文件。**
4. 登录管理页面，在「账号」添加自己的**国内版 CodeBuddy**账号，按提示扫码并授权；在「密钥」新建网关密钥，创建时保存显示的明文。国内/国际两个账号体系不是同一账号；整合包默认禁用上游国际版，Manager 上游界面可能仍显示相关选项。
5. 回到 DSH，点左下角账号菜单进入「设置 → 模型」，点「添加模型提供商 → 自定义模型 API」。Provider ID 填 `workbuddy`，显示名称可填 `WorkBuddy`，API 协议选 **OpenAI Responses**，API 地址填 `http://127.0.0.1:18864/v1`，API 密钥填刚创建的 Manager 网关密钥。点「获取可用模型」选择模型；也可点「添加模型」，模型 ID 填 Manager「设置 → 可用模型」中实际显示的名称，最后点「创建提供商」。不要把管理员密码或 DeepSeek 密钥填进这里。
6. 回到 DSH 选择新配置的模型，先发送「你好」测试。使用期间 Docker Desktop 和 Manager 必须运行。若重启 Mac，先启动 Docker Desktop，再运行一次启动脚本；已有账号和 Manager 数据保存在本机 Docker 卷中。

如果打不开管理页面，检查 Docker Desktop、启动脚本的报错和 18864 端口占用。若登录成功但模型不可用，先在 Manager 检查账号状态、积分、模型名及密钥限制。Manager 和上游的功能及 [使用文档](https://github.com/ithtelab/workbuddy-manager/blob/main/docs/usage.md) 可能随版本变化。登录后才能验证实际模型调用，本项目不能代替你的账号完成扫码。

## 三、联网搜索

在对话中明确说：**「请联网搜索这个问题，给出来源链接和日期。」** 搜索插件提供工具，模型须支持并实际发起工具调用，网关也须正确转发工具调用；搜索服务本身还依赖网络。查看 DSH 的工具调用记录和来源链接，不能只凭回答里写了「我搜索过」判断是否联网。

DSH 官方模型与 Manager 代理模型都可以使用同一个客户端搜索工具，但是否实际成功还取决于模型与代理协议。搜索失败时，先用另一个支持工具调用的模型比较，再检查插件是否启用、网络是否能访问搜索服务、Manager 返回的错误及模型名称。联网搜索不会自动继承 WorkBuddy 网页端自己的搜索功能。

## 四、逆向与 Craft

- **标准模式**适合日常聊天；**无限制模式**含 Purge 和 REA 接入。
- **红队模式**提供 Purge 的演练台；包内配置了 Nmap、Nuclei、Masscan、Fscan、Gogo、Suo5、FRP、Chisel、FFUF、httpx、dnsx、Subfinder、KSubdomain、Impacket 和 Nuclei 模板。先在演练台中明确填写你有权测试的目标，部分网络操作可能需要系统权限或自行提供 FOFA 等服务的凭据；这些凭据不会随包提供。
- 新建会话的模式菜单中选择 **逆向模式（REA + Reverse Skill）**，让模型对已获授权的本地程序使用 REA；REA 调用包内的 Ghidra 做分析，Reverse Skill 提供分场景的方法。技能库作为可选模式提供，普通聊天不需要加载全部逆向技能；具体上下文和 token 用量取决于模型、客户端如何加载技能及 MCP 工具描述。REA 工具较多，选用时会产生额外上下文开销。
- 可以在 DSH 里打开一个单独的工作目录，把自己有权分析的测试程序放进去，选择逆向模式，然后提出例如「分析这个我有权研究的程序的入口和主要函数，解释依据，并生成报告」的请求。先确认文件路径和授权范围，检查工具调用及输出。
- **无限制模式 + Craft Anything** 是另一独立模式，适合对有权研究的软件做功能研究和重建。普通聊天无需选择它。
- 包内 Ghidra 已包含 Apple 芯片反编译器与 Java。REA 还支持其他可选分析器，但 IDA、Hopper、JADX 等不在本包中，也没有配置；REA 的全范围 `doctor` 可能因此报告其他可选项缺失，这不等于 Ghidra 不可用。

## 五、问题排查与数据

- **模型没回复或认证失败**：检查服务地址、协议、模型名、各自的密钥和额度。WorkBuddy 网关密钥、Manager 管理员密码、DeepSeek API Key 是不同的东西。
- **找不到逆向模式或工具报错**：完全退出并重新打开整合版，确认使用的是本应用而非官方 DSH；检查工作区和所选模式。请在提交 Issue 前移除密钥、路径和敏感文件名。
- **提示无法打开应用或脚本**：检查下载是否完整及 macOS 安全设置。本包未公证，不建议关闭系统的全局安全保护。
- **备份或移除**：先自行备份需要的 `~/.dsh-purge-desktop-full` 及 WorkBuddy 的 Docker 卷；删除它们会丢失相应密钥、聊天及账号数据。不要把这些目录打包上传。

## 包含的版本与来源

| 组件 | 版本或固定提交 | 作用 |
| --- | --- | --- |
| [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) | 0.2.1-rc.2 | 桌面应用 |
| [Purge Community](https://github.com/kingcharleslzy-ai/dsh-purge) | 1.6.88 | 补丁和预设 |
| [dsh-web-search](https://github.com/fangchenghao/dsh-web-search) | 0.24.0 | 联网搜索 |
| [WorkBuddy Manager](https://github.com/ithtelab/workbuddy-manager) | 2.11.9 | 本地管理和网关；含其上游镜像 |
| [REA](https://github.com/morluto/rea) | 6.8.0，`317bf3f` | 逆向分析工具接入 |
| [Ghidra](https://github.com/NationalSecurityAgency/ghidra) | 12.1.4 | 反编译分析 |
| [Reverse Skill](https://github.com/zhaoxuya520/reverse-skill) | `cab634b` | 逆向方法技能 |
| [Craft Anything](https://github.com/storytold/craft-anything) | 0.6.1 | 软件功能研究工具 |

还包含 Node.js 24.22.2 和 Temurin JDK 21.0.13。第三方软件保留各自许可及声明，参见包内文件、[licenses](licenses/) 和上游项目。

## 从源码构建

需要 Apple 芯片 Mac、Node.js/npm（22.23.4+、24.22.1+ 或 26.12.1+，以 REA 的版本要求为准）、Xcode 命令行工具、运行中的 Docker Desktop、网络和足够磁盘空间。在仓库根目录执行：

```bash
bash scripts/build.sh
```

脚本下载并校验固定版本的官方组件，构建 REA 与 Ghidra Apple 芯片反编译器，封装 Docker 镜像并生成 `dist/DSH-Purge-Desktop-Full-mac-arm64.zip` 和校验文件。构建过程需要网络及上游资源；重新打包后的应用不是 DeepSeek 的官方签名。脚本与本仓库代码的许可见 [LICENSE](LICENSE)。
