import SwiftUI

/// Gömülü fontlar (Info.plist › UIAppFonts). Hepsi Dinamik Yazı ile ölçeklenir.
extension Font {
    /// Başlıklar: Space Grotesk Bold
    static func rqHeading(_ size: CGFloat, relativeTo style: Font.TextStyle = .title) -> Font {
        .custom("SpaceGrotesk-Bold", size: size, relativeTo: style)
    }

    /// Metin: Plus Jakarta Sans
    static func rqBody(_ size: CGFloat = 17, weight: RQWeight = .regular, relativeTo style: Font.TextStyle = .body) -> Font {
        .custom(weight.fontName, size: size, relativeTo: style)
    }

    // Sık kullanılanlar
    static let rqLogo = rqHeading(40, relativeTo: .largeTitle)
    static let rqTitle = rqHeading(28, relativeTo: .title)
    static let rqTitle2 = rqHeading(22, relativeTo: .title2)
    static let rqQuestion = rqHeading(22, relativeTo: .title2)   // soru metni ≥ 20 pt
    static let rqChoice = rqBody(17, weight: .bold)
    static let rqCaption = rqBody(13, relativeTo: .caption)
}

enum RQWeight {
    case regular, semibold, bold

    var fontName: String {
        switch self {
        case .regular: "PlusJakartaSans-Regular"
        case .semibold: "PlusJakartaSans-SemiBold"
        case .bold: "PlusJakartaSans-Bold"
        }
    }
}

/// Köşe yarıçapları
enum Radius {
    static let card: CGFloat = 24
    static let button: CGFloat = 16
}
