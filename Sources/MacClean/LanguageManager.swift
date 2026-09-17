import Foundation
import SwiftUI

// MARK: - LanguageManager

@MainActor
final class LanguageManager: ObservableObject {

    // Shared singleton — used by the free L() function in LocalizedStrings.swift
    static let shared = LanguageManager()

    @Published var language: Language {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: Self.languageKey)
            // Mirror into the nonisolated store so L() can read it from any context
            LanguageStore.current = language
        }
    }

    private static let languageKey = "MacClean.language"

    init() {
        if let raw = UserDefaults.standard.string(forKey: Self.languageKey),
           let saved = Language(rawValue: raw) {
            language = saved
        } else {
            // Default to system language; fall back to Turkish if unsupported
            let systemCode = Locale.current.language.languageCode?.identifier ?? "tr"
            switch systemCode {
            case "en": language = .english
            case "ru": language = .russian
            default:   language = .turkish
            }
        }
        // Sync initial value into the nonisolated store
        LanguageStore.current = language
    }
}

// MARK: - Nonisolated language store

/// A simple nonisolated store that mirrors the current language so that
/// non-actor-isolated code (enum computed properties, static methods, etc.)
/// can call L() without actor-isolation violations.
enum LanguageStore {
    // Protected by being written only from MainActor-isolated LanguageManager
    // and read from any context (safe for display-only use).
    nonisolated(unsafe) static var current: Language = {
        if let raw = UserDefaults.standard.string(forKey: "MacClean.language"),
           let saved = Language(rawValue: raw) {
            return saved
        }
        let systemCode = Locale.current.language.languageCode?.identifier ?? "tr"
        switch systemCode {
        case "en": return .english
        case "ru": return .russian
        default:   return .turkish
        }
    }()
}
