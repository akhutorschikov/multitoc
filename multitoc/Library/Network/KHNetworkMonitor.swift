//
//  KHNetworkMonitor.swift
//  Multitoc
//
//  Created by Alex Khuala on 24.04.24.
//

import Foundation
import Network

class KHNetworkMonitor
{
    // MARK: - Singleton
    
    public static let shared = KHNetworkMonitor()
    
    // MARK: - Init
    
    private init()
    {
        self.startMonitoring()
    }
    
    // MARK: - Public
    
    var isReachable: Bool {
        self._status == .satisfied
    }
    
    func startMonitoring()
    {
        self._monitor.pathUpdateHandler = { [weak self] path in
            self?._status = path.status
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        self._monitor.start(queue: queue)
    }
    
    func stopMonitoring()
    {
        self._monitor.cancel()
    }
    
    // MARK: - Private

    private let _monitor = NWPathMonitor()
    private var _status = NWPath.Status.requiresConnection
}
