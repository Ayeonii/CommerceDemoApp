//
//  UIColor + Extensions.swift
//  CommerceDemoApp
//
//  Created by 이아연 on 2022/11/25.
//

import UIKit

enum AppMainColor {
    case deepRosePink
    case rosePink
    case textPrimary
    case textSecondary
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
    
    convenience init(rgb: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF,
            alpha: alpha
        )
    }
    
    static func appColor(_ name: AppMainColor) -> UIColor {
        switch name {
        case .deepRosePink:
            return UIColor(rgb: 0xDB545A)
        case .rosePink:
            return UIColor(red: 236, green: 94, blue: 101)
        case .textPrimary:
            return UIColor.black
        case .textSecondary:
            return UIColor(red: 119, green: 119, blue: 119)
        }
    }
}
