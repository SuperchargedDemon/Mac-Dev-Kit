import Foundation
import MacDevKit

let arguments = Array(CommandLine.arguments.dropFirst())
let command = arguments.first ?? "doctor"

func printHelp() {
    print("""
    macdev — 跨平台的 macOS 开发环境自检工具

    用法:
      macdev doctor      检查 Swift / Xcode / 模拟器 / Homebrew 是否就绪
      macdev sysinfo     打印当前机器与工具链信息
      macdev version     版本号
      macdev help        这份帮助

    在 macOS 上，doctor 会检查 Xcode、iOS SDK 与模拟器；
    在 Linux 上，这些项会标记为「跳过」，但 Swift 包仍可编译与测试。
    """)
}

func printSysInfo() {
    let process = ProcessInfo.processInfo
    let memory = (Double(process.physicalMemory) / 1_073_741_824 * 10).rounded() / 10
    let rows: [(String, String)] = [
        ("platform", "\(PlatformInfo.name) \(PlatformInfo.arch)"),
        ("host", process.hostName),
        ("cores", "\(process.processorCount)"),
        ("memory", "\(memory) GB"),
        ("swift", PlatformInfo.swiftVersion),
        ("cwd", FileManager.default.currentDirectoryPath)
    ]
    print("macdev sysinfo")
    print("")
    for (key, value) in rows {
        print("  \(key.padding(toLength: 10, withPad: " ", startingAt: 0)) \(value)")
    }
}

switch command {
case "doctor":
    let checks = Doctor.runAll()
    print(Doctor.render(checks))
    exit(Doctor.exitCode(for: checks))

case "sysinfo":
    printSysInfo()

case "version":
    print("macdev 1.0.0 · Swift \(PlatformInfo.swiftVersion)")

case "help", "-h", "--help":
    printHelp()

default:
    FileHandle.standardError.write(Data("macdev: 未知命令 \(command)\n".utf8))
    printHelp()
    exit(2)
}
