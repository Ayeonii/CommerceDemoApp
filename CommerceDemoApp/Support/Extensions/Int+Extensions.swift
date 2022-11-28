//
//  Int+Extensions.swift
//  CommerceDemoApp
//
//  Created by 이아연 on 2022/11/26.
//

import Foundation

extension Int {
    func toDecimal() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from : NSNumber(value: self)) ?? "0"
    }
}

