import Foundation
import SwiftUI
import AppKit

@MainActor
final class CleanerViewModel: ObservableObject {
    @Published private(set) var scans: [CleanupCategory: CategoryScan] = [:]
    @Published var selectedItemIDs: Set<String> = []
    @Published private(set) var isScanning = false
    @Published private(set) var isCleaning = false
    @Published var lastOutcome: CleanupOutcome?
    @Published var showConfirmation = false
    @Published var errorMessage: String?
    @Published var showPrivacyPolicy = false
    @Published private(set) var hasHomeFolderAccess = false
    @Published private(set) var homeFolderName: String?
    @Published var showHomeFolderSetup = false
    @Published private(set) var systemDataFolderName: String?
    @Published private(set) var hasFullDiskAccess = false
    @Published var showFullDiskAccessSetup = false
    @Published private(set) var diskUsage: DiskUsage?
    @Published private(set) var systemStorageAreas: [SystemStorageArea] = []
    @Published private(set) var isInspectingSystemData = false

    private let homeFolderBookmarkKey = "MacClean.homeFolderBookmark"
    private let systemDataBookmarkKey = "MacClean.systemDataBookmark"
    private let fullDiskAccessKey = "MacClean.fullDiskAccessConfirmed"
    private var homeFolderURL: URL?
    private var systemDataFolderURL: URL?
    private var activeSecurityScopedURLs: [URL] = []

    init() {
        #if APP_STORE
        restoreSavedFolders()
        #else
        let home = FileManager.default.homeDirectoryForCurrentUser
        homeFolderURL = home
        homeFolderName = home.lastPathComponent
        hasHomeFolderAccess = true
        hasFullDiskAccess = UserDefaults.standard.bool(forKey: fullDiskAccessKey)
        #endif
        scan()
    }

    deinit {
        activeSecurityScopedURLs.forEach { $0.stopAccessingSecurityScopedResource() }
    }

    var totalFound: Int64 {
        scans.values.reduce(0) { $0 + $1.totalSize }
    }

    var selectedItems: [CleanupItem] {
        scans.values
            .flatMap(\.items)
            .filter { selectedItemIDs.contains($0.id) }
    }

    var selectedSize: Int64 {
        selectedItems.reduce(0) { $0 + $1.size }
    }

    var selectedPermanentSize: Int64 {
        selectedItems.filter { $0.deletionMode == .permanent }.reduce(0) { $0 + $1.size }
    }

    var selectedTrashSize: Int64 {
        selectedItems.filter { $0.deletionMode == .moveToTrash }.reduce(0) { $0 + $1.size }
    }

