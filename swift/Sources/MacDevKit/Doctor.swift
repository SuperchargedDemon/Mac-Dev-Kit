import Foundation

public struct Check {
    public enum Status: String {
        case ok = "✓"
        case warn = "!"
        case fail = "✗"
        case skipped = "○"
    }

    public let name: String
    public let status: Status
    public let detail: String
    public let hint: String?

    public init(name: String, status: Status, detail: String, hint: String? = nil) {
        self.name = name
        self.status = status
        self.detail = detail
        self.hint = hint
    }
}

public enum Doctor {

    public static func runAll() -> [Check] {
        var checks: [Check] = [swiftCheck(), gitCheck()]

        if PlatformInfo.isMac {
            checks.append(xcodeCheck())
            checks.append(iOSSDKCheck())
            checks.append(simulatorCheck())
            checks.append(homebrewCheck())
        } else {
            checks.append(Check(name: "Xcode",
                                status: .skipped,
                                detail: "仅 macOS 可用，当前是 \(PlatformInfo.name)",
                                hint: "真机编译走 GitHub Actions 的 macos-14 runner，见 README"))
            checks.append(Check(name: "iOS SDK",
                                status: .skipped,
                                detail: "Linux 上的 Swift 没有 Apple SDK",
                                hint: "可以编译 Swift 包与命令行工具，不能链接 UIKit / SwiftUI"))
            checks.append(Check(name: "Simulators",
                                status: .skipped,
                                detail: "需要 Xcode 与 CoreSimulator"))
            checks.append(Check(name: "Homebrew",
                                status: .skipped,
                                detail: "brew on Linux 只能装 CLI 工具",
                                hint: "完整的 bottle 依赖仍要在 macOS 上装"))
        }

        checks.append(nodeCheck())
        checks.append(architectureCheck())
        return checks
    }

    // MARK: - 单项检查

    static func swiftCheck() -> Check {
        let result = Shell.run("swift", ["--version"])
        guard result.code == 0, let first = result.output.split(separator: "\n").first else {
            return Check(name: "Swift", status: .fail, detail: "找不到 swift",
                         hint: "安装 Xcode，或在 Linux 上运行 scripts/bootstrap-swift-linux.sh")
        }
        let detail = String(first).replacingOccurrences(of: "Swift version ", with: "")
        return Check(name: "Swift", status: .ok, detail: detail)
    }

    static func gitCheck() -> Check {
        let result = Shell.run("git", ["--version"])
        guard result.code == 0 else {
            return Check(name: "Git", status: .warn, detail: "未安装")
        }
        return Check(name: "Git", status: .ok, detail: result.output)
    }

    static func xcodeCheck() -> Check {
        let path = Shell.run("xcode-select", ["-p"])
        guard path.code == 0 else {
            return Check(name: "Xcode", status: .fail, detail: "未安装或未选择开发者目录",
                         hint: "xcode-select --install 或从 App Store 安装 Xcode")
        }
        let version = Shell.run("xcodebuild", ["-version"])
        let line = version.output.split(separator: "\n").first.map(String.init) ?? "unknown"
        return Check(name: "Xcode", status: .ok, detail: "\(line) · \(path.output)")
    }

    static func iOSSDKCheck() -> Check {
        let result = Shell.run("xcrun", ["--sdk", "iphonesimulator", "--show-sdk-version"])
        guard result.code == 0, !result.output.isEmpty else {
            return Check(name: "iOS SDK", status: .warn, detail: "未找到模拟器 SDK",
                         hint: "Xcode → Settings → Platforms 里安装 iOS SDK")
        }
        return Check(name: "iOS SDK", status: .ok, detail: "iphonesimulator \(result.output)")
    }

    static func simulatorCheck() -> Check {
        let result = Shell.run("xcrun", ["simctl", "list", "devices", "available"])
        guard result.code == 0 else {
            return Check(name: "Simulators", status: .warn, detail: "simctl 不可用")
        }
        let count = Shell.countLines(containing: "iPhone", in: result.output)
        return Check(name: "Simulators",
                     status: count > 0 ? .ok : .warn,
                     detail: count > 0 ? "\(count) 台可用 iPhone 模拟器" : "没有可用的 iPhone 模拟器",
                     hint: count > 0 ? nil : "Xcode → Settings → Platforms 下载 iOS 运行时")
    }

    static func homebrewCheck() -> Check {
        guard let brew = Shell.which("brew") else {
            return Check(name: "Homebrew", status: .warn, detail: "未安装",
                         hint: "https://brew.sh")
        }
        let version = Shell.run(brew, ["--version"]).output
            .split(separator: "\n").first.map(String.init) ?? ""
        return Check(name: "Homebrew", status: .ok, detail: version)
    }

    static func nodeCheck() -> Check {
        let result = Shell.run("node", ["-v"])
        guard result.code == 0 else {
            return Check(name: "Node", status: .warn, detail: "未安装（可选）")
        }
        return Check(name: "Node", status: .ok, detail: result.output)
    }

    static func architectureCheck() -> Check {
        let process = ProcessInfo.processInfo
        let memory = (Double(process.physicalMemory) / 1_073_741_824 * 10).rounded() / 10
        let detail = "\(PlatformInfo.arch) · \(process.processorCount) 核 · \(memory) GB 内存"
        return Check(name: "Machine", status: .ok, detail: detail)
    }

    // MARK: - 输出

    public static func render(_ checks: [Check], title: String? = nil) -> String {
        var lines: [String] = []
        lines.append(title ?? "macdev doctor · \(PlatformInfo.name) \(PlatformInfo.arch)")
        lines.append("")

        for check in checks {
            let padded = check.name.padding(toLength: 22, withPad: " ", startingAt: 0)
            lines.append("  \(check.status.rawValue) \(padded) \(check.detail)")
            if let hint = check.hint {
                lines.append("      → \(hint)")
            }
        }

        let ok = checks.filter { $0.status == .ok }.count
        let skipped = checks.filter { $0.status == .skipped }.count
        let failed = checks.filter { $0.status == .fail }.count
        let warned = checks.filter { $0.status == .warn }.count

        lines.append("")
        lines.append("\(ok) 通过 · \(warned) 警告 · \(skipped) 跳过 · \(failed) 失败")
        return lines.joined(separator: "\n")
    }

    public static func exitCode(for checks: [Check]) -> Int32 {
        checks.contains { $0.status == .fail } ? 1 : 0
    }

    public static func summary() -> (ok: Int, warn: Int, skipped: Int, fail: Int) {
        let checks = runAll()
        return (
            checks.filter { $0.status == .ok }.count,
            checks.filter { $0.status == .warn }.count,
            checks.filter { $0.status == .skipped }.count,
            checks.filter { $0.status == .fail }.count
        )
    }
}
