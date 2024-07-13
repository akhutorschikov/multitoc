//
//  KHTreeViewModel.swift
//  Multitoc
//
//  Created by Alex Khuala on 24.04.24.
//

import Foundation

class KHTreeViewModel: KHTree_ViewModel
{
    func addListener(_ listener: KHTree_ViewModelListener)
    {
        self._listeners.add(listener)
    }
    
    func removeListener(_ listener: KHTree_ViewModelListener)
    {
        self._listeners.remove(listener)
    }
    
    var entries: [KHMainEntry] {
        KHContentManager.shared.entries
    }
    
    private let _listeners: Listeners = .init()
}

// *************************
// *************************  Internal
// *************************


extension KHTreeViewModel
{
    fileprivate class Listeners
    {
        typealias Listener = KHTree_ViewModelListener
        
        func add(_ listener: Listener)
        {
            self._entries.append(.init(listener: listener))
        }
        
        func remove(_ listener: Listener)
        {
            self._entries.removeAll { $0.listener === listener }
        }
        
        func removeAll()
        {
            self._entries = []
        }
        
        // MARK: - Private
        
        fileprivate func notify(in block: (_ listener: Listener) -> Void)
        {
            for entry in self._entries {
                guard let listener = entry.listener else {
                    continue
                }
                block(listener)
            }
        }
        
        private var _entries: [Entry] = []
        private struct Entry
        {
            weak var listener: Listener?
        }
    }
}
