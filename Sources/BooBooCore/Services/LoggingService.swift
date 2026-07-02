import Foundation

public final class LoggingService: Sendable {
    private let logDir: String
    private let maxBytes: Int
    private let fm: FileManager
    private let lock: NSLock
    private let isoFormatter: ISO8601DateFormatter

    public init(logDir: String = NSHomeDirectory() + "/Library/Logs/BooBoo", maxBytes: Int = 10_485_760) {
        self.logDir = logDir
        self.maxBytes = maxBytes
        self.fm = FileManager.default
        self.lock = NSLock()
        self.isoFormatter = ISO8601DateFormatter()
    }

    private func ensureDirectory() throws {
        var isDir: ObjCBool = false
        if !fm.fileExists(atPath: logDir, isDirectory: &isDir) {
            try fm.createDirectory(atPath: logDir, withIntermediateDirectories: true)
        }
    }

    private func log(level: String, _ message: String) {
        lock.lock()
        defer { lock.unlock() }

        do {
            try ensureDirectory()

            let now = isoFormatter.string(from: Date())
            let entry: [String: Any] = [
                "timestamp": now,
                "level": level,
                "message": message,
            ]
            let json = try JSONSerialization.data(withJSONObject: entry, options: [.sortedKeys])
            let line = String(data: json, encoding: .utf8)! + "\n"

            let logPath = (logDir as NSString).appendingPathComponent("booboo.jsonl")
            rotateIfNeeded(logPath: logPath)

            let handle = try FileHandle(forWritingTo: URL(fileURLWithPath: logPath))
            handle.seekToEndOfFile()
            handle.write(Data(line.utf8))
            try handle.close()
        } catch {
            NSLog("BooBoo logging error: \(error.localizedDescription)")
        }
    }

    private func rotateIfNeeded(logPath: String) {
        guard fm.fileExists(atPath: logPath) else { return }
        guard let attrs = try? fm.attributesOfItem(atPath: logPath) else { return }
        let size = attrs[.size] as? UInt64 ?? 0
        guard size > maxBytes else { return }

        let rotated = (logDir as NSString).appendingPathComponent("booboo.jsonl.old")
        _ = try? fm.removeItem(atPath: rotated)
        try? fm.moveItem(atPath: logPath, toPath: rotated)
    }

    public func info(_ message: String) {
        log(level: "INFO", message)
    }

    public func warn(_ message: String) {
        log(level: "WARN", message)
    }

    public func error(_ message: String) {
        log(level: "ERROR", message)
    }
}
