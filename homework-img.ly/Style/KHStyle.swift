//
//  KHStyle.swift
//  homework-img.ly
//
//  Created by Alex Khuala on 24.04.24.
//

import UIKit

struct KHStyle
{
    // MARK: - Font

    static let bodyFont: UIFont = .systemFont(ofSize: 16)
    
    static let listFont0: UIFont = .systemFont(ofSize: 14, weight: .bold)
    static let listFont1: UIFont = .systemFont(ofSize: 26, weight: .bold)
    static let listFont2: UIFont = .systemFont(ofSize: 16, weight: .medium)
    static let listFont3: UIFont = .systemFont(ofSize: 14, weight: .medium)
    
    static let infoFont: UIFont = .systemFont(ofSize: 13, weight: .medium)
    static let infoBoldFont: UIFont = .systemFont(ofSize: 13, weight: .bold)
    
    static let emailFont: UIFont = .systemFont(ofSize: 19, weight: .semibold)
    
    // MARK: - Size
    
    static let minEventSize: CGSize = .init(44)
    
    static let dateWidth: CGFloat = 84
    
    // MARK: - Inset
    
    static let mainInset: CGFloat = 24
    static let bodyInset: CGFloat = 16
    static let infoInset: CGFloat = 8
    
    static let listInset0: UIEdgeInsets = .init(top: 32, bottom: 14)
    static let listInset1: UIEdgeInsets = .init(top: 15, bottom: 8)
    static let listInset2: UIEdgeInsets = .init(y: 12)
    static let listInset3: UIEdgeInsets = .init(y: 13).left(24)
    
    // MARK: - Spacing
    
    static let groupRowButtonSpacing: CGFloat = 10
    
    static let detailEmailSpacing: CGFloat = 6
    
    // MARK: - Value

    static let cornerRadius: CGFloat = 4
}
