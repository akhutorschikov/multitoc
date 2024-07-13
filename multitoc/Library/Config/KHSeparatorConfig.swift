//
//  KHSeparatorConfig.swift
//  photo-printer
//
//  Created by Alex Khuala on 11.01.24.
//

import UIKit

struct KHSeparatorConfig: KHConfig_Protocol
{
    var lineWidth: CGFloat = KHPixel
    var inset: UIEdgeInsets = .zero
    
    static let zero: Self = .init(lineWidth: 0, inset: .zero)
    static let standard: Self = .init(lineWidth: KHPixel, inset: .zero)
}
