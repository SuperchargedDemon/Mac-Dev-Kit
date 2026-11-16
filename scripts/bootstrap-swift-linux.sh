#!/usr/bin/env bash
# 在 Ubuntu / Debian 上装一套真实的 Swift 工具链。
# 同一套编译器、SwiftPM、Foundation 与 macOS 上一致；
# 差异只在 Apple SDK（UIKit / SwiftUI / AppKit）不可用。
set -euo pipefail

SWIFT_VERSION="${SWIFT_VERSION:-6.1.2}"
CODENAME="${CODENAME:-ubuntu2404}"
ARCH="$(uname -m)"

if [[ "$ARCH" != "x86_64" ]]; then
  echo "这个脚本只处理 x86_64；arm64 请把 ubuntu2404 换成 ubuntu2404-aarch64 并调整包名。" >&2
  exit 1
fi

if ! command -v swift >/dev/null 2>&1; then
  echo "==> 安装运行时依赖"
  sudo apt-get update -qq
  sudo apt-get install -y -qq \
    libcurl4 libxml2 libedit2 libsqlite3-0 libncurses6 zlib1g libgcc-s1 libstdc++6

  echo "==> 下载 Swift ${SWIFT_VERSION}"
  TARBALL="swift-${SWIFT_VERSION}-RELEASE-${CODENAME}.tar.gz"
  URL="https://download.swift.org/swift-${SWIFT_VERSION}-release/${CODENAME}/swift-${SWIFT_VERSION}-RELEASE/${TARBALL}"
  mkdir -p /opt/swift
  curl -fL --retry 3 -o "/opt/swift/${TARBALL}" "$URL"

  echo "==> 解压到 /opt/swift"
  tar xzf "/opt/swift/${TARBALL}" -C /opt/swift
  ln -sf "/opt/swift/swift-${SWIFT_VERSION}-RELEASE-${CODENAME}/usr/bin/swift" /usr/local/bin/swift
  ln -sf "/opt/swift/swift-${SWIFT_VERSION}-RELEASE-${CODENAME}/usr/bin/swiftc" /usr/local/bin/swiftc
fi

echo "==> 完成"
swift --version
