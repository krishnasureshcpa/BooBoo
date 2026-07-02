import Foundation

/// Safe wrapper around Process for running shell commands.
public struct ProcessRunner: Sendable {
    public struct Output: Sendable {
        public let stdout: String
        public let stderr: String
        public let exitCode: Int32
        public var succeeded: Bool { exitCode == 0 }
    }

    public enum Error: Swift.Error, LocalizedError, Sendable {
        case timeout(command: String)
        case launchFailed(Swift.Error)

        public var errorDescription: String? {
            switch self {
            case .timeout(let cmd): return "Command timed out: \(cmd)"
            case .launchFailed(let e): return "Failed to launch process: \(e.localizedDescription)"
            }
        }
    }

    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    @discardableResult
    public func run(executable: String, args: [String] = [], sudo: Bool = false,
                    timeout: TimeInterval = 30) async throws -> Output {
        let cmd: String
        let cmdArgs: [String]

        if sudo {
            cmd = "/usr/bin/sudo"
            cmdArgs = ["--non-interactive", executable] + args
        } else {
            cmd = executable
            cmdArgs = args
        }

        return try await withCheckedThrowingContinuation { continuation in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: cmd)
            process.arguments = cmdArgs

            let stdoutPipe = Pipe()
            let stderrPipe = Pipe()
            process.standardOutput = stdoutPipe
            process.standardError = stderrPipe

            let timerSource = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
            timerSource.schedule(deadline: .now() + timeout)
            timerSource.setEventHandler {
                if process.isRunning {
                    process.terminate()
                }
            }
            timerSource.resume()

            process.terminationHandler = { proc in
                timerSource.cancel()
                let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
                let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
                let output = Output(
                    stdout: String(data: stdoutData, encoding: .utf8) ?? "",
                    stderr: String(data: stderrData, encoding: .utf8) ?? "",
                    exitCode: proc.terminationStatus
                )
                continuation.resume(returning: output)
            }

            do {
                try process.run()
            } catch {
                timerSource.cancel()
                continuation.resume(throwing: Error.launchFailed(error))
            }
        }
    }

    @discardableResult
    public func runBash(_ script: String, timeout: TimeInterval = 30) async throws -> Output {
        try await run(executable: "/bin/bash", args: ["-c", script], timeout: timeout)
    }

    /// Read a plist key value using `defaults read`.
    public func readPlist(domain: String, key: String) async throws -> String? {
        let output = try await run(executable: "/usr/bin/defaults", args: ["read", domain, key])
        guard output.succeeded else { return nil }
        return output.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Check if a file exists.
    public func fileExists(_ path: String) -> Bool {
        FileManager.default.fileExists(atPath: path)
    }

    /// Check if a file contains a string.
    public func fileContains(_ path: String, _ substring: String) async throws -> Bool {
        let output = try await runBash("grep -c '\(substring)' '\(path)' 2>/dev/null || true")
        return output.succeeded && (output.stdout.trimmingCharacters(in: .whitespacesAndNewlines) != "0")
    }
}

// ponytail: synchronous fileExists helper, add async file I/O if latency becomes an issue
