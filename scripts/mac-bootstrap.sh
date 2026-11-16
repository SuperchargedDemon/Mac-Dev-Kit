#!/usr/bin/env bash
# 在一台真实的 Mac 上把工程跑起来。
set -euo pipefail
cd "$(dirname "$0")/.."

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "缺少 $1：$2" >&2
    exit 1
  }
}

need xcodebuild "先安装 Xcode（App Store），并执行 sudo xcode-select -s /Applications/Xcode.app"
need brew "先安装 Homebrew：https://brew.sh"

if ! brew list xcodegen >/dev/null 2>&1; then
  echo "==> 安装 XcodeGen"
  brew install xcodegen
fi

echo "==> Swift 包：构建 + 测试"
(cd swift && swift build -c release && swift test && .build/release/macdev doctor)

echo "==> 生成 Xcode 工程"
(cd ios && xcodegen generate)

echo ""
echo "完成。打开工程："
echo "  open ios/AuroraDemo.xcodeproj"
echo "或者命令行构建："
echo "  cd ios && xcodebuild -scheme AuroraMac -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO build"