    func scan() {
        guard !isScanning && !isCleaning else { return }
        isScanning = true
        lastOutcome = nil
        let previousSelection = selectedItemIDs
        let accessibleHomeURL = homeFolderURL

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let results = DiskScanner.scanAll(homeURL: accessibleHomeURL)
            let currentDiskUsage = DiskScanner.currentDiskUsage()
            DispatchQueue.main.async {
                guard let self else { return }
                self.scans = results
                self.diskUsage = currentDiskUsage
                let availableIDs = Set(results.values.flatMap(\.items).map(\.id))
                self.selectedItemIDs = previousSelection.intersection(availableIDs)
                self.isScanning = false
            }
        }
    }

    func toggle(_ item: CleanupItem) {
        if selectedItemIDs.contains(item.id) {
            selectedItemIDs.remove(item.id)
        } else {
            selectedItemIDs.insert(item.id)
        }
    }

    func toggleCategory(_ category: CleanupCategory) {
        let ids = Set((scans[category]?.items ?? []).map(\.id))
        guard !ids.isEmpty else { return }
        if ids.isSubset(of: selectedItemIDs) {
            selectedItemIDs.subtract(ids)
        } else {
            selectedItemIDs.formUnion(ids)
        }
    }

    func beginCleanup() {
        guard !selectedItems.isEmpty else { return }
        showConfirmation = true
    }

    func scanSystemData() {
        #if APP_STORE
        guard let systemDataFolderURL else {
            chooseSystemDataFolder()
            return
        }
        #else
        guard hasFullDiskAccess else {
            showFullDiskAccessSetup = true
            return
        }
        #endif
        guard !isInspectingSystemData else { return }
        isInspectingSystemData = true
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            #if APP_STORE
            let areas = SystemDataScanner.scan(rootURL: systemDataFolderURL)
            #else
            let areas = SystemDataScanner.scanHome()
            #endif
            DispatchQueue.main.async {
                guard let self else { return }
                self.systemStorageAreas = areas
                self.isInspectingSystemData = false
            }
        }
    }

    func chooseHomeFolder() {
        let panel = NSOpenPanel()
        panel.title = L(.panelHomeFolderTitle)
        panel.message = L(.panelHomeFolderMessage)
        panel.prompt = L(.panelHomeFolderPrompt)
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = false
        panel.allowsMultipleSelection = false
        panel.directoryURL = URL(fileURLWithPath: NSHomeDirectory())
        panel.begin { [weak self] response in
            guard response == .OK, let url = panel.url else { return }
            self?.saveHomeFolder(url)
        }
    }

    func openFullDiskAccessSettings() {
        guard let settingsURL = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles") else { return }
        NSWorkspace.shared.open(settingsURL)
    }

    func confirmFullDiskAccess() {
        hasFullDiskAccess = true
        showFullDiskAccessSetup = false
        UserDefaults.standard.set(true, forKey: fullDiskAccessKey)
        scanSystemData()
    }

    func chooseSystemDataFolder() {
        let panel = NSOpenPanel()
        panel.title = L(.panelSystemDataTitle)
        panel.message = L(.panelSystemDataMessage)
        panel.prompt = L(.panelSystemDataPrompt)
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = false
        panel.allowsMultipleSelection = false
        panel.directoryURL = URL(fileURLWithPath: NSHomeDirectory()).appending(path: "Library")
        panel.begin { [weak self] response in
            guard response == .OK, let url = panel.url else { return }
            self?.saveSystemDataFolder(url)
        }
    }

    func cleanupSelected() {
        guard !isCleaning else { return }
        showConfirmation = false
        let items = selectedItems
        isCleaning = true
        errorMessage = nil

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            var outcome = CleanupOutcome()
            let manager = FileManager.default
            for item in items {
                do {
                    switch item.deletionMode {
                    case .permanent:
                        try manager.removeItem(at: item.url)
                        outcome.permanentlyDeleted += item.size
                    case .moveToTrash:
                        _ = try manager.trashItem(at: item.url, resultingItemURL: nil)
                        outcome.movedToTrash += item.size
                    }
                } catch {
                    outcome.failures.append("\(item.name): \(error.localizedDescription)")
                }
            }

            DispatchQueue.main.async {
                guard let self else { return }
                self.isCleaning = false
                self.lastOutcome = outcome
                self.selectedItemIDs = []
                self.scan()
            }
        }
    }

    func revokeFolderAccess() {
        #if APP_STORE
        activeSecurityScopedURLs.forEach { $0.stopAccessingSecurityScopedResource() }
        activeSecurityScopedURLs.removeAll()
        UserDefaults.standard.removeObject(forKey: homeFolderBookmarkKey)
        UserDefaults.standard.removeObject(forKey: systemDataBookmarkKey)
        homeFolderURL = nil
        systemDataFolderURL = nil
        homeFolderName = nil
        systemDataFolderName = nil
        hasHomeFolderAccess = false
        systemStorageAreas = []
        selectedItemIDs = []
        scan()
        #else
        UserDefaults.standard.removeObject(forKey: fullDiskAccessKey)
        hasFullDiskAccess = false
        systemStorageAreas = []
        #endif
    }

    private func restoreSavedFolders() {
        if let data = UserDefaults.standard.data(forKey: homeFolderBookmarkKey),
           let resolved = ScopedFolderAccess.resolve(data) {
            activateSecurityScope(for: resolved.url)
            homeFolderURL = resolved.url
            homeFolderName = resolved.url.lastPathComponent
            hasHomeFolderAccess = true
            if resolved.isStale, let renewed = try? ScopedFolderAccess.makeBookmark(for: resolved.url) {
                UserDefaults.standard.set(renewed, forKey: homeFolderBookmarkKey)
            }
        }

        if let data = UserDefaults.standard.data(forKey: systemDataBookmarkKey),
           let resolved = ScopedFolderAccess.resolve(data) {
            activateSecurityScope(for: resolved.url)
            systemDataFolderURL = resolved.url
            systemDataFolderName = resolved.url.lastPathComponent
            if resolved.isStale, let renewed = try? ScopedFolderAccess.makeBookmark(for: resolved.url) {
                UserDefaults.standard.set(renewed, forKey: systemDataBookmarkKey)
            }
        }
    }

    private func saveHomeFolder(_ url: URL) {
        let expectedHome = URL(fileURLWithPath: NSHomeDirectory()).standardizedFileURL
        guard url.standardizedFileURL.path == expectedHome.path else {
            errorMessage = String(format: L(.errorWrongHomeFolder), expectedHome.path)
            return
        }
        do {
            let data = try ScopedFolderAccess.makeBookmark(for: url)
            UserDefaults.standard.set(data, forKey: homeFolderBookmarkKey)
            let scopedURL = url.standardizedFileURL
            activateSecurityScope(for: scopedURL)
            homeFolderURL = scopedURL
            homeFolderName = scopedURL.lastPathComponent
            hasHomeFolderAccess = true
            showHomeFolderSetup = false
            scan()
        } catch {
            errorMessage = String(format: L(.errorSaveBookmark), error.localizedDescription)
        }
    }

    private func saveSystemDataFolder(_ url: URL) {
        do {
            let data = try ScopedFolderAccess.makeBookmark(for: url)
            UserDefaults.standard.set(data, forKey: systemDataBookmarkKey)
            let scopedURL = url.standardizedFileURL
            activateSecurityScope(for: scopedURL)
            systemDataFolderURL = scopedURL
            systemDataFolderName = scopedURL.lastPathComponent
            systemStorageAreas = []
            scanSystemData()
        } catch {
            errorMessage = String(format: L(.errorSaveSystemBookmark), error.localizedDescription)
        }
    }

    private func activateSecurityScope(for url: URL) {
        guard !activeSecurityScopedURLs.contains(url) else { return }
        _ = url.startAccessingSecurityScopedResource()
        activeSecurityScopedURLs.append(url)
    }
}
