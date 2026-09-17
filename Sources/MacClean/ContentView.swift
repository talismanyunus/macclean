import SwiftUI
import AppKit

struct ContentView: View {
    @EnvironmentObject private var cleaner: CleanerViewModel
    @EnvironmentObject private var langManager: LanguageManager
    @State private var selectedCategory: CleanupCategory? = nil
    @State private var isShowingSystemData = false
    @State private var browsedFolder: CleanupItem?
    @State private var showLanguagePicker = false

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            Rectangle()
                .fill(.separator.opacity(0.55))
                .frame(width: 1)
            mainContent
        }
        .background(Color(nsColor: .underPageBackgroundColor))
        .sheet(isPresented: $cleaner.showConfirmation) {
            CleanupReviewSheet()
                .environmentObject(cleaner)
                .environmentObject(langManager)
        }
        .sheet(isPresented: $cleaner.showHomeFolderSetup) {
            HomeFolderAccessSetupSheet()
                .environmentObject(cleaner)
                .environmentObject(langManager)
        }
        .sheet(isPresented: $cleaner.showFullDiskAccessSetup) {
            FullDiskAccessSetupSheet()
                .environmentObject(cleaner)
                .environmentObject(langManager)
        }
        .sheet(isPresented: $cleaner.showPrivacyPolicy) {
            PrivacyPolicySheet()
                .environmentObject(cleaner)
                .environmentObject(langManager)
        }
        .sheet(item: $browsedFolder) { folder in
            CleanupFolderBrowserSheet(folder: folder) {
                cleaner.scan()
            }
            .environmentObject(langManager)
        }
        .sheet(isPresented: $showLanguagePicker) {
            LanguagePickerSheet()
                .environmentObject(langManager)
        }
        .alert(L(.errorAlertTitle), isPresented: Binding(
            get: { cleaner.errorMessage != nil },
            set: { if !$0 { cleaner.errorMessage = nil } }
        )) {
            Button(L(.errorAlertOk), role: .cancel) { }
        } message: {
            Text(cleaner.errorMessage ?? "")
        }
        // Re-render when language changes
        .id(langManager.language)
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                AppLogo(size: 48, cornerRadius: 13)
                VStack(alignment: .leading, spacing: 3) {
                    Text(L(.appName))
                        .font(.title3.weight(.semibold))
                    Text(L(.appSubtitle))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 24)
            .padding(.bottom, 16)

            if let usage = cleaner.diskUsage {
                SidebarStorageStatus(usage: usage)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 16)
            }

            SidebarButton(
                title: L(.sidebarOverview),
                icon: "chart.pie.fill",
                isSelected: selectedCategory == nil && !isShowingSystemData
            ) {
                selectedCategory = nil
                isShowingSystemData = false
            }
            .padding(.horizontal, 10)

            Text(L(.sidebarSectionClean))
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.tertiary)
                .padding(.top, 24)
                .padding(.horizontal, 20)

            ForEach(CleanupCategory.visibleCases) { category in
                SidebarButton(
                    title: category.title,
                    icon: category.icon,
                    isSelected: selectedCategory == category,
                    amount: category.needsHomeFolderPermission && !cleaner.hasHomeFolderAccess
                        ? L(.sidebarStatusChooseFolder)
                        : (cleaner.scans[category] ?? .empty).totalSize.formattedSize,
                    tint: category.tint
                ) {
                    selectedCategory = category
                    isShowingSystemData = false
                }
                .padding(.horizontal, 10)
            }

            Text(DistributionMode.isAppStore ? L(.sidebarSectionFolderInspect) : L(.sidebarSectionSystemData))
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.tertiary)
                .padding(.top, 24)
                .padding(.horizontal, 20)

            SidebarButton(
                title: L(.sidebarDetailedInspect),
                icon: "magnifyingglass.circle.fill",
                isSelected: isShowingSystemData,
                amount: cleaner.isInspectingSystemData
                    ? L(.sidebarStatusScanning)
                    : systemDataStatus,
                tint: .indigo
            ) {
                selectedCategory = nil
                isShowingSystemData = true
                cleaner.scanSystemData()
            }
            .padding(.horizontal, 10)

            Spacer()
            sidebarPrivacyCard
        }
        .frame(width: 278)
        .background {
            CrystalSidebarBackground()
        }
        .overlay(alignment: .trailing) {
            LinearGradient(
                colors: [.white.opacity(0.18), .white.opacity(0.02), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: 1)
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        if isShowingSystemData {
            SystemDataInspectorView()
                .environmentObject(langManager)
        } else if let category = selectedCategory {
            categoryDetail(category)
        } else {
            overview
        }
    }

    private var systemDataTotal: Int64 {
        cleaner.systemStorageAreas.reduce(0) { partial, area in
            partial + area.totalSize
        }
    }

    private var systemDataStatus: String {
        if DistributionMode.isAppStore && cleaner.systemDataFolderName == nil {
            return L(.sidebarStatusChooseFolder)
        }
        if !DistributionMode.isAppStore && !cleaner.hasFullDiskAccess {
            return L(.sidebarStatusSetAccess)
        }
        return cleaner.systemStorageAreas.isEmpty ? L(.sidebarStatusInspect) : systemDataTotal.formattedSize
    }

    @ViewBuilder
    private var sidebarPrivacyCard: some View {
        VStack(alignment: .leading, spacing: 7) {
            if DistributionMode.isAppStore {
                Label(L(.privacyCardAppStoreTitle), systemImage: "lock.shield.fill")
                Text(cleaner.hasHomeFolderAccess
                    ? L(.privacyCardHomeFolderSaved)
                    : L(.privacyCardHomeFolderRequired))
                Button(cleaner.hasHomeFolderAccess ? L(.privacyCardChangeHomeFolder) : L(.privacyCardSelectHomeFolder)) {
                    cleaner.chooseHomeFolder()
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)
            } else {
                Label(L(.privacyCardDirectTitle), systemImage: "lock.shield.fill")
                Text(cleaner.hasFullDiskAccess
                    ? L(.privacyCardFullDiskEnabled)
                    : L(.privacyCardFullDiskRequired))
                if !cleaner.hasFullDiskAccess {
                    Button(L(.privacyCardSetAccess)) {
                        cleaner.showFullDiskAccessSetup = true
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)
                }
            }
            Button(L(.privacyCardPrivacy)) {
                cleaner.showPrivacyPolicy = true
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)

            Button(L(.sidebarChangeLanguage)) {
                showLanguagePicker = true
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(15)
        .crystalSurface(cornerRadius: 16)
        .padding(14)
    }

    private var sidebarLanguageSwitcher: some View { EmptyView() }

    private var overview: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header(title: L(.overviewTitle), subtitle: L(.overviewSubtitle))

                if let diskUsage = cleaner.diskUsage {
                    StorageStatusCard(usage: diskUsage)
                }

                HStack(spacing: 14) {
                    MetricCard(
                        title: L(.overviewMetricFound),
                        value: cleaner.totalFound.formattedSize,
                        icon: "internaldrive.fill",
                        color: .accentColor
                    )
                    MetricCard(
                        title: L(.overviewMetricSelected),
                        value: cleaner.selectedSize.formattedSize,
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                    MetricCard(
                        title: L(.overviewMetricSafeMode),
                        value: L(.overviewMetricSafeModeValue),
                        icon: "lock.shield.fill",
                        color: .green
                    )
                }

                if !cleaner.hasHomeFolderAccess {
                    HomeFolderAccessRequiredView {
                        cleaner.showHomeFolderSetup = true
                    }
                } else if cleaner.isScanning {
                    scanningCard
                } else {
                    Text(L(.overviewCleanupSummary))
                        .font(.title3.weight(.semibold))
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        ForEach(CleanupCategory.visibleCases) { category in
                            CategoryCard(category: category, scan: cleaner.scans[category] ?? .empty) {
                                selectedCategory = category
                            }
                        }
                    }
                }

                systemDataNote

                if let outcome = cleaner.lastOutcome {
                    OutcomeCard(outcome: outcome)
                }
            }
            .padding(32)
        }
        .safeAreaInset(edge: .bottom) { actionBar }
    }

    private func categoryDetail(_ category: CleanupCategory) -> some View {
        let scan = cleaner.scans[category] ?? .empty
        return VStack(spacing: 0) {
            header(title: category.title, subtitle: category.subtitle)
                .padding(.horizontal, 34)
                .padding(.top, 34)

            HStack {
                Button {
                    cleaner.toggleCategory(category)
                } label: {
                    let allSelected = !scan.items.isEmpty && Set(scan.items.map(\.id)).isSubset(of: cleaner.selectedItemIDs)
                    Label(
                        allSelected ? L(.categoryDeselectAll) : L(.categorySelectAll),
                        systemImage: allSelected ? "minus.circle" : "checkmark.circle"
                    )
                }
                .buttonStyle(.bordered)
                Spacer()
                Text(String(format: L(.categoryItemCount), scan.items.count, scan.totalSize.formattedSize))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 34)
            .padding(.top, 22)
            .padding(.bottom, 12)

            if category.needsHomeFolderPermission && !cleaner.hasHomeFolderAccess {
                HomeFolderAccessRequiredView {
                    cleaner.showHomeFolderSetup = true
                }
                Spacer()
            } else if cleaner.isScanning {
                scanningCard
                    .padding(34)
                Spacer()
            } else if scan.items.isEmpty {
                ContentUnavailableView(
                    L(.categoryEmpty),
                    systemImage: "checkmark.circle",
                    description: Text(L(.categoryEmptyDescription)))
                Spacer()
            } else {
                List(scan.items) { item in
                    ItemRow(
                        item: item,
                        isSelected: cleaner.selectedItemIDs.contains(item.id),
                        toggleSelection: { cleaner.toggle(item) },
                        openFolder: item.isDirectory ? { browsedFolder = item } : nil
                    )
                }
                .listStyle(.inset)
            }
        }
        .safeAreaInset(edge: .bottom) { actionBar }
    }

    private func header(title: String, subtitle: String) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 7) {
                Text(title)
                    .font(.system(size: 32, weight: .bold))
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if cleaner.isScanning {
                HStack(spacing: 7) {
                    ProgressView()
                        .controlSize(.small)
                    Text(L(.categoryUpdating))
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 11)
                .padding(.vertical, 8)
                .background(.quaternary, in: Capsule())
            }
            Button {
                cleaner.scan()
            } label: {
                Label(
                    cleaner.isScanning ? L(.categoryRescanInProgress) : L(.categoryRescan),
                    systemImage: "arrow.clockwise"
                )
            }
            .disabled(cleaner.isScanning || cleaner.isCleaning)
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
    }

    private var scanningCard: some View {
        HStack(spacing: 14) {
            ProgressView()
                .controlSize(.small)
            VStack(alignment: .leading, spacing: 2) {
                Text(L(.scanningCardTitle))
                    .font(.headline)
                Text(L(.scanningCardSubtitle))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(17)
        .macSurface(cornerRadius: 16)
    }

    private var systemDataNote: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(.blue)
                .font(.title3)
            VStack(alignment: .leading, spacing: 5) {
                Text(L(.systemDataNoteTitle))
                    .font(.headline)
                Text(DistributionMode.isAppStore
                    ? L(.systemDataNoteBodyAppStore)
                    : L(.systemDataNoteBodyDirect))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .background(Color.blue.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.blue.opacity(0.16))
        }
    }

    private var actionBar: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text(String(format: L(.actionBarItemsSelected), cleaner.selectedItems.count))
                    .font(.headline)
                Text(String(format: L(.actionBarWillProcess), cleaner.selectedSize.formattedSize))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if cleaner.isCleaning {
                ProgressView()
                Text(L(.actionBarCleaning))
                    .foregroundStyle(.secondary)
            } else {
                Button {
                    cleaner.beginCleanup()
                } label: {
                    Label(L(.actionBarClean), systemImage: "sparkles")
                        .frame(minWidth: 108)
                }
                .buttonStyle(.borderedProminent)
                .disabled(cleaner.selectedItems.isEmpty || cleaner.isScanning)
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 15)
        .background(.regularMaterial)
        .overlay(alignment: .top) {
            Rectangle().fill(.separator.opacity(0.55)).frame(height: 1)
        }
    }
}

