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

struct LanguageSettingsView: View {
    @AppStorage("appLanguage") private var selection = AppLanguage.system.rawValue
    @State private var showsRestart = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("Language", selection: $selection) {
                ForEach(AppLanguage.allCases) { language in
                    Text(language.title).tag(language.rawValue)
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
        .onAppear {
            // A per-app language chosen in System Settings is stored here too; show it as the
            // current choice instead of claiming the app still follows the system.
            guard let language = (UserDefaults.standard.array(forKey: "AppleLanguages") as? [String])?.first else { return }
            if language.hasPrefix("zh") { selection = AppLanguage.simplifiedChinese.rawValue }
            else if language.hasPrefix("en") { selection = AppLanguage.english.rawValue }
        }
        .onChange(of: selection) { _, value in
            (AppLanguage(rawValue: value) ?? .system).apply()
            showsRestart = true
        }
        .alert("Restart Compositor", isPresented: $showsRestart) {
            Button("Quit Compositor") { NSApp.terminate(nil) }
            Button("Later", role: .cancel) {}
        } message: {
            Text("The new language is applied the next time Compositor opens.")
        }
    }
}
