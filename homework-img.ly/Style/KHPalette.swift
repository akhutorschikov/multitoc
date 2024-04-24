//
//  KHPalette.swift
//  homework-img.ly
//
//  Created by Alex Khuala on 24.04.24.
//

import UIKit

struct KHPalette
{
    typealias T = KHColor
    
    let main: T = .black
    let text: T = .black
    let info: T = .init(104)
    let back: T = .white
    let button: T
    let separator: T
    let separator0: T
    
    let listBack0: T
    
    let listText0: T
    let listText1: T
    let listText2: T
    let listText3: T
    
            
    init(_ name: KHTheme.Name) { switch name {
    case .gray:
        
        button = .gray
        separator = .init(200)
        separator0 = .init(220)
        
        listBack0 = .init(248, 248, 250)
        listText0 = .init(30, 32, 36)
        listText1 = .init(30, 32, 36)
        listText2 = .init(20, 63, 147)
        listText3 = .init(30, 32, 36)
    case .red:
        
        button = .init(160, 110, 130)
        separator = .init(200)
        separator0 = .init(220)
        
        listBack0 = .init(248, 243, 242)
        listText0 = .init(90, 32, 36)
        listText1 = .init(30, 45, 36)
        listText2 = .init(200, 63, 20)
        listText3 = .init(100)
    case .green:
        
        button = .init(110, 160, 130)
        separator = .init(200)
        separator0 = .init(220)
        
        listBack0 = .init(243, 248, 244)
        listText0 = .init(30, 90, 36)
        listText1 = .init(30, 45, 36)
        listText2 = .init(63, 160, 20)
        listText3 = .init(50, 56, 120)
    }}
}
