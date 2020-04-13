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

    struct TransferService {
        static let serviceUUID = CBUUID(string: "E20A39F4-73F5-4BC4-A12F-17D1AD07A961")
        static let characteristicUUID = CBUUID(string: "08590F7E-DB05-467E-8757-72F6FAEB13D4")
    }

    static let proximityRSSIThreshold: Float = -70.0

    private var centralManager: CBCentralManager!
    private var peripheralManager: CBPeripheralManager!
    private var locationManager: CLLocationManager

    private var queue: DispatchQueue
    private var uuid: CBUUID
    private var registry = Registry()

    var lastLocation: CLLocation?

    var peripherals: [UUID: CBPeripheral]

    let characteristic = CBMutableCharacteristic(type: TransferService.characteristicUUID, properties: [.notify, .writeWithoutResponse], value: nil, permissions: [.readable, .writeable])

    let service = CBMutableService(type: TransferService.serviceUUID, primary: true)

    override init() {
        queue = DispatchQueue(label: "tracker", qos: .background, attributes: [])

//        uuid = CBUUID(string: "0000180F-0000-1000-8000-00805F9B34FB")
        uuid = CBUUID(string: "39ED98FF-2900-441A-802F-9C398FC199D2")
        peripherals = [:]
        locationManager = CLLocationManager()

        super.init()
        centralManager = CBCentralManager(delegate: self, queue: queue)
        peripheralManager = CBPeripheralManager(delegate: self, queue: queue)
        locationManager.delegate = self
        service.characteristics = [characteristic]
    }

    static let main = Tracker()

    func startBroadcastingTokens() {

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

    func broadcastToken() {
        let token = registry.newToken()
        guard let data = try? JSONEncoder().encode(token) else {
            return
        }
        if let loc = lastLocation {
            registry.add(entry: Registry.Entry(uuid: token, location: Registry.Entry.Location(lat: loc.coordinate.latitude, long: loc.coordinate.longitude)))
        }

        for (id, peripheral) in peripherals {
            centralManager.connect(peripheral, options: nil)
            // peripheral.writeValue(data, for: char, type: .withoutResponse)
            // peripheral.writeValue(data, for: CBDescriptor)
        }
    }
}

extension Tracker: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {

        if central.state == .poweredOn {
            print("Bluetooth is On")
            central.scanForPeripherals(withServices: nil, options: nil)
            locationManager.startMonitoringSignificantLocationChanges()
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
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheralManager.state == .poweredOn {
            peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [TransferService.serviceUUID]])
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            os_log("Error discovering characteristics: %s", error.localizedDescription)
            return
        }

        guard let characteristicData = characteristic.value,
            let token = try? JSONDecoder().decode(Registry.Token.self, from: characteristicData) else {
                return
        }

        os_log("Received %d bytes: %s", characteristicData.count, token.uuidString)
        self.registry.add(token: token)
    }
}

extension Tracker: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }

}