// MARK: - System Data Inspector

private struct SystemDataInspectorView: View {
    @EnvironmentObject private var cleaner: CleanerViewModel
    @EnvironmentObject private var langManager: LanguageManager
    @State private var selectedItem: SystemStorageItem?

    private var knownTotal: Int64 {
        cleaner.systemStorageAreas.reduce(0) { $0 + $1.totalSize }
    }

    private var highlights: [SystemStorageItem] {
        cleaner.systemStorageAreas
            .flatMap(\.items)
            .filter {
                let path = $0.url.path.lowercased()
                return path.contains("whatsapp")
                    || path.contains("/kiro")
                    || path.contains("coresimulator")
                    || path.contains("com.docker.docker")
                    || path.contains("com.netease.mumu")
            }
            .sorted { $0.size > $1.size }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(DistributionMode.isAppStore ? L(.inspectorTitleAppStore) : L(.inspectorTitleDirect))
                            .font(.system(size: 30, weight: .bold))
                        Text(DistributionMode.isAppStore
                            ? L(.inspectorSubtitleAppStore)
                            : L(.inspectorSubtitleDirect))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {
                        if DistributionMode.isAppStore && cleaner.systemDataFolderName == nil {
                            cleaner.chooseSystemDataFolder()
                        } else {
                            cleaner.scanSystemData()
                        }
                    } label: {
                        Label(
                            cleaner.isInspectingSystemData ? L(.sidebarStatusScanning) : inspectorButtonTitle,
                            systemImage: inspectorButtonIcon
                        )
                    }
                    .buttonStyle(.bordered)
                    .disabled(cleaner.isInspectingSystemData)
                }

