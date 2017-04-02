//
//  ViewController.swift
//  H7PolarHeartRate
//
//  Created by Mark Illingworth on 4/3/17.
//  Copyright © 2017 Mark Illingworth. All rights reserved.
//

import UIKit
import CoreBluetooth
import QuartzCore

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    // MARK: - PROPERTIES
    
    // Title labels
    var titleLabel : UILabel!
    var statusLabel : UILabel!
    
    // Properties to handle storing the BPM and heart beat
    
    var heartRateBPM: UILabel!
    var pulseTimer: Timer!
    let deviceName = "H7 Polar"
    
    // Service UUIDs
    let POLARH7_HRM_DEVICE_INFO_SERVICE_UUID = CBUUID(string: "180A")
    let POLARH7_HRM_HEART_RATE_SERVICE_UUID = CBUUID(string: "180D")
    
    // Characteristic UUIDs
    let POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID = CBUUID(string: "2A37")
    let POLARH7_HRM_BODY_LOCATION_CHARACTERISTIC_UUID = CBUUID(string: "2A38")
    let POLARH7_HRM_MANUFACTURER_NAME_CHARACTERISTIC_UUID = CBUUID(string: "2A29")
    
    // set up a central and peripheral
    var centralManager: CBCentralManager!
    var polarH7Peripheral: CBPeripheral!
    
    // Properties to hold the object data
    
    @IBOutlet var heartImage: UIImageView!
    @IBOutlet var deviceInfo: UITextView!
    
    // Properties to hold data characteristics for the peripheral device
    
    var connected: NSString!
    var bodyData: NSString!
    var manufacturer: NSString!
    var polarH7DeviceData: NSString!
    var heartRate: __uint16_t!
    var bodyDataLabel: UILabel!
    
    // APP launch Screen
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.polarH7DeviceData = nil
        
        // Initialize central manager on load
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        // Set up title label
        titleLabel = UILabel()
        titleLabel.text = "Heart Rate Monitor"
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint(x: self.view.frame.midX, y: self.titleLabel.bounds.midY+28)
        self.view.addSubview(titleLabel)
        
        // Set up status label
        statusLabel = UILabel()
        statusLabel.textAlignment = NSTextAlignment.center
        statusLabel.text = "Loading..."
        statusLabel.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        statusLabel.sizeToFit()
        statusLabel.center = CGPoint(x: self.view.frame.midX, y: (titleLabel.frame.maxY + statusLabel.bounds.height/2) )
        statusLabel.frame = CGRect(x: self.view.frame.origin.x, y: self.titleLabel.frame.maxY, width: self.view.frame.width, height: self.statusLabel.bounds.height)
        self.view.addSubview(statusLabel)
        
        
        // Set up heartRateBPM label
        heartRateBPM = UILabel()
        heartRateBPM.text = "0"
        heartRateBPM.font = UIFont(name: "HelveticaNeue-Light", size: 100)
        heartRateBPM.sizeToFit()
        heartRateBPM.center = CGPoint(x: self.view.frame.midX, y: self.titleLabel.bounds.midY+300)
        self.view.addSubview(heartRateBPM)
        
        // Set up UIImageView
        heartImage = UIImageView()
        heartImage.center = CGPoint(x: self.view.frame.midX, y: (titleLabel.frame.maxY + statusLabel.bounds.height/2) )
        heartImage.frame = CGRect(x: self.view.frame.origin.x, y: self.titleLabel.frame.maxY, width: self.view.frame.width, height: self.statusLabel.bounds.height)
        self.view.addSubview(heartImage)
        
        
        // Set up UITextTableView
        deviceInfo = UITextView()
        deviceInfo.textAlignment = NSTextAlignment.center
        deviceInfo.text = ""
        deviceInfo.textColor = UIColor.blue
        deviceInfo.frame = CGRect(x: self.view.frame.origin.x, y: self.deviceInfo.frame.maxY, width: self.view.frame.width, height: self.deviceInfo.bounds.height)
        self.view.addSubview(deviceInfo)
        
