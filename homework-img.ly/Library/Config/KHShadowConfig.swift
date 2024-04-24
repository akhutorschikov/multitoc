//
//  KHShadowConfig.swift
//  photo-printer
//
//  Created by Alex Khuala on 20.01.23.
//

import UIKit

struct KHShadowConfig: KHConfig_Protocol
{
    var offset: CGPoint   = .zero
    var radius: CGFloat   =  10
    var opacity: CGFloat  =  0.2
    var color: UIColor    = .black

    func apply(to view: UIView)
    {
        self.apply(to: view.layer)
    }
    
    func apply(to layer: CALayer)
    {
        let offset = self.offset
        
        layer.shadowOffset  = CGSize(width: offset.x, height: offset.y)
        layer.shadowRadius  = self.radius
        layer.shadowOpacity = Float(self.opacity)
        layer.shadowColor   = self.color.cgColor
    }
    
    static func removeShadow(of view: UIView)
    {
        self.removeShadow(of: view.layer)
    }
    
    static func removeShadow(of layer: CALayer)
    {
        layer.shadowOffset  = .zero
        layer.shadowRadius  = .zero
        layer.shadowOpacity = .zero
        layer.shadowColor   = .none
    }
    
    static func setShadow(_ config: Self?, to view: UIView)
    {
        guard let config = config else {
            self.removeShadow(of: view)
            return
        }
        config.apply(to: view)
    }
    
    static func setShadow(_ config: Self?, to layer: CALayer)
    {
        guard let config = config else {
            self.removeShadow(of: layer)
            return
        }
        config.apply(to: layer)
    }
    
    static let standard: Self = .init()
}
