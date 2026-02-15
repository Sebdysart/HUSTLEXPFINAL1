//
//  LocationService.swift
//  hustleXP final1
//
//  Service switcher: uses MockLocationService in the simulator, RealLocationService on device
//

import Foundation

enum LocationService {
    #if targetEnvironment(simulator)
    static var current: LocationServiceProtocol { MockLocationService.shared }
    #else
    static var current: LocationServiceProtocol { RealLocationService.shared }
    #endif
}
