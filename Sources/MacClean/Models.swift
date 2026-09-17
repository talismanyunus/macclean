import Foundation
import SwiftUI

enum CleanupCategory: String, CaseIterable, Identifiable, Hashable {
    case caches
    case logs
    case developer
    case installers
    case largeFiles
    case trash

    var id: String { rawValue }

    static var visibleCases: [CleanupCategory] {
        #if APP_STORE
        allCases.filter { $0 != .trash }
        #else
        allCases
        #endif
    }

    var title: String {
        switch self {
        case .caches:     return L(.categoryCachesTitle)
        case .logs:       return L(.categoryLogsTitle)
        case .developer:  return L(.categoryDeveloperTitle)
        case .installers: return L(.categoryInstallersTitle)
        case .largeFiles: return L(.categoryLargeFilesTitle)
        case .trash:      return L(.categoryTrashTitle)
        }
    }

    var subtitle: String {
        switch self {
        case .caches:     return L(.categoryCachesSubtitle)
        case .logs:       return L(.categoryLogsSubtitle)
        case .developer:  return L(.categoryDeveloperSubtitle)
        case .installers: return L(.categoryInstallersSubtitle)
        case .largeFiles: return L(.categoryLargeFilesSubtitle)
        case .trash:      return L(.categoryTrashSubtitle)
        }
    }

    var icon: String {
        switch self {
        case .caches:     return "shippingbox.fill"
        case .logs:       return "doc.text.magnifyingglass"
        case .developer:  return "hammer.fill"
        case .installers: return "arrow.down.circle.fill"
        case .largeFiles: return "externaldrive.fill"
        case .trash:      return "trash.fill"
        }
    }

    var tint: Color {
        switch self {
        case .caches:     return .blue
        case .logs:       return .purple
        case .developer:  return .orange
        case .installers: return .teal
        case .largeFiles: return .pink
        case .trash:      return .red
        }
    }

    var safetyNote: String {
        switch self {
        case .caches:     return L(.categoryCachesSafetyNote)
        case .logs:       return L(.categoryLogsSafetyNote)
        case .developer:  return L(.categoryDeveloperSafetyNote)
        case .installers: return L(.categoryInstallersSafetyNote)
        case .largeFiles: return L(.categoryLargeFilesSafetyNote)
        case .trash:      return L(.categoryTrashSafetyNote)
        }
    }

    var reviewDescription: String {
        switch self {
        case .caches:     return L(.categoryCachesReviewDesc)
        case .logs:       return L(.categoryLogsReviewDesc)
        case .developer:  return L(.categoryDeveloperReviewDesc)
        case .installers: return L(.categoryInstallersReviewDesc)
        case .largeFiles: return L(.categoryLargeFilesReviewDesc)
        case .trash:      return L(.categoryTrashReviewDesc)
        }
    }

    var protectedDataNote: String? {
        switch self {
        case .caches:     return L(.categoryCachesProtectedNote)
        case .developer:  return L(.categoryDeveloperProtectedNote)
        case .installers: return L(.categoryInstallersProtectedNote)
        case .largeFiles: return L(.categoryLargeFilesProtectedNote)
        case .logs, .trash: return nil
        }
    }

    var deletionMode: DeletionMode {
        switch self {
        case .installers, .largeFiles: return .moveToTrash
        case .caches, .logs, .developer, .trash: return .permanent
        }
    }

    var isRecommended: Bool {
        switch self {
        case .caches, .logs, .developer: return true
        case .installers, .largeFiles, .trash: return false
        }
    }

    var needsHomeFolderPermission: Bool {
        self != .trash
    }
}

enum DeletionMode {
    case permanent
    case moveToTrash
}

struct CleanupItem: Identifiable, Hashable {
    let id: String
    let category: CleanupCategory
    let url: URL
    let size: Int64
    let modifiedAt: Date?
    let deletionMode: DeletionMode
    let isDirectory: Bool

    var name: String { url.lastPathComponent.isEmpty ? url.path : url.lastPathComponent }
    var path: String { url.path.replacingOccurrences(of: NSHomeDirectory(), with: "~") }
}

struct CategoryScan: Equatable {
    let items: [CleanupItem]
    let totalSize: Int64

    static let empty = CategoryScan(items: [], totalSize: 0)
}

struct CleanupOutcome {
    var permanentlyDeleted: Int64 = 0
    var movedToTrash: Int64 = 0
    var failures: [String] = []

    var totalProcessed: Int64 { permanentlyDeleted + movedToTrash }
}

struct DiskUsage: Equatable {
    let total: Int64
    let available: Int64

    var used: Int64 { max(0, total - available) }
    var usedFraction: Double {
        guard total > 0 else { return 0 }
        return min(1, max(0, Double(used) / Double(total)))
    }
}

extension Int64 {
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: self, countStyle: .file)
    }
}
