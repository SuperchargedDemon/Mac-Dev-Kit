# mac-dev-kit · 真正能跑 Mac 开发的工程

这个目录里的东西分两层：

- **能立刻验证的**：一套真实的 Swift 6.1.2 工具链（Linux），同一个编译器、SwiftPM、Foundation，构建与测试都真的跑过；
- **真正在 Apple 硬件上编译的**：一份 GitHub Actions 工作流，跑在 `macos-14`（Apple Silicon）上，用 `xcodebuild` 产出 iOS 模拟器包和 macOS `.app`。

没有 macOS 虚拟机，也不需要：这条路用的是 GitHub 自己的 Mac 机器，合法、免费额度内零成本。

---

## 三条路的真实程度

| 方式 | 真实度 | 能做什么 | 代价 |
|---|---|---|---|
| **GitHub Actions `macos-14`** | 真 Apple 硬件，真 Xcode | 编译、测试、产出 `.app` / 模拟器包、跑 `xcodebuild` | 公开仓库免费；私有仓库每月 2000 分钟（macOS 按 10 倍计） |
| **租云 Mac**（MacinCloud / MacStadium / AWS EC2 Mac） | 真 Mac 桌面 | 完整 Xcode、模拟器、真机调试、交互式开发 | 约 $25–449/月，或 $0.65/小时起 |
| **Linux + Swift 6**（本目录已装好） | 同一编译器，非 Apple SDK | Swift 包、命令行工具、服务端 Swift、单元测试 | 免费；不能 `import UIKit / SwiftUI / AppKit` |

想要“点开就是 Mac 桌面”，只有第二条。想要“代码真的被 Apple 工具链编译”，第一条就够，而且不用花钱。

---

## 目录

```
mac-dev-kit/
├─ swift/                     # 跨平台 Swift 包：macdev 环境自检 CLI
│  ├─ Sources/MacDevKit/      # 检查逻辑（Swift / Xcode / SDK / 模拟器 / brew）
│  └─ Tests/                  # 7 个单元测试
├─ ios/
│  ├─ project.yml             # XcodeGen 配置，生成 iOS + macOS 两个 target
│  └─ Sources/                # SwiftUI 界面，两端共用
├─ .github/workflows/macos.yml# 真机 macOS 构建流水线
├─ scripts/
│  ├─ bootstrap-swift-linux.sh
│  └─ mac-bootstrap.sh        # 在真 Mac 上一键跑起来
└─ Makefile
```

---

## 五分钟上手（不需要 Mac）

```bash
cd mac-dev-kit
git init && git add . && git commit -m "init mac dev kit"

# 有 gh 的话：
gh repo create mac-dev-kit --public --source=. --push

# 没有的话：在 GitHub 建个空仓库，然后
git remote add origin git@github.com:<你的账号>/mac-dev-kit.git
git push -u origin main
```

推送后打开仓库的 **Actions → macos-build**，等 2–4 分钟，在 run 页面底部下载 `aurora-macos-build`：

- `macdev` — 在 Mac 上可直接运行的二进制
- `AuroraMac.zip` — 真正的 macOS `.app`
- `AuroraDemo-ios-sim.zip` — iOS 模拟器包

日志开头会打印 `sw_vers`、`xcodebuild -version`、`uname -m`，这就是真机器的证据。

## 在本沙盒里已经跑通的

```console
$ swift --version
Swift version 6.1.2 (swift-6.1.2-RELEASE)
Target: x86_64-unknown-linux-gnu

$ cd swift && swift test
Executed 7 tests, with 0 failures

$ swift run macdev doctor
macdev doctor · Linux x86_64

  ✓ Swift                  6.1.2 (swift-6.1.2-RELEASE)
  ✓ Git                    git version 2.43.0
  ○ Xcode                  仅 macOS 可用，当前是 Linux
      → 真机编译走 GitHub Actions 的 macos-14 runner，见 README
  ○ iOS SDK                Linux 上的 Swift 没有 Apple SDK
      → 可以编译 Swift 包与命令行工具，不能链接 UIKit / SwiftUI
  ○ Simulators             需要 Xcode 与 CoreSimulator
  ○ Homebrew               brew on Linux 只能装 CLI 工具
  ✓ Node                   v22.13.1
  ✓ Machine                x86_64 · 32 核 · 123.3 GB 内存

4 通过 · 0 警告 · 4 跳过 · 0 失败
```

## 在一台真 Mac 上

```bash
brew install xcodegen          # 只需一次
./scripts/mac-bootstrap.sh     # 构建 + 测试 + 生成工程
open ios/AuroraDemo.xcodeproj  # 直接开 Xcode
```

或者只想要产物：

```bash
make mac-app     # -> build/Build/Products/Debug/AuroraMac.app
make ios-app     # 模拟器包
```

---

## 为什么这里不能直接跑 macOS

- 沙盒是 Linux 容器，`/dev/kvm` 不存在，CPU 也没暴露 `vmx/svm` —— 连嵌套虚拟化都没有；
- 即使有，Apple 的许可只允许 macOS 跑在 Apple 硬件上，非苹果硬件上的“黑苹果”不放行；
- QEMU 纯软件模拟理论上能启动，但启动要按小时计，且同样违反许可，不做。

所以“近似”的部分做成两件正经事：**同一套 Swift 工具链** + **真实 Apple 硬件的构建流水线**。

## 计费与限制（2026 年 11 月）

- GitHub Actions 公开仓库：macOS runner 免费，无分钟上限；私有仓库 2000 分钟/月，macOS 消耗系数 10，约合 200 分钟实机时间。
- 产物未签名、未公证：iOS 包只能装模拟器；macOS `.app` 首次打开需右键 → 打开。要真机安装得配 `DEVELOPMENT_TEAM` 与证书。
- 需要交互式 Xcode 调试、真机联调时，还是得云 Mac 或本地 Mac；方案对比见上一份 `macos-环境方案对比与开通手册.html`。
