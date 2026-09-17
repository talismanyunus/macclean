import Foundation
import SQLite3

struct WhatsAppChatUsage: Identifiable, Hashable {
    let chatID: String
    let displayName: String
    let kind: Kind
    let mediaFolderURL: URL
    let size: Int64
    let mediaCount: Int

    var id: String { chatID }

    enum Kind: Hashable {
        case direct
        case group
        case status
        case unknown

        var title: String {
            switch self {
            case .direct:  return L(.whatsappKindDirect)
            case .group:   return L(.whatsappKindGroup)
            case .status:  return L(.whatsappKindStatus)
            case .unknown: return L(.whatsappKindUnknown)
            }
        }

        var icon: String {
            switch self {
            case .direct:  return "person.fill"
            case .group:   return "person.2.fill"
            case .status:  return "circle.dotted"
            case .unknown: return "message.fill"
            }
        }
    }
}

enum WhatsAppStorageScanner {
    static func scan(rootURL: URL) -> [WhatsAppChatUsage] {
        let mediaRoot = rootURL.appending(path: "Message/Media")
        let names = chatNames(from: rootURL.appending(path: "ChatStorage.sqlite"))
        guard let folders = try? FileManager.default.contentsOfDirectory(
            at: mediaRoot,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }

        return folders.compactMap { folder in
            guard (try? folder.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true else { return nil }
            let chatID = folder.lastPathComponent
            let meta = names[chatID] ?? fallbackMetadata(for: chatID)
            return WhatsAppChatUsage(
                chatID: chatID,
                displayName: meta.name,
                kind: meta.kind,
                mediaFolderURL: folder,
                size: SystemDataScanner.allocatedSize(of: folder),
                mediaCount: fileCount(in: folder)
            )
        }
        .filter { $0.size > 0 }
        .sorted { $0.size > $1.size }
    }

    private static func chatNames(from databaseURL: URL) -> [String: (name: String, kind: WhatsAppChatUsage.Kind)] {
        var database: OpaquePointer?
        guard sqlite3_open_v2(databaseURL.path, &database, SQLITE_OPEN_READONLY, nil) == SQLITE_OK else {
            return [:]
        }
        defer { sqlite3_close(database) }

        let sql = "SELECT ZCONTACTJID, ZPARTNERNAME, ZSESSIONTYPE FROM ZWACHATSESSION"
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK else { return [:] }
        defer { sqlite3_finalize(statement) }

        var result: [String: (name: String, kind: WhatsAppChatUsage.Kind)] = [:]
        while sqlite3_step(statement) == SQLITE_ROW {
            guard let identifierPointer = sqlite3_column_text(statement, 0) else { continue }
            let identifier = String(cString: identifierPointer)
            let name = sqlite3_column_text(statement, 1).map { String(cString: $0) }
            let sessionType = sqlite3_column_int(statement, 2)
            let resolvedName = (name?.isEmpty == false ? name! : nil) ?? fallbackMetadata(for: identifier).name
            result[identifier] = (resolvedName, sessionType == 1 ? .group : .direct)
        }
        return result
    }

    private static func fallbackMetadata(for chatID: String) -> (name: String, kind: WhatsAppChatUsage.Kind) {
        if chatID.hasSuffix(".status") {
            return (L(.whatsappFallbackStatusMedia), .status)
        }
        if chatID.contains("@g.us") {
            return (L(.whatsappFallbackGroup), .group)
        }
        return (chatID, .unknown)
    }

    private static func fileCount(in directory: URL) -> Int {
        guard let enumerator = FileManager.default.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsPackageDescendants],
            errorHandler: { _, _ in true }
        ) else { return 0 }

        var count = 0
        for case let fileURL as URL in enumerator {
            if (try? fileURL.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) == true {
                count += 1
            }
        }
        return count
    }
}