                if DistributionMode.isAppStore && cleaner.systemDataFolderName == nil {
                    SystemDataFolderRequiredView {
                        cleaner.chooseSystemDataFolder()
                    }
                } else if !DistributionMode.isAppStore && !cleaner.hasFullDiskAccess {
                    FullDiskAccessRequiredView {
                        cleaner.showFullDiskAccessSetup = true
                    }
                } else if cleaner.isInspectingSystemData && cleaner.systemStorageAreas.isEmpty {
                    SystemDataScanningCard()
                } else if cleaner.systemStorageAreas.isEmpty {
                    ContentUnavailableView(
                        L(.inspectorNotStartedTitle),
                        systemImage: "magnifyingglass",
                        description: Text(L(.inspectorNotStartedDescription)))
                } else {
                    SystemDataSummaryCard(total: knownTotal)

                    if !highlights.isEmpty {
                        SystemDataHighlightsCard(items: highlights) { item in
                            selectedItem = item
                        }
                    }

                    ForEach(cleaner.systemStorageAreas) { area in
                        SystemStorageAreaCard(area: area) { item in
                            selectedItem = item
                        }
                    }
                }
            }
            .padding(34)
        }
        .sheet(item: $selectedItem) { item in
            if item.url.path.lowercased().contains("whatsapp") {
                WhatsAppStorageSheet(rootURL: item.url) {
                    cleaner.scanSystemData()
                }
                .environmentObject(langManager)
            } else {
                SystemStorageBrowserSheet(root: item) {
                    cleaner.scanSystemData()
                    cleaner.scan()
                }
                .environmentObject(langManager)
            }
        }
        .id(langManager.language)
    }

    private var inspectorButtonTitle: String {
        if DistributionMode.isAppStore && cleaner.systemDataFolderName == nil { return L(.inspectorChooseFolderButton) }
        if !DistributionMode.isAppStore && !cleaner.hasFullDiskAccess { return L(.inspectorSetAccess) }
        return L(.inspectorRescanButton)
    }

    private var inspectorButtonIcon: String {
        DistributionMode.isAppStore && cleaner.systemDataFolderName == nil
            ? "folder.badge.plus"
            : (!DistributionMode.isAppStore && !cleaner.hasFullDiskAccess ? "lock.shield" : "arrow.clockwise")
    }
}

private struct SystemDataHighlightsCard: View {
    let items: [SystemStorageItem]
    let selectItem: (SystemStorageItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                VStack(alignment: .leading, spacing: 2) {
                    Text(L(.inspectorHighlightsTitle))
                        .font(.headline)
                    Text(L(.inspectorHighlightsSubtitle))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(17)

            Divider()

            ForEach(items) { item in
                Button {
                    selectItem(item)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "externaldrive.fill")
                            .foregroundStyle(.orange)
                            .frame(width: 20)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.title)
                                .font(.subheadline.weight(.semibold))
                            Text(item.summary)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 3) {
                            Text(item.size.formattedSize)
                                .font(.subheadline.weight(.bold).monospacedDigit())
                            Text(item.action.title)
                                .font(.caption2)
                                .foregroundStyle(.orange)
                        }
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.horizontal, 17)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                if item.id != items.last?.id { Divider().padding(.leading, 17) }
            }
        }
        .macSurface(cornerRadius: 18, accent: .orange)
    }
}

private struct SystemDataScanningCard: View {
    var body: some View {
        HStack(spacing: 14) {
            ProgressView()
            VStack(alignment: .leading, spacing: 3) {
                Text(L(.inspectorScanningTitle))
                    .font(.headline)
                Text(L(.inspectorScanningSubtitle))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(20)
        .macSurface(cornerRadius: 18, accent: .indigo)
    }
}

private struct SystemDataSummaryCard: View {
    let total: Int64

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: "externaldrive.fill")
                .font(.title2)
                .foregroundStyle(.indigo)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 5) {
                Text(String(format: L(.inspectorSummaryTitle), total.formattedSize))
                    .font(.title3.weight(.bold))
                Text(L(.inspectorSummaryBody))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(20)
        .macSurface(cornerRadius: 18, accent: .indigo)
    }
}

private struct SystemStorageAreaCard: View {
    let area: SystemStorageArea
    let selectItem: (SystemStorageItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 11) {
                Image(systemName: area.icon)
                    .foregroundStyle(.indigo)
                    .font(.title3)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text(area.title)
                        .font(.headline)
                    Text(area.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(area.totalSize.formattedSize)
                    .font(.headline.monospacedDigit())
            }
            .padding(17)

            Divider()

            ForEach(area.items) { item in
                Button {
                    selectItem(item)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: item.isDirectory ? "folder.fill" : "doc.fill")
                            .foregroundStyle(itemTint(for: item.action))
                            .frame(width: 18)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.title)
                                .font(.subheadline.weight(.semibold))
                            Text(item.summary)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 3) {
                            Text(item.size.formattedSize)
                                .font(.subheadline.weight(.semibold).monospacedDigit())
                            Text(item.action.title)
                                .font(.caption2)
                                .foregroundStyle(itemTint(for: item.action))
                        }
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.horizontal, 17)
                    .padding(.vertical, 11)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                if item.id != area.items.last?.id { Divider().padding(.leading, 17) }
            }
        }
        .macSurface(cornerRadius: 18)
    }

    private func itemTint(for action: StorageAction) -> Color {
        switch action {
        case .manageInApp:    return .blue
        case .manageInXcode:  return .orange
        case .manageInDocker: return .cyan
        case .removeIfUnused: return .red
        case .inspectFirst:   return .secondary
        }
    }
}

// MARK: - WhatsApp Sheet

private struct WhatsAppStorageSheet: View {
    let rootURL: URL
    let onMutation: () -> Void
    @EnvironmentObject private var langManager: LanguageManager
    @Environment(\.dismiss) private var dismiss
    @State private var chats: [WhatsAppChatUsage] = []
    @State private var isLoading = true
    @State private var selectedChat: WhatsAppChatUsage?

    private var totalSize: Int64 {
        chats.reduce(0) { $0 + $1.size }
    }

    var body: some View {
        if let selectedChat {
            WhatsAppChatMediaRemovalSheet(
                chat: selectedChat,
                onBack: { self.selectedChat = nil }
            ) {
                self.selectedChat = nil
                loadChats()
                onMutation()
            }
            .environmentObject(langManager)
        } else {
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: "message.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
                        .frame(width: 42, height: 42)
                        .background(Color.green.opacity(0.13), in: Circle())
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L(.whatsappSheetTitle))
                            .font(.title2.weight(.bold))
                        Text(L(.whatsappSheetSubtitle))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if !isLoading {
                        Text(totalSize.formattedSize)
                            .font(.title3.weight(.bold).monospacedDigit())
                    }
                }
                .padding(24)

