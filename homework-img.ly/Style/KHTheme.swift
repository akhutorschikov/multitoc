//
//  KHTheme.swift
//  homework-img.ly
//
//  Created by Alex Khuala on 24.04.24.
//

import Foundation

class KHTheme: KHTheme_Protocol
{
    enum Name: String, CaseIterable
    {
        case gray
        case red
        case green
        
        func next() -> Name
        {
            let allCases = Self.allCases
            
            guard let currentIndex = allCases.firstIndex(of: self) else {
                return .gray
            }
            let nextIndex = (currentIndex + 1) % allCases.count
            return allCases[nextIndex]
        }
    }
    
    // MARK: - Public
    
    public static private(set) var name: Name = .gray
    public static private(set) var color = KHPalette(KHTheme.name)
    
    public static func load(_ name: Name)
    {
        self.name = name
        self.color = KHPalette(name)
        self._notifyListeners()
    }
    
    public static func toggle()
    {
        self.load(self.name.next())
    }
    
    /*!
     @brief Subscribe to events
     */
    public static func addListener(_ listener: any KHTheme_Sensitive)
    {
        self._listeners.append(.init(listener: listener))
    }
    
    /*!
     @brief Unsubscribe from events
     */
    public static func removeListener(_ listener: any KHTheme_Sensitive)
    {
        self._listeners.removeAll { $0.listener === listener }
    }
    
    // MARK: - Init
    
    private init() {}
    
    // MARK: - Internal
    
    private struct Entry
    {
        weak var listener: (any KHTheme_Sensitive)?
    }
    
    private static var _listeners: [Entry] = []
    
    private static func _notifyListeners()
    {
        self._listeners.forEach { $0.listener?.didChangeTheme() }
    }
}
