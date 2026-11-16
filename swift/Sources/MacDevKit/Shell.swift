import Foundation

/// 当前运行平台的描述。macOS 与 Linux 共用同一套代码，
/// 只有在 macOS 上才会去检查 Xcode / 模拟器。
public enum PlatformInfo {
    public static var isMac: Bool {
        #if os(macOS)
        return true
        #else
        return false
        #endif
    }

    public static var name: String {
        #if os(macOS)
        return "macOS"
        #elseif os(Linux)
        return "Linux"
        #else
        return "Unknown"
        #endif
    }

    public static var arch: String {
        #if arch(arm64)
        return "arm64"
        #elseif arch(x86_64)
        return "x86_64"
        #else
        return "unknown"
        #endif
    }

    /// 运行时读取 `swift --version`，拿不到就退回编译期判断。
    public static var swiftVersion: String {
        let result = Shell.run("swift", ["--version"])
        if result.code == 0, let first = result.output.split(separator: "\n").first {
            return first.replacingOccurrences(of: "Swift version ", with: "")
        }
        #if swift(>=6.0)
        return "6.x (编译期)"
        #elseif swift(>=5.9)
        return "5.9+ (编译期)"
        #else
        return "unknown"
        #endif
    }
}

/// 很薄的进程调用封装，避免引入第三方依赖。
public enum Shell {
    public struct Result {
        public let code: Int32
        public let output: String
    }

    @discardableResult
    public static func run(_ tool: String, _ arguments: [String] = []) -> Result {
        let process = Process()
        let pipe = Pipe()

        // 用 /usr/bin/env 解析 PATH，这样 brew / xcrun 这类都能找到
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = [tool] + arguments
        process.standardOutput = pipe
        process.standardError = pipe
        process.standardInput = FileHandle.nullDevice

        do {
            try process.run()
        } catch {
            return Result(code: -1, output: "")
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        let text = String(decoding: data, as: UTF8.self)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return Result(code: process.terminationStatus, output: text)
    }

    public static func which(_ name: String) -> String? {
        let result = run("/bin/sh", ["-lc", "command -v \(name)"])
        guard result.code == 0, !result.output.isEmpty else { return nil }
        return result.output.split(separator: "\n").first.map(String.init)
    }

    /// 统计一段文本里包含关键字的行数。
    public static func countLines(containing needle: String, in text: String) -> Int {
        text.split(separator: "\n").filter { $0.contains(needle) }.count
    }
}
