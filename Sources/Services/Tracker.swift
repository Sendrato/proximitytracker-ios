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

//    static let serviceUUID = CBUUID(string: "0000FD6F-0000-1000-8000-00805F9B34FB")
    static let serviceUUID = CBUUID(string: "FD6F")

    static let startDatedefaultKey = "com.dexels.proximitytracker.startdate"

    static let proximityRSSIThreshold: Float = -70.0
    static let calendar = Calendar(identifier: .gregorian)

    static let main = Tracker()

    private let tracingCrypto: TracingCrypto
    private var centralManager: CBCentralManager!
    private var peripheralManager: CBPeripheralManager!

    private var queue: DispatchQueue
    private var registry = Registry()

    let joined = MutableProperty<Bool>(false)
    let tracking = MutableProperty<Bool>(false)

    let status = MutableProperty<String>("")
    let startDate: Date

    override init() {
        queue = DispatchQueue(label: "tracker", qos: .background, attributes: [])

        tracingCrypto = try! TracingCrypto()

        startDate = Self.getStartDate()

        super.init()

        centralManager = CBCentralManager(delegate: self, queue: queue)
        peripheralManager = CBPeripheralManager(delegate: self, queue: queue)

        status.value = "Found \(self.registry.pending.count) tokens"
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
            startTracking()
        }
    }

    public func unjoin() {
        joined.value = false
        stopTracking()
    }

    private func day(date: Date) -> Int {
        return Self.calendar.dateComponents([.day], from: startDate, to: date).day ?? 0
    }

    private func tin(date: Date) -> Int {
        let components = Self.calendar.dateComponents([.hour, .minute, .second], from: date)
        let second: Int = components.second ?? 0
        let minute: Int = components.minute ?? 0
        let hour: Int = components.hour ?? 0
        return ( second + minute * 60 + hour * 3600) / 300
    }

    private func startTracking() {
        if !tracking.value {
            tracking.value = true
            centralManager.scanForPeripherals(withServices: [Self.serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])

            roll(date: Date() )
            SignalProducer
                       .timer(interval: .seconds(30), on: QueueScheduler())
                       .take(duringLifetimeOf: self)
                       .start { event in
                           switch event {
                           case .value(let date):
                            self.roll(date: date)
                           default:
                               ()
                           }
                   }
        }
    }

    private func roll(date: Date) {
        let identifier = try! tracingCrypto.rollingProximityIdentifier(day: day(date: date), tin: tin(date: date))

        let advertisementData: [String: Any] = [
            CBAdvertisementDataServiceUUIDsKey: [Self.serviceUUID],

            // This setting is currently not supported by CoreBluetooth.
            CBAdvertisementDataServiceDataKey: [Self.serviceUUID.uuidString: identifier.data as NSData],
        ]
        peripheralManager.startAdvertising(advertisementData)
    }

    private func stopTracking() {
        tracking.value = false
        centralManager.stopScan()
        peripheralManager.stopAdvertising()
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

        if rssi > -50 {
            if let data = advertisementData[CBAdvertisementDataServiceDataKey] as? Data {
                print("Close by id: \(data)")
                let identifier = TracingCrypto.RollingProximityIdentifier(id: data.bytes)
                self.registry.add(entry: identifier)
                status.value = "Found \(self.registry.pending.count) tokens"
            }
        }
    }
}

extension Tracker: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheralManager: CBPeripheralManager) {
        if joined.value && peripheralManager.state == .poweredOn {
            startTracking()
        }
    }
}
