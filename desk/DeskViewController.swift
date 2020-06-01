//
//  DeskViewcontroller.swift
//  desk
//
//  Created by Forti on 18/05/2020.
//  Copyright © 2020 Forti. All rights reserved.
//

import Cocoa
import CoreBluetooth

class DeskViewController: NSViewController, CBPeripheralDelegate, CBCentralManagerDelegate {

    /**
     let's find all devices with given Services UDID (control and referenceOutput)
     */
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central state update")
        if central.state != .poweredOn {
            print("Central is not powered on")
        } else {
            print("Central scanning for", ParticlePeripheral.control.uuidString, ParticlePeripheral.referenceOutput.uuidString);
            centralManager.scanForPeripherals(withServices: nil,
                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    
    let deviceNamePattern = #"Desk[\s0-9].*"#;
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // @TODO
        // DeviceName is just a test. let's do collection list with option to connect by user
        let deviceName = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey) as? NSString
print(deviceName)
        let isDesk = deviceName?.range(of: deviceNamePattern, options:.regularExpression)
        if (isDesk?.location != NSNotFound && deviceName != nil) {
            print(isDesk, deviceName)
            print("--============================================================================--")
            print(advertisementData)
            print(peripheral)
            print(RSSI)
            
            self.centralManager.stopScan()
            
            self.peripheral = peripheral
            self.peripheral.delegate = self
            
            self.centralManager.connect(self.peripheral, options: nil)
            print("--============================================================================--")
        }
    }
    
    /**
     After connected do device - let's discover it's services
     */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == self.peripheral {
            print("Connected to your Desk:", peripheral.name)
            
            self.peripheral.discoverServices([ParticlePeripheral.control, ParticlePeripheral.referenceOutput])
        }
    }
    
    /**
     After discovered services - let's discover out characteristics
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                print("service:", service)
                peripheral.discoverCharacteristics([ParticlePeripheral.characteristicControl], for: service)
            }
        }
    }
    
    /**
     Add listener to our characteristic
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.properties.contains(.read) {
                  print("\(characteristic.uuid): properties contains .read")
                }
                if characteristic.properties.contains(.notify) {
                  print("\(characteristic.uuid): properties contains .notify")
                }

                peripheral.setNotifyValue(true, for: characteristic)
                
                print("readValue:", self.peripheral.readValue(for: characteristic), characteristic.value, characteristic.uuid)
                print("characteristic:", characteristic)
                print("properties:", characteristic.properties)
            }
        }
    }
    
    // https://www.raywenderlich.com/231-core-bluetooth-tutorial-for-ios-heart-rate-monitor
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        if (characteristic.uuid.uuidString == ParticlePeripheral.characteristicControl.uuidString) {
            print("INIT CONTROL")
            self.characteristicControl = characteristic
        }
        
        if (characteristic.value != nil){
            let byteArray = [UInt8](characteristic.value!)
            if (characteristic.value != nil && byteArray.indices.contains(0) && byteArray.indices.contains(1)) {
                do {
                    let a = try unpack("<H", Data([byteArray[0], byteArray[1]]))
                    print("Current position:", a, characteristic.uuid.uuidString)
//                    valueLabel.intValue = [Int32]a
                }catch let error as NSError {
                    print("Bad Error (How Bad Level: \(error)")
                }
            }
        }
    }
        
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    private var characteristicControl: CBCharacteristic!
    private var characteristicMove: CBCharacteristic!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    @IBOutlet var valueLabel: NSTextField!
    
    @IBAction func up(_ sender: NSButton) {
        let moveUp = pack("<H", [71, 0])
        self.peripheral.writeValue(Data(moveUp), for: self.characteristicControl, type: CBCharacteristicWriteType.withResponse)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let stop = pack("<H", [255, 0])
            self.peripheral.writeValue(Data(stop), for: self.characteristicControl, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    @IBAction func down(_ sender: NSButton) {
        let a = pack("<H", [70, 0])
        self.peripheral.writeValue(Data(a), for: self.characteristicControl, type: CBCharacteristicWriteType.withResponse)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let stop = pack("<H", [255, 0])
            self.peripheral.writeValue(Data(stop), for: self.characteristicControl, type: CBCharacteristicWriteType.withResponse)
        }
    }
}

extension DeskViewController {
    // MARK: Storyboard instantiation
    static func freshController() -> DeskViewController {
        //1.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        //2.
        let identifier = NSStoryboard.SceneIdentifier("DeskViewController")
        //3.
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? DeskViewController else {
            fatalError("Why cant i find QuotesViewController? - Check Main.storyboard")
        }
        return viewcontroller
    }
}

