//
//  NetworkMonitor.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 19.4.26.
//

import Foundation
import Network
import Observation

@Observable
@MainActor
final class NetworkMonitor {
    
    private(set) var isConnected = true
    
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "com.moviesapp.networkmonitor", qos: .utility)
    
    init() {
        self.monitor = NWPathMonitor()

        // Allow UI tests to simulate offline mode
        if ProcessInfo.processInfo.arguments.contains("-UITest_ForceOffline") {
            isConnected = false
            return
        }

        startMonitoring()
    }
    
    deinit {
        monitor.cancel()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            let connected = path.status == .satisfied
            
            Task { @MainActor [weak self] in
                guard let self else { return }
                // Only update if value actually changed
                if self.isConnected != connected {
                    self.isConnected = connected
                }
            }
        }
        monitor.start(queue: queue)
    }
}