//        // Scan for all available Bluetooth LE devices
//        func scanBLEDevice(){
//            let services: NSArray! = [[POLARH7_HRM_DEVICE_INFO_SERVICE_UUID],[POLARH7_HRM_HEART_RATE_SERVICE_UUID]]
//            centralManager?.scanForPeripherals(withServices: services as! [CBUUID]?, options: nil)
//            // If the main queue has not found the services in 60 seconds stop scanning for devices
//            DispatchQueue.main.asyncAfter(deadline: .now() + 60.0) {
//            self.centralManager.stopScan()
//            NSLog("Scanning took longer than 60 seconds")
//            }
//        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - CBCentralManagerDelegate
    
    
    // Method called whenever the device state changes.
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        // Determine the state of the peripheral
        if (centralManager.state == .poweredOn) {
            NSLog("CoreBluetooth BLE hardware is powered on and ready")
            // Scan for peripherals if BLE is turned on
            centralManager.scanForPeripherals(withServices: nil, options: nil)
            self.statusLabel.text = "Bluetooth is on... Searching for BLE Devices"
        }
        else if (centralManager.state == .poweredOff) {
            NSLog("CoreBluetooth BLE hardware is powered off")
            self.statusLabel.text = "BLE harware is powered off"
        }
        else if (centralManager.state == .unauthorized) {
            NSLog("CoreBluetooth BLE state is unauthorized")
            self.statusLabel.text = "CoreBluetooth BLE state is unauthorised"
        }
        else if (centralManager.state == .unknown) {
            NSLog("CoreBluetooth BLE state is unknown")
            self.statusLabel.text = "CoreBluetooth BLE state is unknown"
        }
        else if (centralManager.state == .unsupported) {
            NSLog("CoreBluetooth BLE hardware is unsupported on this platform")
            self.statusLabel.text = "CoreBluetooth BLE state is not supported on this platform"
            
        }
        
    }
    
    // CBCentralManagerDelegate - This is called with the CBPeripheral class as its main input parameter. This contains most of the information there is to know about a BLE peripheral.
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // let device = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey) as? NSString
        
        if /* device?.contains(deviceName)== */true {
            self.centralManager.stopScan()
            self.polarH7Peripheral = peripheral
            self.polarH7Peripheral.delegate = self
            centralManager.connect(peripheral, options: nil)
            NSLog("Central Manager connected to peripheral")
        }
    }
    
    
    // Method called whenever you have successfully connected to the BLE peripheral
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.statusLabel.text = "Called didConnect to peripheral"
        polarH7Peripheral.discoverServices(nil)
        NSLog("Called didConnect to peripheral")
    }
    
    
    // MARK: - CBPerhiperhalManagerDelegate
    // CBPeripheralDelegate - Invoked when you discover the peripheral's available services.
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in polarH7Peripheral.services! {
            NSLog("Discovered service: %@", service.uuid)
            polarH7Peripheral.discoverCharacteristics(nil, for: service)  // come back an check this
        }
    }
 
    // Invoked when you discover the characteristics of a specified service.
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        // Retrieve heart rate information from the device
        if service.uuid == POLARH7_HRM_HEART_RATE_SERVICE_UUID {
            for aChar in service.characteristics! {
                if aChar.uuid == POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID {
                    self.polarH7Peripheral.setNotifyValue(true, for: aChar)
                    NSLog("Found heart rate measurement characteritic")
                }
            }
        }
        // Retrieve peripheral location from the device
            if service.uuid == POLARH7_HRM_HEART_RATE_SERVICE_UUID {
                for aChar in service.characteristics! {
                    if aChar.uuid == POLARH7_HRM_BODY_LOCATION_CHARACTERISTIC_UUID  {
                        self.polarH7Peripheral.setNotifyValue(true, for: aChar)
                        NSLog("Found body location characteritic")
                    }
                }
        }
        
        // Retrieve Device Information Services for the Manufactuers Name
        if service.uuid == POLARH7_HRM_DEVICE_INFO_SERVICE_UUID {
            for aChar in service.characteristics! {
                if aChar.uuid == POLARH7_HRM_MANUFACTURER_NAME_CHARACTERISTIC_UUID {
                    self.polarH7Peripheral.setNotifyValue(true, for: aChar)
                    NSLog("Found a device manufacturer name characteristic")
                }
            }
        }
    }


    
    // Invoked when you retrieve a specified characteristic's value, or when the peripheral device notifies your app that the characteristic's value has changed.
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        NSLog("Called didupdatevaluefor")
        var count:Data
        
        if characteristic.uuid == POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID  {
            count = characteristic.value!
            heartRateBPM.text = NSString(format: "%llu", count as CVarArg) as String
        } else if characteristic.uuid == POLARH7_HRM_BODY_LOCATION_CHARACTERISTIC_UUID {
            count = characteristic.value!
            bodyDataLabel.text = NSString(format: "%", count as CVarArg) as String
        }
    }
    
    // MARK:- CBCharacteristic helpers
    
    // Instance method to get the heart rate BPM information
    
    func getHeartBPMData(_ characteristic: CBCharacteristic, error: Error?) {
        
        // Get the Heart Rate Monitor BPM
        //var heartData = characteristic.value as NSData!
        var reportData = [UInt16]()
        var bpm: UInt16 = 0
        
        if ((reportData[0] & 0x01) == 0) {
            bpm = reportData[1]
        } else {
            bpm = 999 //CFSwapInt16LittleToHost(*(uint16_t *),(&reportData[1]))
        }

        // Display the heart rate value to the UI if no error occurred
        if( ((characteristic.value != nil))  || !(error != nil) ) {
            self.heartRate = bpm;
            self.heartRateBPM.text = "\(bpm)"
            self.heartRateBPM.font = UIFont(name: "Futura-CondensedMedium", size:100)
            //self.doHeartBeat()
            //self.pulseTimer = [NSTimer scheduledTimerWithTimeInterval:(60. / self.heartRate) target:self selector:@selector(doHeartBeat) userInfo:nil repeats:NO];
        }
        return self.view.addSubview(heartRateBPM)
    }
    
    
    // Instance method to get the manufacturer name of the device
    
    func getManufacturerName(_ characteristic: CBCharacteristic, error: Error?) {
        
    }
   
    // Instance method to get the body location of the device
    
    func getBodyLocation(_ characteristic: CBCharacteristic, error: Error?) {
        
    }
   
    // Helper method to perform a heartbeat animation
    func doHeartBeat() {
    
        let layer = CALayer(layer: self)
        
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.toValue = NSNumber(value: 1.1)
        pulseAnimation.fromValue = NSNumber(value: 1.0)
        
        pulseAnimation.duration = 120.0 // 60 / self.heartRate / 2
        pulseAnimation.repeatCount = 1
        pulseAnimation.autoreverses = true
        //pulseAnimation.timingFunction = kCAMediaTimingFunctionEaseIn(true)
        layer.add(pulseAnimation, forKey: "scale")
        
        // self.pulseTimer = [NSTimer scheduledTimerWithTimeInterval:(60. / self.heartRate) target:self selector:@selector(doHeartBeat) userInfo:nil repeats:NO];

        
    }
    
    
    // Stop scanning for BLE device
    func stopScanForBLEDevice(){
        centralManager?.stopScan()
        print("scan stopped")
        }
    }
