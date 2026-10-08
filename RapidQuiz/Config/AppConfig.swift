import Foundation

/// Derleme ayarından (xcconfig → Info.plist "APIBaseURL") okunan uygulama yapılandırması.
enum AppConfig {
    static let apiBaseURL: URL = {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: "APIBaseURL") as? String,
              !raw.isEmpty,
              let url = URL(string: raw) else { fatalError("APIBaseURL ayarlı değil") }
        return url
    }()
}