                HStack(spacing: 10) {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.secondary)
                    Text(L(.whatsappSheetPrivacyNote))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 13)
                .background(.quaternary.opacity(0.6))

                if isLoading {
                    Spacer()
                    ProgressView(L(.whatsappSheetLoading))
                    Spacer()
                } else if chats.isEmpty {
                    Spacer()
                    ContentUnavailableView(
                        L(.whatsappSheetEmptyTitle),
                        systemImage: "message",
                        description: Text(L(.whatsappSheetEmptyDescription)))
                    Spacer()
                } else {
                    List(chats) { chat in
                        HStack(spacing: 12) {
                            Image(systemName: chat.kind.icon)
                                .font(.subheadline)
                                .foregroundStyle(.green)
                                .frame(width: 32, height: 32)
                                .background(Color.green.opacity(0.12), in: Circle())
                            VStack(alignment: .leading, spacing: 3) {
                                Text(chat.displayName)
                                    .font(.body.weight(.semibold))
                                    .lineLimit(1)
                                Text(String(format: L(.whatsappSheetChatSubtitle), chat.kind.title, chat.mediaCount))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(chat.chatID)
                                    .font(.caption2.monospaced())
                                    .foregroundStyle(.tertiary)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Text(chat.size.formattedSize)
                                .font(.body.weight(.bold).monospacedDigit())
                            Button(L(.whatsappSheetManage)) {
                                selectedChat = chat
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                        .padding(.vertical, 7)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedChat = chat
                        }
                    }
                    .listStyle(.inset)
                }

                Divider()
                HStack {
                    if !isLoading {
                        Text(String(format: L(.whatsappSheetChatCount), chats.count))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(L(.whatsappSheetClose)) { dismiss() }
                        .buttonStyle(.bordered)
                }
                .padding(18)
            }
            .frame(width: 760, height: 700)
            .onAppear(perform: loadChats)
            .id(langManager.language)
        }
    }

    private func loadChats() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            let result = WhatsAppStorageScanner.scan(rootURL: rootURL)
            DispatchQueue.main.async {
                chats = result
                isLoading = false
            }
        }
    }
}

