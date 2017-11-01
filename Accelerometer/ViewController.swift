//
//  ViewController.swift
//  Accelerometer
//
//  Created by Markus Buhl on 20.10.17.
//  Copyright © 2017 Markus Buhl. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    //MARK: Properties
    
    //X-Component
    @IBOutlet weak var textField_sensorX: UILabel!
    @IBOutlet weak var progressView_sensorX: UIProgressView!
    
    //Y-Component
    @IBOutlet weak var textField_sensorY: UILabel!
    @IBOutlet weak var progressView_sensorY: UIProgressView!
    
    
    //Z-Component
    @IBOutlet weak var textField_sensorZ: UILabel!
    @IBOutlet weak var progressView_sensorZ: UIProgressView!
    
    //Accuracy-Slider
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var timeSliderValueLabel: UILabel!
    
    //Export-Button
    @IBOutlet weak var exportButton: UIButton!
    
    
    
    //MARK: MotionManager properties
    
    var motionManager: CMMotionManager?
    
    let updateIntervalFormatter = MeasurementFormatter()
    
    //MARK: Storage
    
    let csvExporter = CSVExporter()
    
    //MARK: Recording
    
    var isRecording = false
    
    //MARK: UIViewController overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        motionManager = CMMotionManager()
        
        timeSlider.minimumValue = 1 / 60
        timeSlider.maximumValue = 3.0
        
        timeSlider.value = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startUpdates()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopUpdates()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Interface Builder actions
    
    @IBAction func timeSliderChanged(_ sender: Any) {
        startUpdates()
    }
    
    @IBAction func exportButtonPressed(_ sender: Any) {
        if isRecording {
            exportAccelerometerData()
        } else {
            recordAccelerometerData()
        }
        
    }
    
    
    
    //MARK: Behaviour implementation

    func startUpdates() {
        //if motionManager fails to initialize or cant access accelerometer data, exit
        guard let motionManager = motionManager, motionManager.isAccelerometerAvailable else {
            self.textField_sensorX.text = "ff"
            return
            
        }
        let adjustedTimeSliderValue = timeSlider.maximumValue-timeSlider.value
        motionManager.accelerometerUpdateInterval = TimeInterval(adjustedTimeSliderValue)
        motionManager.showsDeviceMovementDisplay = true
        
        timeSliderValueLabel.text = String(format: "%.2f Sekunden", adjustedTimeSliderValue)
        print("Time slider value: \(timeSlider.value)")
        
        motionManager.startAccelerometerUpdates(to: .main) { accelerometerData, error in
            guard let accelerometerData = accelerometerData else {
                return
            }
            
            //output status of sensor X
            self.outputAccelerometerValue(value: accelerometerData.acceleration.x, component:"x", uiLabel: self.textField_sensorX, progressView: self.progressView_sensorX)
            
            //output status of sensor Y
            self.outputAccelerometerValue(value: accelerometerData.acceleration.y, component:"y", uiLabel: self.textField_sensorY, progressView: self.progressView_sensorY)
            
            //output status of sensor Z
            self.outputAccelerometerValue(value: accelerometerData.acceleration.z, component:"z", uiLabel: self.textField_sensorZ, progressView: self.progressView_sensorZ)
            
            //check if we're supposed to be recording
            if self.isRecording {
                //add values to csv file
                self.csvExporter.addToCSVData("\(accelerometerData.acceleration.x),\(accelerometerData.acceleration.y),\(accelerometerData.acceleration.z)")
            }
            
            
            
        }
        
    }
    
    func stopUpdates() {
        guard let motionManager = motionManager, motionManager.isAccelerometerAvailable else { return }
        
        motionManager.stopAccelerometerUpdates()
    }
    
    func outputAccelerometerValue(value: Double, component:String, uiLabel: UILabel, progressView: UIProgressView) {
        //What to output in the text field
        uiLabel.text = String(format: "\(component): %.2f", value)
        //What to output in the progess view
        progressView.setProgress(Float(abs(value)), animated: false)
        
        
    }
    
    func recordAccelerometerData() {
        self.exportButton.setTitle("Export", for: .normal)
        isRecording = true
        //add header to csv data
        csvExporter.addToCSVData("X-Component,Y-Component,Z-Component")
    }
    
    func exportAccelerometerData() {
        //stop recording
        isRecording = false
        //set button title back to "start recording"
        self.exportButton.setTitle("Start Recording", for: .normal)
        
        let path = csvExporter.storeCSVData()
        let vc = UIActivityViewController(activityItems: [path!], applicationActivities: [])
        vc.excludedActivityTypes = [
            UIActivityType.assignToContact,
            UIActivityType.saveToCameraRoll,
            UIActivityType.postToFlickr,
            UIActivityType.postToVimeo,
            UIActivityType.postToTencentWeibo,
            UIActivityType.postToTwitter,
            UIActivityType.postToFacebook,
            UIActivityType.openInIBooks
        ]
        self.present(vc, animated: true, completion: nil)
        
        csvExporter.eraseCSVData()
        
    }
    

}

