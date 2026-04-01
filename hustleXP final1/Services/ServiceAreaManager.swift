//
//  ServiceAreaManager.swift
//  hustleXP final1
//
//  Enforces a single launch region using GPS vs AppConfig center + radius.
//

import CoreLocation
import Foundation

// MARK: - Phase

enum ServiceAreaGatePhase: Equatable {
    /// Restriction off (e.g. DEBUG) — main app always allowed.
    case allowed
    /// Resolving location / permission.
    case checking
    /// User is outside the configured radius.
    case outsideRegion
    /// Location denied or restricted — cannot verify area.
    case needsLocationPermission
}

// MARK: - Manager

@MainActor 
@Observable
final class ServiceAreaManager {
    static let shared = ServiceAreaManager()

    private(set) var phase: ServiceAreaGatePhase

    private init() {
        if AppConfig.isServiceAreaLimited {
            phase = .checking
        } else {
            phase = .allowed
        }
    }

    /// Re-evaluates whether the user may use the main app. Call on launch and when returning to foreground.
    func refresh() async {
        guard AppConfig.isServiceAreaLimited else {
            phase = .allowed
            return
        }

        phase = .checking

        let service = LocationService.current

        switch service.locationAuthorizationStatus {
        case .denied, .restricted:
            phase = .needsLocationPermission
            return
        case .notDetermined:
            service.requestLocationPermission()
        default:
            break
        }

        let (coords, reportedAccuracy) = await service.captureLocation()

        switch service.locationAuthorizationStatus {
        case .denied, .restricted:
            phase = .needsLocationPermission
            return
        default:
            break
        }

        let center = GPSCoordinates(
            latitude: AppConfig.serviceAreaCenterLatitude,
            longitude: AppConfig.serviceAreaCenterLongitude,
            accuracyMeters: 0,
            timestamp: Date()
        )

        let distance = service.calculateDistance(from: coords, to: center)
        let slackMeters = max(reportedAccuracy, coords.accuracyMeters, service.currentAccuracy)
        let limit = AppConfig.serviceAreaRadiusMeters + slackMeters

        if distance <= limit {
            phase = .allowed
            HXLogger.info(
                "[ServiceArea] Within region (\(Int(distance))m from center, limit \(Int(limit))m)",
                category: "General"
            )
        } else {
            phase = .outsideRegion
            HXLogger.info(
                "[ServiceArea] Outside region (\(Int(distance))m from center, limit \(Int(limit))m)",
                category: "General"
            )
        }
    }
}
