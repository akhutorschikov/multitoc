//
//  KHLayout_Listener.swift
//  Multitoc
//
//  Created by Alex Khuala on 01.02.24.
//

import UIKit

protocol KHLayout_Listener: AnyObject
{
    // all methods are optional
    
    func subviewDidRequestLayoutUpdate()
    func subviewDidRequestBringToFront()
}

extension KHLayout_Listener
{
    func subviewDidRequestLayoutUpdate() {}
    func subviewDidRequestBringToFront() {}
}
