//
//  Connect.swift
//  desk
//
//  Created by Forti on 05/06/2020.
//  Copyright © 2020 Forti. All rights reserved.
//

import Foundation
import CoreBluetooth

let deviceNamePattern = #"Desk[\s0-9].*"#;
class DeskConnect: NSObject, CBPeripheralDelegate, CBCentralManagerDelegate {
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    
    private var characteristicPosition: CBCharacteristic!
    private var characteristicControl: CBCharacteristic!
    
    private var valueMoveUp = pack("<H", [71, 0])
    private var valueMoveDown = pack("<H", [70, 0])
    private var valueStopMove = pack("<H", [255, 0])
    
    private var currentPosition: Int!
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if (central.state != .poweredOn) {
            print("Central is not powered on. Bluetooth disabled? @TODO")
        } else {
            self.centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        }
    }
    
    /**
     ON DISCOVER
     */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // @TODO
        // DeviceName is just a test. let's do collection list with option to connect by user
        let deviceName = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey) as? NSString
        let isDesk = deviceName?.range(of: deviceNamePattern, options:.regularExpression)
        if (isDesk?.location != NSNotFound && deviceName != nil) {
            self.centralManager.stopScan()
            
            self.peripheral = peripheral
            self.peripheral.delegate = self
            self.centralManager.connect(self.peripheral, options: nil)
        }
    }
    
    /**
     ON CONNECT
     */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print(peripheral)

        self.peripheral.discoverServices(ParticlePeripheral.allServices)
    }
    
    /**
     ON SERVICES
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                self.peripheral.discoverCharacteristics(ParticlePeripheral.allCharacteristics, for: service)
            }
        }
    }
    
    /**
     ON CHARACTERISTICS
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                self.peripheral.readValue(for: characteristic)
                self.peripheral.setNotifyValue(true, for: characteristic)
                                
                if (characteristic.uuid.uuidString == ParticlePeripheral.characteristicControl.uuidString) {
                    self.characteristicControl = characteristic
                }
                
                if (characteristic.uuid.uuidString == ParticlePeripheral.characteristicPosition.uuidString) {
                    self.characteristicPosition = characteristic
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        self.updatePosition(characteristic: characteristic)
    }
    
    func moveUp() {
        self.peripheral.writeValue(Data(self.valueMoveUp), for: self.characteristicControl, type: CBCharacteristicWriteType.withResponse)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.stopMoving()
        }
    }
    
    func moveDown() {
        self.peripheral.writeValue(Data(self.valueMoveDown), for: self.characteristicControl, type: CBCharacteristicWriteType.withResponse)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.stopMoving()
        }
    }
    
    private func updatePosition(characteristic: CBCharacteristic) {
        if (characteristic.value != nil && characteristic.uuid.uuidString == self.characteristicPosition.uuid.uuidString) {
            let byteArray = [UInt8](characteristic.value!)
            if (byteArray.indices.contains(0) && byteArray.indices.contains(1)) {
                do {
                    let position = try unpack("<H", Data([byteArray[0], byteArray[1]]))
                    self.currentPosition = position[0] as? Int
                    print(self.currentPosition!)
                } catch let error as NSError {
                    print("Error, update position: \(error)")
                }
            }
        }
    }
    
    private func stopMoving() {
        self.peripheral.writeValue(Data(self.valueStopMove), for: self.characteristicControl, type: CBCharacteristicWriteType.withResponse)
    }
}
