import Foundation

enum DiskScanner {
    private static let installers: Set<String> = [
        "dmg", "pkg", "mpkg", "zip", "rar", "7z", "iso", "app.zip"
    ]

    static func scanAll(homeURL: URL?) -> [CleanupCategory: CategoryScan] {
        Dictionary(uniqueKeysWithValues: CleanupCategory.allCases.map { category in
            (category, scan(category, homeURL: homeURL))
        })
    }

    static func currentDiskUsage() -> DiskUsage? {
        let rootVolume = URL(fileURLWithPath: "/")
        guard let values = try? rootVolume.resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityKey]),
              let total = values.volumeTotalCapacity,
              let available = values.volumeAvailableCapacity
        else { return nil }
        return DiskUsage(total: Int64(total), available: Int64(available))
    }

    static func scan(_ category: CleanupCategory, homeURL: URL?) -> CategoryScan {
        guard let homeURL else { return .empty }
        let items: [CleanupItem]
        switch category {
        case .caches:
            items = children(in: homeURL.appending(path: "Library/Caches"), category: category)
        case .logs:
            items = children(in: homeURL.appending(path: "Library/Logs"), category: category)
                + children(in: homeURL.appending(path: "Library/DiagnosticReports"), category: category)
        case .developer:
            items = children(in: homeURL.appending(path: "Library/Developer/Xcode/DerivedData"), category: category)
                + children(in: homeURL.appending(path: "Library/Developer/CoreSimulator/Caches"), category: category)
                + children(in: homeURL.appending(path: "Library/Caches/com.apple.dt.Xcode"), category: category)
        case .installers:
            items = installerFiles(in: homeURL.appending(path: "Downloads"))
        case .largeFiles:
            items = largeFiles(in: ["Downloads", "Desktop", "Documents", "Movies"].map { homeURL.appending(path: $0) })
        case .trash:
            #if APP_STORE
            // The App Store sandbox does not grant a safe, durable scope to the
            // Finder Trash. The user can empty it from Finder instead.
            items = []
            #else
            items = children(in: homeURL.appending(path: ".Trash"), category: category)
            #endif
        }

        return CategoryScan(items: items.sorted { $0.size > $1.size }, totalSize: items.reduce(0) { $0 + $1.size })
    }

    static func children(in directory: URL, category: CleanupCategory) -> [CleanupItem] {
        guard let urls = try? FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey, .fileSizeKey, .contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }

        return urls.compactMap { item(for: $0, category: category) }
    }

    private static func installerFiles(in directory: URL) -> [CleanupItem] {
        guard let urls = try? FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey, .fileSizeKey, .contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }

        return urls.compactMap { url in
            let suffix = url.pathExtension.lowercased()
            guard installers.contains(suffix), let item = item(for: url, category: .installers) else { return nil }
            return item
        }
    }

    private static func largeFiles(in directories: [URL]) -> [CleanupItem] {
        let threshold: Int64 = 500 * 1_024 * 1_024
        return directories.flatMap { directory -> [CleanupItem] in
            guard let urls = try? FileManager.default.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [.isRegularFileKey, .fileSizeKey, .contentModificationDateKey],
                options: [.skipsHiddenFiles]
            ) else { return [] }

            return urls.compactMap { url in
                guard let item = item(for: url, category: .largeFiles), item.size >= threshold else { return nil }
                guard let modifiedAt = item.modifiedAt,
                      Calendar.current.dateComponents([.day], from: modifiedAt, to: .now).day ?? 0 >= 14
                else { return nil }
                return item
            }
        }
    }

    private static func item(for url: URL, category: CleanupCategory) -> CleanupItem? {
        let values = try? url.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey, .isDirectoryKey, .isSymbolicLinkKey])
        guard let values, values.isSymbolicLink != true else { return nil }
        let size: Int64
        if values.isDirectory == true {
            size = recursiveSize(of: url)
        } else {
            size = Int64(values.fileSize ?? 0)
        }
        return CleanupItem(
            id: url.standardizedFileURL.path,
            category: category,
            url: url,
            size: size,
            modifiedAt: values.contentModificationDate,
            deletionMode: category.deletionMode,
            isDirectory: values.isDirectory == true
        )
    }

    private static func recursiveSize(of directory: URL) -> Int64 {
        let keys: Set<URLResourceKey> = [.fileSizeKey, .totalFileAllocatedSizeKey, .isRegularFileKey]
        guard let enumerator = FileManager.default.enumerator(
            at: directory,
            includingPropertiesForKeys: Array(keys),
            options: [.skipsHiddenFiles, .skipsPackageDescendants],
            errorHandler: { _, _ in true }
        ) else { return 0 }

        var total: Int64 = 0
        for case let fileURL as URL in enumerator {
            guard let values = try? fileURL.resourceValues(forKeys: keys), values.isRegularFile == true else { continue }
            total += Int64(values.totalFileAllocatedSize ?? values.fileSize ?? 0)
        }
        return total
    }
}
