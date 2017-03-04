//
//  ViewController.swift
//  H7PolarHeartRate
//
//  Created by Mark Illingworth on 4/3/17.
//  Copyright © 2017 Mark Illingworth. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralManagerDelegate {

    let deviceName = "H7 Polar" as NSString
    
    // Service UUIDs
    let POLARH7_HRM_DEVICE_INFO_SERVICE_UUID = CBUUID(string: "180A")
    let POLARH7_HRM_HEART_RATE_SERVICE_UUID = CBUUID(string: "180D")
    
    // Characteristic UUIDs
    let POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID = CBUUID(string: "2A37")
    let POLARH7_HRM_BODY_LOCATION_CHARACTERISTIC_UUID = CBUUID(string: "2A38")
    let POLARH7_HRM_MANUFACTURER_NAME_CHARACTERISTIC_UUID = CBUUID(string: "2A29")
    
    // set up a central and peripheral
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - CBCentralManagerDelegate
    
    // Method called whenever you have successfully connected to the BLE peripheral
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        <#code#>
    }
    
    // CBCentralManagerDelegate - This is called with the CBPeripheral class as its main input parameter. This contains most of the information there is to know about a BLE peripheral.
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        <#code#>
    }
    
    // Method called whenever the device state changes.
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        <#code#>
    }
    
    // MARK: - CBPerhiperhalManagerDelegate
    // CBPeripheralDelegate - Invoked when you discover the peripheral's available services.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
    }
 
    // Invoked when you discover the characteristics of a specified service.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicFor service: CBService, error: Error?) {
        
    }
    
    // Invoked when you retrieve a specified characteristic's value, or when the peripheral device notifies your app that the characteristic's value has changed.
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: Error?) {
        
    }
    
}


