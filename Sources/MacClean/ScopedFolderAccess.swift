import Foundation

/// Persists a user-selected folder as a security-scoped bookmark.
/// The bookmark gives the sandboxed App Store build access only to the folder
/// the person explicitly chose, including across future launches.
enum ScopedFolderAccess {
    static func makeBookmark(for url: URL) throws -> Data {
        try url.bookmarkData(
            options: [.withSecurityScope],
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
    }

    static func resolve(_ data: Data) -> (url: URL, isStale: Bool)? {
        var isStale = false
        guard let url = try? URL(
            resolvingBookmarkData: data,
            options: [.withSecurityScope, .withoutUI],
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        ) else {
            return nil
        }
        return (url.standardizedFileURL, isStale)
    }
}
