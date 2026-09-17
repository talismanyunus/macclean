import Foundation

enum StorageAction: String, Hashable {
    case manageInApp
    case manageInXcode
    case manageInDocker
    case removeIfUnused
    case inspectFirst

    var title: String {
        switch self {
        case .manageInApp:     return L(.storageActionManageInAppTitle)
        case .manageInXcode:   return L(.storageActionManageInXcodeTitle)
        case .manageInDocker:  return L(.storageActionManageInDockerTitle)
        case .removeIfUnused:  return L(.storageActionRemoveIfUnusedTitle)
        case .inspectFirst:    return L(.storageActionInspectFirstTitle)
        }
    }

    var detail: String {
        switch self {
        case .manageInApp:    return L(.storageActionManageInAppDetail)
        case .manageInXcode:  return L(.storageActionManageInXcodeDetail)
        case .manageInDocker: return L(.storageActionManageInDockerDetail)
        case .removeIfUnused: return L(.storageActionRemoveIfUnusedDetail)
        case .inspectFirst:   return L(.storageActionInspectFirstDetail)
        }
    }
}

struct SystemStorageItem: Identifiable, Hashable {
    let url: URL
    let size: Int64
    let isDirectory: Bool
    let title: String
    let summary: String
    let action: StorageAction

    var id: String { url.standardizedFileURL.path }
    var path: String { url.path.replacingOccurrences(of: NSHomeDirectory(), with: "~") }
}

struct SystemStorageArea: Identifiable, Hashable {
    let title: String
    let subtitle: String
    let icon: String
    let rootURL: URL
    let items: [SystemStorageItem]

    var id: String { rootURL.standardizedFileURL.path }
    var totalSize: Int64 { items.reduce(0) { $0 + $1.size } }
}

enum SystemDataScanner {
    /// App Store builds inspect only a folder chosen in the system picker; they
    /// never enumerate other apps' containers on their own.
    static func scan(rootURL: URL) -> [SystemStorageArea] {
        guard FileManager.default.fileExists(atPath: rootURL.path) else { return [] }
        return [
            SystemStorageArea(
                title: rootURL.lastPathComponent.isEmpty ? L(.systemAreaSelectedFolder) : rootURL.lastPathComponent,
                subtitle: L(.systemAreaSelectedSubtitle),
                icon: "folder.badge.magnifyingglass",
                rootURL: rootURL,
                items: children(in: rootURL)
            )
        ]
    }

    static func scanHome() -> [SystemStorageArea] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let definitions: [(StringKey, StringKey, String, String)] = [
            (.systemAreaAppData,       .systemAreaAppDataSubtitle,       "app.badge",        "Library/Application Support"),
            (.systemAreaSharedAppData, .systemAreaSharedAppDataSubtitle, "person.2.fill",    "Library/Group Containers"),
            (.systemAreaDeveloperData, .systemAreaDeveloperDataSubtitle, "hammer.fill",      "Library/Developer"),
            (.systemAreaSandboxData,   .systemAreaSandboxDataSubtitle,   "shippingbox.fill", "Library/Containers")
        ]

        return definitions.compactMap { titleKey, subtitleKey, icon, relativePath in
            let rootURL = home.appending(path: relativePath)
            guard FileManager.default.fileExists(atPath: rootURL.path) else { return nil }
            return SystemStorageArea(
                title: L(titleKey),
                subtitle: L(subtitleKey),
                icon: icon,
                rootURL: rootURL,
                items: children(in: rootURL)
            )
        }
    }

    static func children(in directory: URL) -> [SystemStorageItem] {
        let keys: Set<URLResourceKey> = [.isDirectoryKey, .isSymbolicLinkKey, .fileSizeKey]
        guard let urls = try? FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: Array(keys),
            options: []
        ) else { return [] }

        return urls.compactMap { url in
            guard let values = try? url.resourceValues(forKeys: keys), values.isSymbolicLink != true else { return nil }
            let isDirectory = values.isDirectory ?? false
            let size = isDirectory ? allocatedSize(of: url) : Int64(values.fileSize ?? 0)
            let meta = metadata(for: url)
            return SystemStorageItem(
                url: url,
                size: size,
                isDirectory: isDirectory,
                title: meta.title,
                summary: meta.summary,
                action: meta.action
            )
        }
        .sorted { $0.size > $1.size }
    }

    static func allocatedSize(of directory: URL) -> Int64 {
        let keys: Set<URLResourceKey> = [.fileSizeKey, .totalFileAllocatedSizeKey, .isRegularFileKey]
        guard let enumerator = FileManager.default.enumerator(
            at: directory,
            includingPropertiesForKeys: Array(keys),
            options: [.skipsPackageDescendants],
            errorHandler: { _, _ in true }
        ) else { return 0 }

        var total: Int64 = 0
        for case let fileURL as URL in enumerator {
            guard let values = try? fileURL.resourceValues(forKeys: keys), values.isRegularFile == true else { continue }
            total += Int64(values.totalFileAllocatedSize ?? values.fileSize ?? 0)
        }
        return total
    }

    private static func metadata(for url: URL) -> (title: String, summary: String, action: StorageAction) {
        let path = url.path.lowercased()
        let name = url.lastPathComponent

        if path.contains("group.net.whatsapp.whatsapp") || path.contains("net.whatsapp.whatsapp") {
            return (L(.systemMetaWhatsApp), L(.systemMetaWhatsAppSummary), .manageInApp)
        }
        if path.contains("/kiro") {
            return (L(.systemMetaKiro), L(.systemMetaKiroSummary), .manageInApp)
        }
        if path.contains("coresimulator") {
            return (L(.systemMetaCoreSimulator), L(.systemMetaCoreSimulatorSummary), .manageInXcode)
        }
        if path.contains("com.docker.docker") {
            return (L(.systemMetaDocker), L(.systemMetaDockerSummary), .manageInDocker)
        }
        if path.contains("com.netease.mumu") {
            return (L(.systemMetaMuMu), L(.systemMetaMuMuSummary), .removeIfUnused)
        }
        if path.contains("/google") || path.contains("bravesoftware") || path.contains("microsoft edge") {
            return (name, L(.systemMetaBrowserSummary), .inspectFirst)
        }
        if path.contains("/code") || path.contains("cursor") || path.contains("claude") || path.contains("codex") {
            return (name, L(.systemMetaCodeEditorSummary), .inspectFirst)
        }
        return (name, L(.systemMetaGenericApp), .inspectFirst)
    }
}
