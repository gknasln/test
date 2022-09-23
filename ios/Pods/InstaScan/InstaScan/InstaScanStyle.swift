//
//  InstaScanStyle.swift
//  InstaScan
//
//  Created by Can Şener on 8.08.2022.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    var hexString: String {
        let cgColorInRGB = cgColor.converted(to: CGColorSpace(name: CGColorSpace.sRGB)!, intent: .defaultIntent, options: nil)!
        let colorRef = cgColorInRGB.components
        let r = colorRef?[0] ?? 0
        let g = colorRef?[1] ?? 0
        let b = ((colorRef?.count ?? 0) > 2 ? colorRef?[2] : g) ?? 0
        let a = cgColor.alpha

        var color = String(
            format: "#%02lX%02lX%02lX",
            lroundf(Float(r * 255)),
            lroundf(Float(g * 255)),
            lroundf(Float(b * 255))
        )

        if a < 1 {
            color += String(format: "%02lX", lroundf(Float(a * 255)))
        }

        return color
    }
}


public class InstaScanStyle : Encodable {

    public var validTextHighlightColor = UIColor(red: 16/255.0, green: 107/255.0, blue: 33/225.0, alpha: 1.0)
    public var invalidTextHighlightColor = UIColor(red: 148/255.0, green: 0/255.0, blue: 8/225.0, alpha: 1.0)
    public var guideTextColor = UIColor.white
    public var guideTextFont:UIFont = UIFont.systemFont(ofSize: 15.0, weight: .semibold)
    public var overlayColor = UIColor.black.withAlphaComponent(0.6)

    public init(){
        
    }
    
    enum CodingKeys: String, CodingKey {
      case validTextHighlightColor, invalidTextHighlightColor, guideTextColor, guideTextFont, overlayColor, guideTextFontName, guideTextFontSize
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(validTextHighlightColor.hexString, forKey: .validTextHighlightColor)
        try container.encode(invalidTextHighlightColor.hexString, forKey: .invalidTextHighlightColor)
        try container.encode(guideTextColor.hexString, forKey: .guideTextColor)
        try container.encode(overlayColor.hexString, forKey: .overlayColor)
        try container.encode(guideTextFont.fontName, forKey: .guideTextFontName)
        try container.encode(guideTextFont.pointSize, forKey: .guideTextFontSize)
        

    }

}
