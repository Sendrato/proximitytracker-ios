//
//  File.swift
//  Rid Covid 19
//
//  Created by Jacco Taal on 13/04/2020.
//  Copyright © 2020 Bitnomica. All rights reserved.
//

import Foundation
import CoreBluetooth
import CoreLocation

import ReactiveSwift
import os

class Tracker: NSObject {

    static let serviceUUID = CBUUID(string: "FD6F")
    static let startDatedefaultKey = "com.dexels.proximitytracker.startdate"

    static let proximityRSSIThreshold: Float = -70.0
    static let calendar = Calendar(identifier: .gregorian)

    static let main = Tracker()

    private let tracingCrypto: TracingCrypto
    private var centralManager: CBCentralManager!
    private var peripheralManager: CBPeripheralManager!
    private var locationManager: CLLocationManager

    private var queue: DispatchQueue
    private var registry = Registry()

    var peripherals: [UUID: CBPeripheral]

    let joined = MutableProperty<Bool>(false)
    let tracking = MutableProperty<Bool>(false)

    let lastLocation = MutableProperty<CLLocation?>(nil)


    let startDate: Date

    override init() {
        queue = DispatchQueue(label: "tracker", qos: .background, attributes: [])

        tracingCrypto = try! TracingCrypto()
        peripherals = [:]
        locationManager = CLLocationManager()

        startDate = Self.getStartDate()

        super.init()

        centralManager = CBCentralManager(delegate: self, queue: queue)
        peripheralManager = CBPeripheralManager(delegate: self, queue: queue)
        locationManager.delegate = self
    }

    static func getStartDate() -> Date {
        var startDate = UserDefaults.standard.double(forKey: startDatedefaultKey)
        if startDate == 0 {
            startDate = Date().timeIntervalSince1970
            UserDefaults.standard.set(startDate, forKey: startDatedefaultKey)
        }
        return Date(timeIntervalSince1970: startDate)
    }

    public func join() {
        joined.value = true
        if centralManager.state == .poweredOn &&
            peripheralManager.state == .poweredOn {
            try startTracking()
        }
    }

    public func unjoin() {
        joined.value = false
        stopTracking()
    }

    private func day(date: Date) -> Int {
        return Self.calendar.dateComponents([.day], from: startDate, to: date).day ?? 0
    }

    private func tin(date: Date) -> UInt {
        let components = Self.calendar.dateComponents([.hour, .minute, .second], from: date)
        return (((components.second ?? 0) + (components.minute ?? 0) * 60 + (components.hour ?? 0) * 3600) as Int) / 12
    }

    private func startTracking() throws {
        if !tracking.value {
            tracking.value = true
            centralManager.scanForPeripherals(withServices: nil, options: nil)
            locationManager.startMonitoringSignificantLocationChanges()

            let date = Date()
            let identifier = try tracingCrypto.rollingProximityIdentifier(day: day(date: date), tin: tin(date: date))
            let advertisementData: [String: Any] = [
                CBAdvertisementDataServiceUUIDsKey: [Self.serviceUUID],
                CBAdvertisementDataServiceDataKey: identifier
            ]
            peripheralManager.startAdvertising(advertisementData)

            SignalProducer
                       .timer(interval: .seconds(30), on: QueueScheduler())
                       .take(duringLifetimeOf: self)
                       .start { event in
                           switch event {
                           case .value(let date):
                               self.broadcastToken()
                           default:
                               ()
                           }
                   }
        }
    }

    private func roll() {
        if !tracking.value {
                   tracking.value = true
                   centralManager.scanForPeripherals(withServices: nil, options: nil)
                   locationManager.startMonitoringSignificantLocationChanges()

                   let date = Date()
                   let identifier = try tracingCrypto.rollingProximityIdentifier(day: day(date: date), tin: tin(date: date))
                   let advertisementData: [String: Any] = [
                       CBAdvertisementDataServiceUUIDsKey: [Self.serviceUUID]
                       CBAdvertisementDataServiceDataKey: identifier
                   ]
                   peripheralManager.startAdvertising(advertisementData)
                   startBroadcastingTokens()
               }
    }

    private func stopTracking() {
        tracking.value = false
        centralManager.stopScan()
        peripheralManager.stopAdvertising()
//        stopBroadcasting()
    }
}

extension Tracker: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {

        if joined.value && central.state == .poweredOn {
            print("Bluetooth is On")
            startTracking()
        } else {
            print("Bluetooth is not active")
        }
    }

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                               advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let rssi: Float = RSSI.floatValue
        print("\n")
        print("Name   : \(peripheral.name ?? "(No name)")")
        print("ID     : \(peripheral.identifier.uuidString)")
        print("RSSI   : \(RSSI)")
        for ad in advertisementData {
            print("AD Data: \(ad)")
        }
//        for s in peripheral.services ?? [] {
//            print("Service: \(s.characteristics)")
//        }

        self.peripherals[peripheral.identifier] = peripheral

//        if rssi > Self.proximityRSSIThreshold {
//            let entry = Registry.Entry(uuid: UUID(), location: .init(lat: 2.0, long: 3.0))
//            self.registry.add(entry: entry)
//        }
    }

    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        peripherals.removeValue(forKey: peripheral.identifier)
    }
}

extension Tracker: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheralManager: CBPeripheralManager) {
        if joined.value && peripheralManager.state == .poweredOn {
            startTracking()
        }
    }
}

extension Tracker: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation.value = locations.last
    }
}
