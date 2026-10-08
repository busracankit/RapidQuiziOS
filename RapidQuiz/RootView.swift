import SwiftUI

/// Uygulamanın kökü. Navigasyon (NavigationStack + Route) 3. adımda buraya gelecek.
struct RootView: View {
    var body: some View {
        ZStack {
            Color.rqBackground.ignoresSafeArea()
            VStack(spacing: 12) {
                Text("app_name")
                    .font(.rqLogo)
                    .foregroundStyle(Color.rqPrimary)
                Text("slogan")
                    .font(.rqBody(17, weight: .semibold))
                    .foregroundStyle(Color.rqInk)
                    .multilineTextAlignment(.center)
                Text(AppConfig.apiBaseURL.absoluteString)
                    .font(.rqCaption)
                    .foregroundStyle(Color.rqInk.opacity(0.6))
            }
            .padding(24)
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    RootView()
}
