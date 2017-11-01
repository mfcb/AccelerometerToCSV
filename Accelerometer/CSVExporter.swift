//
//  CSVExporter.swift
//  Accelerometer
//
//  Created by Markus Buhl on 27.10.17.
//  Copyright © 2017 Markus Buhl. All rights reserved.
//

import Foundation
import UIKit

class CSVExporter {
    
    var fileName = "output.csv"
    var path: URL?
    
    var CSVData:String = ""
    
    init() {
        setup()
    }
    
    init(withFileName fileName: String) {
        self.fileName = fileName
        setup()
    }
    
    private func setup() {
        self.path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(self.fileName)
        
    }
    
    func addToCSVData(_ data:String) {
        CSVData.append(data)
        CSVData.append("\n")
        print(CSVData)
    }
    
    
    func storeCSVData() -> URL? {
        do {
            try self.CSVData.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
            return path!
        } catch {
            print("Failed to create file")
            print("\(error)")
            return nil
        }
        
        
    }
    
    func eraseCSVData() {
        CSVData = ""
    }
    
}
