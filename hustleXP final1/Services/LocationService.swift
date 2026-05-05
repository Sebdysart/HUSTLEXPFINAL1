//
//  LocationService.swift
//  hustleXP final1
//
//  Service switcher: uses MockLocationService in the simulator, RealLocationService on device
//

import Foundation

enum LocationService {
    static var current: LocationServiceProtocol { RealLocationService.shared }
}
