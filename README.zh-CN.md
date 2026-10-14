# agent-chrome-split · Agent 独立浏览器，人机分屏

**给每个 AI Agent 一个独立的 Chrome，人和 Agent 在同一台电脑上各干各的。**

[English](README.md) · [给 AI Agent 的安装说明](AGENTS.md)

![cover](assets/cover.zh-CN.png)

让 AI Agent 接管电脑，最头疼的是它和你抢同一块屏幕：你一动鼠标它就点错，它一刷新你的页面就没了。

一个零成本的分法：你在电脑上照常写东西、开会，Agent 在另一个独立的浏览器里查资料、整理数据、跑网页任务，各干各的，互不干扰。

懒得自己配？直接把这个仓库丢给你的 AI Agent，让它照着 [AGENTS.md](AGENTS.md) 一步步装好。

## 1️⃣ 给 Agent 一个独立的 Chrome

单独的配置文件夹和端口，跟你自己的浏览器完全分开。Mac 终端运行：

```bash
open -na "Google Chrome" --args --user-data-dir=$HOME/AgentChrome --remote-debugging-port=9333
```

（首次使用脚本前先执行 `chmod +x scripts/*.sh`，或用 `bash scripts/...` 运行。）

把这一行存成桌面上的 .command 文件，以后双击就能启动（`scripts/make-launcher.sh` 可自动生成）。也可以用 `scripts/launch-agent-chrome.sh`，顺带设好下载目录和彩色标签页。

## 2️⃣ 手动登录一次

在这个 Chrome 里手动登录一次它需要用的网站，登录状态会一直保留。

## 3️⃣ 通过调试端口下指令

Agent 通过调试端口（Chrome 自带的 DevTools 协议）直接给浏览器发指令，不占用你的鼠标键盘，也不用抢前台窗口。你用你的，它跑它的。

## 4️⃣ 多个 Agent 就各开一个

每个 Agent 一个 Chrome、一个端口（9333、9335…），再各放一个彩色标签页写上名字，一眼就能分清谁是谁（`scripts/label-tab.sh`，示例见 `examples/`）。

## 5️⃣ 人只在关键节点出手

Agent 把活干到最后一步就停下来，把结果摆在它那个窗口里等你。你看一眼、拍板，再继续。机器负责跑，人负责判断。

## 下载：每个 Agent 一个下载文件夹

各自的文件不混在一起，也不会弹「另存为」对话框：

- 启动脚本会在 Chrome 未运行时写入 `download.default_directory`、`prompt_for_download: false`、`directory_upgrade: true`；
- 已在运行的实例：`python3 scripts/set-download-dir.py 9333 ~/Downloads/agent-a`（CDP `Browser.setDownloadBehavior`）；
- 也可以在那个 Chrome 的「设置 → 下载内容」里手动改。

## 云端 Agent 怎么办？

跑在你自己电脑上的 Agent，直接连 127.0.0.1:端口 就行。云端 Agent 连不上，因为 Chrome 的调试端口默认只监听本机。这是安全设计：谁能连上这个端口，谁就能操控里面已登录的账号。

所以别把端口暴露出去，更不要绑定到 0.0.0.0 或公网。云端 Agent 可以走私有网络里的 SSH 隧道，比如 Tailscale 加 macOS 的「远程登录」（详见 [docs/ssh-tunnel.md](docs/ssh-tunnel.md)）：

```bash
ssh -N -L 9335:127.0.0.1:9335 你的用户名@你的Mac
```

实在不方便，就退回老办法：让它的窗口切到前台操作。

## 安全须知

- 调试端口 = 已登录账号的完全控制权，像密码一样对待；
- 永远不要绑定 0.0.0.0 或暴露到公网；
- 永远不要把配置文件夹、cookies、Preferences、下载内容提交到仓库；
- Agent 只碰自己的端口，别碰你日常用的浏览器；
- 任何有后果的操作（发送、发布、购买、删除）都由人来批准；
- 电脑设成不自动睡眠（出屏保没关系）。

## 相关与致谢

思路受社区讨论启发，相关讨论：<https://x.com/turingou/status/2109854210917593557>

原文：<https://x.com/ImmunoSparkle/status/2110193604908003442>

*个人实践分享，仅供参考。* MIT © Lumina Research
