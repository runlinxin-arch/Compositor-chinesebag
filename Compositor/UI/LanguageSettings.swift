import AppKit
import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case simplifiedChinese = "zh-Hans"
    case english = "en"

    var id: String { rawValue }

    /// Language names stay in their own language; only "Follow System" is translated.
    var title: String {
        switch self {
        case .system: L("Follow System")
        case .simplifiedChinese: "简体中文"
        case .english: "English"
        }
    }

    /// The Mac's own language, read from the global domain rather than the app's override.
    static var systemLanguage: AppLanguage {
        let global = UserDefaults.standard.persistentDomain(forName: UserDefaults.globalDomain)
        let languages = global?["AppleLanguages"] as? [String]
        let first = languages?.first ?? Locale.preferredLanguages.first ?? "en"
        return first.hasPrefix("zh") ? .simplifiedChinese : .english
    }

    /// "Follow System" shows what the system is set to, so the choice is clear.
    var displayTitle: String {
        switch self {
        case .system: "\(L("Follow System")) · \(AppLanguage.systemLanguage.title)"
        default: title
        }
    }

    /// Writes the app's language where macOS reads it at launch. Removing the key hands the
    /// choice back to the system, including a per-app language chosen in System Settings.
    func apply() {
        let defaults = UserDefaults.standard
        switch self {
        case .system:
            defaults.removeObject(forKey: "AppleLanguages")
        case .simplifiedChinese:
            defaults.set(["zh-Hans"], forKey: "AppleLanguages")
        case .english:
            defaults.set(["en"], forKey: "AppleLanguages")
        }
        CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication)
    }
}

/// The globe in the window toolbar: click it to choose a language, then restart.
struct LanguageToolbarButton: View {
    @AppStorage("appLanguage") private var selection = AppLanguage.system.rawValue
    @State private var showsPopover = false

    private var current: AppLanguage { AppLanguage(rawValue: selection) ?? .system }

    var body: some View {
        Button { showsPopover.toggle() } label: {
            HStack(spacing: 5) {
                Image(systemName: "globe")
                Text(current == .system ? L("Language") : current.title)
            }
        }
        .help("\(L("Language")) · \(current == .system ? AppLanguage.systemLanguage.title : current.title)")
        .accessibilityLabel(L("Language"))
        .popover(isPresented: $showsPopover, arrowEdge: .bottom) {
            LanguageSettingsView()
        }
    }
}

struct LanguageSettingsView: View {
    @AppStorage("appLanguage") private var selection = AppLanguage.system.rawValue
    @State private var showsRestart = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("Language", selection: $selection) {
                ForEach(AppLanguage.allCases) { language in
                    Text(language.displayTitle).tag(language.rawValue)
                }
            }
            .pickerStyle(.radioGroup)

            Text("Changing the language takes effect after restarting Compositor.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(width: 380)
        .onChange(of: selection) { _, value in
            (AppLanguage(rawValue: value) ?? .system).apply()
            showsRestart = true
        }
        .alert("Restart Compositor", isPresented: $showsRestart) {
            Button("Restart Compositor") { restart() }
            Button("Later", role: .cancel) {}
        } message: {
            Text("The new language is applied the next time Compositor opens.")
        }
    }

    /// Launches a fresh copy, which reads the new AppleLanguages value, then quits this one.
    /// If the launch fails the app still quits, and opening it again applies the choice.
    private func restart() {
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.createsNewApplicationInstance = true
        NSWorkspace.shared.openApplication(at: Bundle.main.bundleURL, configuration: configuration) { _, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                NSApp.terminate(nil)
            }
        }
    }
}
