import Foundation

enum DistributionMode {
    #if APP_STORE
    static let isAppStore = true
    #else
    static let isAppStore = false
    #endif
}
