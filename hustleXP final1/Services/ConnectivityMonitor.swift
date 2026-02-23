import Foundation
import Network
import Combine

/// Monitors network connectivity and publishes status changes
@MainActor
final class ConnectivityMonitor: ObservableObject {
    static let shared = ConnectivityMonitor()

    @Published var isConnected = true
    @Published var connectionType: ConnectionType = .unknown

    enum ConnectionType: String {
        case wifi
        case cellular
        case wiredEthernet
        case unknown
    }

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.hustlexp.connectivity", qos: .utility)

    private init() {
        startMonitoring()
    }

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                guard let self = self else { return }
                let wasConnected = self.isConnected
                self.isConnected = path.status == .satisfied

                if path.usesInterfaceType(.wifi) {
                    self.connectionType = .wifi
                } else if path.usesInterfaceType(.cellular) {
                    self.connectionType = .cellular
                } else if path.usesInterfaceType(.wiredEthernet) {
                    self.connectionType = .wiredEthernet
                } else {
                    self.connectionType = .unknown
                }

                if wasConnected && !self.isConnected {
                    HXLogger.info("ConnectivityMonitor: Network lost", category: "Network")
                } else if !wasConnected && self.isConnected {
                    HXLogger.info("ConnectivityMonitor: Network restored (\(self.connectionType.rawValue))", category: "Network")
                }
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