private struct WhatsAppChatMediaRemovalSheet: View {
    let chat: WhatsAppChatUsage
    let onBack: () -> Void
    let onRemoval: () -> Void
    @EnvironmentObject private var langManager: LanguageManager
    @State private var showConfirmation = false
    @State private var isRemoving = false
    @State private var resultMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 13) {
                Image(systemName: chat.kind.icon)
                    .font(.title2)
                    .foregroundStyle(.green)
                    .frame(width: 44, height: 44)
                    .background(Color.green.opacity(0.13), in: Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text(chat.displayName)
                        .font(.title2.weight(.bold))
                    Text(String(format: L(.whatsappRemovalMediaCount), chat.mediaCount))
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 12) {
                Label(chat.size.formattedSize, systemImage: "internaldrive.fill")
                    .font(.title3.weight(.bold).monospacedDigit())
                Text(L(.whatsappRemovalVerified))
                    .foregroundStyle(.secondary)
            }
            .padding(15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.green.opacity(0.09), in: RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 8) {
                Label(L(.whatsappRemovalLabel1), systemImage: "checkmark.shield.fill")
                Label(L(.whatsappRemovalLabel2), systemImage: "exclamationmark.triangle.fill")
                Label(L(.whatsappRemovalLabel3), systemImage: "trash.fill")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(16)
            .background(.quaternary.opacity(0.6), in: RoundedRectangle(cornerRadius: 14))

            HStack {
                Button(L(.whatsappRemovalBack), systemImage: "chevron.left", action: onBack)
                    .buttonStyle(.bordered)
                Spacer()
                Button(role: .destructive) {
                    showConfirmation = true
                } label: {
                    if isRemoving {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Label(L(.whatsappRemovalConfirmButton), systemImage: "trash")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isRemoving)
            }
        }
        .padding(28)
        .frame(width: 610)
        .alert(L(.whatsappRemovalAlertTitle), isPresented: $showConfirmation) {
            Button(L(.whatsappRemovalAlertCancel), role: .cancel) { }
            Button(L(.whatsappRemovalAlertConfirm), role: .destructive) {
                removeMedia()
            }
        } message: {
            Text(String(format: L(.whatsappRemovalAlertMessage), chat.mediaCount, chat.size.formattedSize))
        }
        .alert(L(.whatsappRemovalResultTitle), isPresented: Binding(
            get: { resultMessage != nil },
            set: { if !$0 { resultMessage = nil } }
        )) {
            Button(L(.errorAlertOk)) {
                if resultMessage?.hasPrefix(successPrefix) == true {
                    onRemoval()
                }
                resultMessage = nil
            }
        } message: {
            Text(resultMessage ?? "")
        }
        .id(langManager.language)
    }

    private var successPrefix: String {
        // Match the beginning of the success result message regardless of language
        switch langManager.language {
        case .turkish: return "Çöp Kutusu'na taşındı"
        case .english: return "Moved to Trash"
        case .russian: return "Перемещено в Корзину"
        }
    }

    private func removeMedia() {
        isRemoving = true
        let target = chat.mediaFolderURL
        let count = chat.mediaCount
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                _ = try FileManager.default.trashItem(at: target, resultingItemURL: nil)
                DispatchQueue.main.async {
                    isRemoving = false
                    resultMessage = String(format: L(.whatsappRemovalResultSuccess), count)
                }
            } catch {
                DispatchQueue.main.async {
                    isRemoving = false
                    resultMessage = String(format: L(.whatsappRemovalResultFailure), error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - Cleanup Folder Browser Sheet

private struct CleanupFolderBrowserSheet: View {
    let folder: CleanupItem
    let onMutation: () -> Void
    @EnvironmentObject private var langManager: LanguageManager
    @Environment(\.dismiss) private var dismiss
    @State private var history: [CleanupItem] = []
    @State private var contents: [CleanupItem] = []
    @State private var selectedIDs: Set<String> = []
    @State private var isLoading = true
    @State private var isRemoving = false
    @State private var showRemovalConfirmation = false
    @State private var removalMessage: String?

    private var currentFolder: CleanupItem { history.last ?? folder }
    private var selectedItems: [CleanupItem] { contents.filter { selectedIDs.contains($0.id) } }
    private var selectedSize: Int64 { selectedItems.reduce(0) { $0 + $1.size } }
    private var movesToTrash: Bool { folder.deletionMode == .moveToTrash }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "folder.fill")
                    .font(.title2)
                    .foregroundStyle(folder.category.tint)
                    .frame(width: 42, height: 42)
                    .background(folder.category.tint.opacity(0.13), in: Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text(currentFolder.name)
                        .font(.title2.weight(.bold))
                        .lineLimit(1)
                    Text(currentFolder.path)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                if !history.isEmpty {
                    Button(L(.folderBrowserGoUp), systemImage: "chevron.left") {
                        history.removeLast()
                        selectedIDs.removeAll()
                        loadContents()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(24)

            HStack {
                Button {
                    toggleAll()
                } label: {
                    let allSelected = !contents.isEmpty && contents.allSatisfy { selectedIDs.contains($0.id) }
                    Label(
                        allSelected ? L(.folderBrowserDeselectAll) : L(.folderBrowserSelectAll),
                        systemImage: allSelected ? "minus.circle" : "checkmark.circle"
                    )
                }
                .buttonStyle(.bordered)
                Spacer()
                Text(String(format: L(.folderBrowserItemCount),
                            contents.count,
                            contents.reduce(0) { $0 + $1.size }.formattedSize))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 12)

            if isLoading {
                Spacer()
                ProgressView(L(.folderBrowserLoading))
                Spacer()
            } else if contents.isEmpty {
                Spacer()
                ContentUnavailableView(L(.folderBrowserEmpty), systemImage: "folder")
                Spacer()
            } else {
                List(contents) { item in
                    FolderContentRow(
                        item: item,
                        isSelected: selectedIDs.contains(item.id),
                        toggleSelection: { toggle(item) },
                        openFolder: item.isDirectory ? {
                            history.append(item)
                            selectedIDs.removeAll()
                            loadContents()
                        } : nil
                    )
                }
                .listStyle(.inset)
            }

            Divider()
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(format: L(.folderBrowserSelectedCount), selectedItems.count))
                        .font(.headline)
                    Text(String(format: movesToTrash
                                ? L(.folderBrowserWillTrash)
                                : L(.folderBrowserWillDelete),
                                selectedSize.formattedSize))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(L(.folderBrowserClose)) { dismiss() }
                    .buttonStyle(.bordered)
                Button(role: .destructive) {
                    showRemovalConfirmation = true
                } label: {
                    if isRemoving {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Label(movesToTrash ? L(.folderBrowserMoveToTrash) : L(.folderBrowserRemove),
                              systemImage: "trash")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedItems.isEmpty || isRemoving)
            }
            .padding(18)
        }
        .frame(width: 780, height: 700)
        .onAppear(perform: loadContents)
        .alert(movesToTrash ? L(.folderBrowserAlertTrashTitle) : L(.folderBrowserAlertDeleteTitle),
               isPresented: $showRemovalConfirmation) {
            Button(L(.folderBrowserAlertCancel), role: .cancel) { }
            Button(movesToTrash ? L(.folderBrowserAlertConfirmTrash) : L(.folderBrowserAlertConfirmDelete),
                   role: .destructive) {
                removeSelectedItems()
            }
        } message: {
            Text(movesToTrash
                ? String(format: L(.folderBrowserAlertTrashMessage), selectedItems.count, selectedSize.formattedSize)
                : String(format: L(.folderBrowserAlertDeleteMessage), selectedItems.count, selectedSize.formattedSize))
        }
        .alert(L(.folderBrowserResultTitle), isPresented: Binding(
            get: { removalMessage != nil },
            set: { if !$0 { removalMessage = nil } }
        )) {
            Button(L(.errorAlertOk)) { removalMessage = nil }
        } message: {
            Text(removalMessage ?? "")
        }
        .id(langManager.language)
    }

    private func loadContents() {
        let target = currentFolder
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            let result = DiskScanner.children(in: target.url, category: folder.category)
                .sorted { $0.size > $1.size }
            DispatchQueue.main.async {
                guard currentFolder.id == target.id else { return }
                contents = result
                isLoading = false
            }
        }
    }

    private func toggle(_ item: CleanupItem) {
        if selectedIDs.contains(item.id) { selectedIDs.remove(item.id) }
        else { selectedIDs.insert(item.id) }
    }

    private func toggleAll() {
        let ids = Set(contents.map(\.id))
        if ids.isSubset(of: selectedIDs) { selectedIDs.subtract(ids) }
        else { selectedIDs.formUnion(ids) }
    }

    private func removeSelectedItems() {
        let targets = selectedItems
        let shouldMoveToTrash = movesToTrash
        isRemoving = true
        DispatchQueue.global(qos: .userInitiated).async {
            let manager = FileManager.default
            var successes = 0
            var failures: [String] = []
            for item in targets {
                do {
                    if shouldMoveToTrash {
                        _ = try manager.trashItem(at: item.url, resultingItemURL: nil)
                    } else {
                        try manager.removeItem(at: item.url)
                    }
                    successes += 1
                } catch {
                    failures.append("\(item.name): \(error.localizedDescription)")
                }
            }
            DispatchQueue.main.async {
                selectedIDs.removeAll()
                isRemoving = false
                loadContents()
                onMutation()
                if failures.isEmpty {
                    removalMessage = shouldMoveToTrash
                        ? String(format: L(.folderBrowserResultSuccessTrash), successes)
                        : String(format: L(.folderBrowserResultSuccessDelete), successes)
                } else {
                    removalMessage = String(format: L(.folderBrowserResultPartial), successes, failures.count)
                }
            }
        }
    }
}

private struct FolderContentRow: View {
    let item: CleanupItem
    let isSelected: Bool
    let toggleSelection: () -> Void
    let openFolder: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            Button(action: toggleSelection) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.accentColor : .secondary)
            }
            .buttonStyle(.plain)
            Button {
                if let openFolder { openFolder() }
                else { toggleSelection() }
            } label: {
                HStack(spacing: 11) {
                    Image(systemName: item.isDirectory ? "folder.fill" : "doc.fill")
                        .foregroundStyle(item.category.tint)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.name)
                            .font(.body.weight(.medium))
                            .lineLimit(1)
                        if item.isDirectory {
                            Text(L(.folderBrowserContentRow))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else if let date = item.modifiedAt {
                            Text(date.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    Text(item.size.formattedSize)
                        .font(.body.weight(.semibold).monospacedDigit())
                    if item.isDirectory {
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.tertiary)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 5)
    }
}

// MARK: - System Storage Browser Sheet

private struct SystemStorageBrowserSheet: View {
    let root: SystemStorageItem
    let onRemoval: () -> Void
    @EnvironmentObject private var langManager: LanguageManager
    @Environment(\.dismiss) private var dismiss
    @State private var history: [SystemStorageItem] = []
    @State private var items: [SystemStorageItem] = []
    @State private var isLoading = true
    @State private var isRemoving = false
    @State private var showRemovalConfirmation = false
    @State private var removalMessage: String?

    private var currentFolder: SystemStorageItem { history.last ?? root }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 13) {
                Image(systemName: currentFolder.isDirectory ? "folder.fill" : "doc.fill")
                    .font(.title2)
                    .foregroundStyle(.indigo)
                VStack(alignment: .leading, spacing: 4) {
                    Text(currentFolder.title)
                        .font(.title2.weight(.bold))
                    Text(currentFolder.path)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                Text(currentFolder.size.formattedSize)
                    .font(.title3.weight(.bold).monospacedDigit())
            }
            .padding(24)

            VStack(alignment: .leading, spacing: 6) {
                Label(currentFolder.action.title, systemImage: "shield.lefthalf.filled")
                    .font(.subheadline.weight(.semibold))
                Text(currentFolder.action.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(15)
            .background(.quaternary.opacity(0.6))

            if !history.isEmpty {
                HStack {
                    Button {
                        history.removeLast()
                        loadContents()
                    } label: {
                        Label(L(.storageBrowserGoUp), systemImage: "chevron.left")
                    }
                    .buttonStyle(.bordered)
                    Spacer()
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 12)
            }

            if isLoading {
                Spacer()
                ProgressView(L(.storageBrowserLoading))
                Spacer()
            } else if items.isEmpty {
                Spacer()
                ContentUnavailableView(L(.storageBrowserEmpty), systemImage: "folder")
                Spacer()
            } else {
                List(items) { item in
                    Button {
                        guard item.isDirectory else { return }
                        history.append(item)
                        loadContents()
                    } label: {
                        HStack(spacing: 11) {
                            Image(systemName: item.isDirectory ? "folder.fill" : "doc.fill")
                                .foregroundStyle(.indigo)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.title)
                                    .font(.body.weight(.medium))
                                Text(item.path)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Text(item.size.formattedSize)
                                .font(.body.weight(.semibold).monospacedDigit())
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(!item.isDirectory)
                }
                .listStyle(.inset)
            }

            Divider()
            HStack {
                Button(role: .destructive) {
                    showRemovalConfirmation = true
                } label: {
                    if isRemoving {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Label(L(.storageBrowserRemove), systemImage: "trash")
                    }
                }
                .buttonStyle(.bordered)
                .disabled(isRemoving)
                Spacer()
                Button(L(.storageBrowserClose)) { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding(18)
        }
        .frame(width: 760, height: 700)
        .onAppear(perform: loadContents)
        .alert(L(.storageBrowserAlertTitle), isPresented: $showRemovalConfirmation) {
            Button(L(.storageBrowserAlertCancel), role: .cancel) { }
            Button(L(.storageBrowserAlertConfirm), role: .destructive) {
                removeCurrentFolder()
            }
        } message: {
            Text(String(format: L(.storageBrowserAlertMessage),
                        currentFolder.title, currentFolder.size.formattedSize))
        }
        .alert(L(.storageBrowserResultTitle), isPresented: Binding(
            get: { removalMessage != nil },
            set: { if !$0 { removalMessage = nil } }
        )) {
            Button(L(.errorAlertOk)) {
                if removalMessage?.hasPrefix(successPrefix) == true {
                    onRemoval()
                    dismiss()
                }
                removalMessage = nil
            }
        } message: {
            Text(removalMessage ?? "")
        }
        .id(langManager.language)
    }

    private var successPrefix: String {
        switch langManager.language {
        case .turkish: return "Çöp Kutusu'na taşındı"
        case .english: return "Moved to Trash"
        case .russian: return "Перемещено в Корзину"
        }
    }

    private func loadContents() {
        let folder = currentFolder
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            let contents = SystemDataScanner.children(in: folder.url)
            DispatchQueue.main.async {
                guard currentFolder.id == folder.id else { return }
                items = contents
                isLoading = false
            }
        }
    }

    private func removeCurrentFolder() {
        let target = currentFolder
        isRemoving = true
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                _ = try FileManager.default.trashItem(at: target.url, resultingItemURL: nil)
                DispatchQueue.main.async {
                    isRemoving = false
                    removalMessage = String(format: L(.storageBrowserResultSuccess), target.title)
                }
            } catch {
                DispatchQueue.main.async {
                    isRemoving = false
                    removalMessage = String(format: L(.storageBrowserResultFailure), error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - App Logo

private struct AppLogo: View {
    let size: CGFloat
    let cornerRadius: CGFloat

    var body: some View {
        Group {
            if let image = AppIconLoader.image {
                Image(nsImage: image)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFill()
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(LinearGradient(
                            colors: [.cyan, .blue, .indigo],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                    Image(systemName: "sparkles")
                        .font(.system(size: size * 0.39, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(.white.opacity(0.38), lineWidth: 0.8)
        }
        .shadow(color: .black.opacity(0.25), radius: 6, y: 3)
    }
}

private enum AppIconLoader {
    static let image: NSImage? = {
        let candidates = [
            Bundle.main.url(forResource: "AppIcon", withExtension: "png"),
            Bundle.main.url(forResource: "MacClean", withExtension: "icns")
        ]
        return candidates
            .compactMap { $0 }
            .lazy
            .compactMap { NSImage(contentsOf: $0) }
            .first
    }()
}

// MARK: - Background / Surface styles

private struct CrystalSidebarBackground: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
            LinearGradient(
                colors: [
                    Color.white.opacity(0.15),
                    Color.blue.opacity(0.055),
                    Color.clear,
                    Color.indigo.opacity(0.07)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [Color.cyan.opacity(0.10), .clear],
                center: .topLeading,
                startRadius: 20,
                endRadius: 280
            )
            .blendMode(.screen)
        }
    }
}

private struct SidebarStorageStatus: View {
    let usage: DiskUsage

    var body: some View {
        HStack(spacing: 11) {
            DiskUsageRing(usage: usage, diameter: 36, lineWidth: 5, showsLabel: false)
            VStack(alignment: .leading, spacing: 2) {
                Text(String(format: L(.diskFreeSpace), usage.available.formattedSize))
                    .font(.subheadline.weight(.semibold))
                Text("Macintosh HD · %\(Int((usage.usedFraction * 100).rounded())) dolu")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(11)
        .crystalSurface(cornerRadius: 15)
    }
}

private struct DiskUsageRing: View {
    let usage: DiskUsage
    let diameter: CGFloat
    let lineWidth: CGFloat
    var showsLabel = true

    var body: some View {
        ZStack {
            Circle()
                .stroke(.quaternary, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0.012, usage.usedFraction))
                .stroke(color.gradient, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            if showsLabel {
                Text("%\(Int((usage.usedFraction * 100).rounded()))")
                    .font(.caption.weight(.bold).monospacedDigit())
            }
        }
        .frame(width: diameter, height: diameter)
        .accessibilityLabel(String(format: L(.diskAccessibilityRing), Int((usage.usedFraction * 100).rounded())))
    }

    private var color: Color {
        switch usage.usedFraction {
        case 0.92...: return .red
        case 0.80...: return .orange
        default:      return .green
        }
    }
}

private struct StorageStatusCard: View {
    let usage: DiskUsage

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 18) {
                DiskUsageRing(usage: usage, diameter: 70, lineWidth: 8)
                VStack(alignment: .leading, spacing: 5) {
                    Label("Macintosh HD", systemImage: "internaldrive.fill")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text(String(format: L(.diskOpenSpace), usage.available.formattedSize))
                        .font(.system(size: 28, weight: .bold))
                    Text(String(format: L(.diskUsedOf), usage.used.formattedSize, usage.total.formattedSize))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Label(
                    usage.available < 15 * 1_024 * 1_024 * 1_024 ? L(.diskFreeSpaceBadge) : "✓",
                    systemImage: usage.available < 15 * 1_024 * 1_024 * 1_024
                        ? "exclamationmark.triangle.fill" : "checkmark.circle.fill"
                )
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(storageColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(storageColor.opacity(0.12), in: Capsule())
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.quaternary)
                    Capsule()
                        .fill(storageColor.gradient)
                        .frame(width: max(7, proxy.size.width * usage.usedFraction))
                }
            }
            .frame(height: 12)

            Text(String(format: L(.diskUsagePercent), Int((usage.usedFraction * 100).rounded())))
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .padding(22)
        .macSurface(cornerRadius: 22, accent: storageColor)
    }

    private var storageColor: Color {
        switch usage.usedFraction {
        case 0.92...: return .red
        case 0.80...: return .orange
        default:      return .green
        }
    }
}

// MARK: - Cleanup Review Sheet

private struct CleanupReviewSheet: View {
    @EnvironmentObject private var cleaner: CleanerViewModel
    @EnvironmentObject private var langManager: LanguageManager
    @Environment(\.dismiss) private var dismiss

    private var selectedCategories: [CleanupCategory] {
        CleanupCategory.allCases.filter { !items(in: $0).isEmpty }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(.green)
                VStack(alignment: .leading, spacing: 5) {
                    Text(L(.reviewTitle))
                        .font(.title2.weight(.bold))
                    Text(L(.reviewSubtitle))
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(28)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(selectedCategories) { category in
                        categoryReview(for: category)
                    }
                    protectedDataCard
                }
                .padding(28)
            }

            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(format: L(.reviewItemCount), cleaner.selectedItems.count, cleaner.selectedSize.formattedSize))
                        .font(.headline)
                    if cleaner.selectedTrashSize > 0 {
                        Text(String(format: L(.reviewWillTrash), cleaner.selectedTrashSize.formattedSize))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(L(.reviewWillDelete))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Button(L(.reviewBack)) { dismiss() }
                    .buttonStyle(.bordered)
                Button(L(.reviewConfirm), role: .destructive) {
                    cleaner.cleanupSelected()
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
            .padding(22)
        }
        .frame(width: 700, height: 680)
        .id(langManager.language)
    }

    private func categoryReview(for category: CleanupCategory) -> some View {
        let selectedItems = items(in: category)
        return VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 11) {
                Image(systemName: category.icon)
                    .foregroundStyle(category.tint)
                    .font(.title3)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.title)
                        .font(.headline)
                    Text(String(format: L(.reviewItemCount),
                                selectedItems.count,
                                selectedItems.reduce(0) { $0 + $1.size }.formattedSize))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(category.deletionMode == .permanent ? L(.reviewBadgePermanent) : L(.reviewBadgeTrash))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(category.deletionMode == .permanent ? .orange : .blue)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(.quaternary, in: Capsule())
            }

            Text(category.reviewDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let note = category.protectedDataNote {
                Label(note, systemImage: "lock.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(11)
                    .background(.quaternary.opacity(0.55), in: RoundedRectangle(cornerRadius: 10))
            }

            if selectedItems.count <= 4 {
                ForEach(selectedItems) { item in
                    Label("\(item.name) — \(item.size.formattedSize)", systemImage: "folder")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            } else {
                ForEach(selectedItems.prefix(3)) { item in
                    Label("\(item.name) — \(item.size.formattedSize)", systemImage: "folder")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Text("+ \(selectedItems.count - 3)")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(17)
        .background(.quaternary.opacity(0.42), in: RoundedRectangle(cornerRadius: 15))
    }

    private var protectedDataCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "shield.lefthalf.filled")
                .foregroundStyle(.green)
                .font(.title3)
            VStack(alignment: .leading, spacing: 4) {
                Text(L(.reviewProtectedHeader))
                    .font(.headline)
                Text(L(.categoryDeveloperProtectedNote))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(Color.green.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
    }

    private func items(in category: CleanupCategory) -> [CleanupItem] {
        cleaner.selectedItems.filter { $0.category == category }
    }
}

// MARK: - Sidebar Button

private struct SidebarButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    var amount: String? = nil
    var tint: Color = .accentColor
    let action: () -> Void
    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .frame(width: 18)
                    .foregroundStyle(isSelected ? .white : tint)
                Text(title)
                    .lineLimit(1)
                Spacer(minLength: 4)
                if let amount {
                    Text(amount)
                        .font(.caption2)
                        .foregroundStyle(isSelected ? .white.opacity(0.85) : .secondary)
                }
            }
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, 12)
            .frame(height: 38)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(isSelected ? .white : .primary)
        .background {
            if isSelected {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(LinearGradient(
                            colors: [Color.blue.opacity(0.92), Color.cyan.opacity(0.70), Color.blue.opacity(0.82)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(LinearGradient(
                            colors: [.white.opacity(0.28), .clear, .white.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .blendMode(.screen)
                }
            } else {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isHovering ? Color.white.opacity(0.12) : Color.clear)
            }
        }
        .overlay {
            if isSelected {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(.white.opacity(0.28), lineWidth: 0.8)
            }
        }
        .shadow(color: isSelected ? Color.blue.opacity(0.25) : .clear, radius: 8, y: 3)
        .animation(.easeOut(duration: 0.16), value: isSelected)
        .animation(.easeOut(duration: 0.12), value: isHovering)
        .onHover { isHovering = $0 }
    }
}

// MARK: - View Modifiers

private extension View {
    func macSurface(cornerRadius: CGFloat, accent: Color? = nil) -> some View {
        background(.regularMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                if let accent {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(accent.opacity(0.28))
                } else {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(.separator.opacity(0.38))
                }
            }
            .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
    }

    func crystalSurface(cornerRadius: CGFloat) -> some View {
        background {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(LinearGradient(
                        colors: [.white.opacity(0.15), .white.opacity(0.025), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(.white.opacity(0.18), lineWidth: 0.8)
        }
        .shadow(color: .black.opacity(0.09), radius: 10, y: 4)
    }
}

// MARK: - Access Required Views

private struct FullDiskAccessRequiredView: View {
    let openSetup: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label(L(.fullDiskRequiredTitle), systemImage: "lock.shield.fill")
        } description: {
            Text(L(.fullDiskRequiredDescription))
        } actions: {
            Button(L(.fullDiskRequiredButton), action: openSetup)
                .buttonStyle(.borderedProminent)
        }
        .padding(34)
    }
}

private struct FullDiskAccessSetupSheet: View {
    @EnvironmentObject private var cleaner: CleanerViewModel
    @EnvironmentObject private var langManager: LanguageManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 34))
                .foregroundStyle(.blue)
            Text(L(.fullDiskSetupTitle))
                .font(.title2.weight(.bold))
            Text(L(.fullDiskRequiredDescription))
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 8) {
                Label(L(.fullDiskSetupStep1), systemImage: "1.circle.fill")
                Label(L(.fullDiskSetupStep2), systemImage: "2.circle.fill")
            }
            .font(.subheadline)
            .padding(15)
            .background(.quaternary.opacity(0.55), in: RoundedRectangle(cornerRadius: 13))
            HStack {
                Button(L(.fullDiskSetupCancel)) { dismiss() }
                    .buttonStyle(.bordered)
                Spacer()
                Button(L(.fullDiskSetupOpenSettings)) {
                    cleaner.openFullDiskAccessSettings()
                }
                .buttonStyle(.bordered)
                Button(L(.fullDiskSetupConfirm)) {
                    cleaner.confirmFullDiskAccess()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(28)
        .frame(width: 570)
        .id(langManager.language)
    }
}

private struct HomeFolderAccessRequiredView: View {
    let openSetup: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label(L(.homeFolderRequiredTitle), systemImage: "folder.badge.person.crop")
        } description: {
            Text(L(.homeFolderRequiredDescription))
        } actions: {
            Button(L(.homeFolderRequiredButton), action: openSetup)
                .buttonStyle(.borderedProminent)
        }
        .padding(34)
    }
}

private struct SystemDataFolderRequiredView: View {
    let chooseFolder: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label(L(.systemDataFolderRequiredTitle), systemImage: "folder.badge.magnifyingglass")
        } description: {
            Text(L(.systemDataFolderRequiredDescription))
        } actions: {
            Button(L(.systemDataFolderRequiredButton), action: chooseFolder)
                .buttonStyle(.borderedProminent)
        }
        .padding(34)
    }
}

private struct HomeFolderAccessSetupSheet: View {
    @EnvironmentObject private var cleaner: CleanerViewModel
    @EnvironmentObject private var langManager: LanguageManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 34))
                .foregroundStyle(.blue)
            Text(L(.homeFolderSetupTitle))
                .font(.title2.weight(.bold))
            Text(L(.homeFolderRequiredDescription))
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 8) {
                Label(L(.homeFolderSetupStep1), systemImage: "1.circle.fill")
                Label(L(.homeFolderSetupStep2), systemImage: "2.circle.fill")
            }
            .font(.subheadline)
            .padding(15)
            .background(.quaternary.opacity(0.55), in: RoundedRectangle(cornerRadius: 13))
            HStack {
                Button(L(.homeFolderSetupCancel)) { dismiss() }
                    .buttonStyle(.bordered)
                Spacer()
                Button(L(.homeFolderSetupConfirm)) {
                    cleaner.chooseHomeFolder()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(28)
        .frame(width: 560)
        .id(langManager.language)
    }
}

private struct PrivacyPolicySheet: View {
    @EnvironmentObject private var cleaner: CleanerViewModel
    @EnvironmentObject private var langManager: LanguageManager
    @Environment(\.dismiss) private var dismiss

    private let privacyPolicyURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    private let termsURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    private let contactURL = URL(string: "mailto:yusahmedia@gmail.com")!

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Image(systemName: "hand.raised.fill")
                .font(.system(size: 34))
                .foregroundStyle(.blue)
            Text(L(.privacyPolicyTitle))
                .font(.title2.weight(.bold))
            Text(L(.privacyPolicyBody))
            Text(DistributionMode.isAppStore
                ? L(.systemDataNoteBodyAppStore)
                : L(.systemDataNoteBodyDirect))
                .foregroundStyle(.secondary)
            Text(L(.privacyPolicyAdditionalNote))
                .foregroundStyle(.secondary)

            Divider()

            // Tappable links
            VStack(alignment: .leading, spacing: 10) {
                Link(destination: termsURL) {
                    Label(L(.privacyPolicyTermsLink), systemImage: "doc.text")
                        .font(.subheadline)
                }

                Link(destination: contactURL) {
                    Label(L(.privacyPolicyContact), systemImage: "envelope")
                        .font(.subheadline)
                }
            }

            HStack {
                Button(L(.privacyPolicyRevokeAccess), role: .destructive) {
                    cleaner.revokeFolderAccess()
                    dismiss()
                }
                .buttonStyle(.bordered)
                Spacer()
                Button(L(.privacyPolicyClose)) { dismiss() }
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(28)
        .frame(width: 560)
        .id(langManager.language)
    }
}

// MARK: - Language Picker Sheet

private struct LanguagePickerSheet: View {
    @EnvironmentObject private var langManager: LanguageManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 14) {
                Image(systemName: "globe")
                    .font(.system(size: 28))
                    .foregroundStyle(.blue)
                Text(L(.sidebarChangeLanguage))
                    .font(.title2.weight(.bold))
                Spacer()
            }
            .padding(28)
            .padding(.bottom, 4)

            Divider()

            VStack(spacing: 0) {
                ForEach(Language.allCases) { lang in
                    Button {
                        langManager.language = lang
                        dismiss()
                    } label: {
                        HStack(spacing: 16) {
                            Text(lang.flagEmoji)
                                .font(.system(size: 28))
                            VStack(alignment: .leading, spacing: 3) {
                                Text(lang.displayName)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(.primary)
                                Text(lang.shortName)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if langManager.language == lang {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.blue)
                                    .font(.title3)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundStyle(.secondary)
                                    .font(.title3)
                            }
                        }
                        .padding(.horizontal, 28)
                        .padding(.vertical, 16)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .background(
                        langManager.language == lang
                            ? Color.accentColor.opacity(0.07)
                            : Color.clear
                    )

                    if lang != Language.allCases.last {
                        Divider()
                            .padding(.leading, 28)
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .frame(width: 340)
        .id(langManager.language)
    }
}

// MARK: - Metric / Category / Item cards

private struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(color)
                .frame(width: 34, height: 34)
                .background(color.opacity(0.13), in: Circle())
            Text(value)
                .font(.title3.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .macSurface(cornerRadius: 18)
    }
}

private struct CategoryCard: View {
    let category: CleanupCategory
    let scan: CategoryScan
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 13) {
                Image(systemName: category.icon)
                    .font(.headline)
                    .foregroundStyle(category.tint)
                    .frame(width: 36, height: 36)
                    .background(category.tint.opacity(0.12), in: Circle())
                VStack(alignment: .leading, spacing: 3) {
                    Text(category.title)
                        .font(.headline)
                    Text(String(format: L(.categoryItemCount), scan.items.count, scan.totalSize.formattedSize))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(scan.totalSize.formattedSize)
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            .padding(17)
            .contentShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
        .macSurface(cornerRadius: 18)
    }
}

private struct ItemRow: View {
    let item: CleanupItem
    let isSelected: Bool
    let toggleSelection: () -> Void
    let openFolder: (() -> Void)?

    var body: some View {
        HStack(spacing: 13) {
            Button(action: toggleSelection) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.accentColor : .secondary)
                    .font(.title3)
            }
            .buttonStyle(.plain)
            Button {
                if let openFolder { openFolder() }
                else { toggleSelection() }
            } label: {
                HStack(spacing: 13) {
                    Image(systemName: item.isDirectory ? "folder.fill" : "doc.fill")
                        .foregroundStyle(item.category.tint)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.name)
                            .font(.body.weight(.medium))
                            .lineLimit(1)
                        Text(item.path)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 3) {
                        Text(item.size.formattedSize)
                            .font(.body.weight(.semibold).monospacedDigit())
                        if let date = item.modifiedAt {
                            Text(date.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    if item.isDirectory {
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.tertiary)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 5)
    }
}

private struct OutcomeCard: View {
    let outcome: CleanupOutcome

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: outcome.failures.isEmpty ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                .font(.title2)
                .foregroundStyle(outcome.failures.isEmpty ? .green : .orange)
            VStack(alignment: .leading, spacing: 4) {
                Text(outcome.totalProcessed > 0 ? L(.outcomeTitle) : L(.outcomeFailedTitle))
                    .font(.headline)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(18)
        .macSurface(cornerRadius: 17, accent: outcome.failures.isEmpty ? .green : .orange)
    }

    private var detail: String {
        var parts: [String] = []
        if outcome.permanentlyDeleted > 0 {
            parts.append(String(format: L(.outcomePermanentlyDeleted), outcome.permanentlyDeleted.formattedSize))
        }
        if outcome.movedToTrash > 0 {
            parts.append(String(format: L(.outcomeMovedToTrash), outcome.movedToTrash.formattedSize))
        }
        if !outcome.failures.isEmpty {
            parts.append(String(format: L(.outcomeFailedItems), outcome.failures.count))
        }
        return parts.joined(separator: " · ")
    }
}
