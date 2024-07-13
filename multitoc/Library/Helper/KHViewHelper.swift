//
//  KHViewHelper.swift
//  Multitoc
//
//  Created by Alex Khuala on 24.04.24.
//

import UIKit

class KHViewHelper
{
    static let animationDuration: TimeInterval = 0.25
    
    // MARK: - Device Feedback
    
    static func triggerImpactDeviceFeedback()
    {
        UIImpactFeedbackGenerator().impactOccurred(intensity: 0.5)
    }
    
    // MARK: - Animations
    
    static func updateLayerShadowOpacity(_ layer: CALayer, _ opacity: Float)
    {
        let key = "shadowOpacity"
        let updateBlock = { [weak layer] in
            layer?.shadowOpacity = opacity
        }
        
        layer.removeAnimation(forKey: key)
        
        let animationDuration = UIView.inheritedAnimationDuration
        if (animationDuration > 0) {
            
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                layer.removeAnimation(forKey: key)
                updateBlock()
            }
            
            self._addBaseAnimation(to: layer, with: key, duration: animationDuration, toValue: opacity)
            
            CATransaction.commit()
            
        } else {
            
            updateBlock()
        }
    }
    
    // MARK: - Animations internal
    
    static private func _addBaseAnimation(to layer: CALayer, with keyPath: String, duration: TimeInterval, toValue: Any?)
    {
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.toValue = toValue
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        layer.add(animation, forKey: keyPath)
    }
    
    static private func _removeAnimations(of layer: CALayer, for keyPaths: [String])
    {
        for keyPath in keyPaths {
            layer.removeAnimation(forKey: keyPath)
        }
    }
}
