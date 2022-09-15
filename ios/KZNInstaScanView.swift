//
//  File.swift
//  InstaScanReactNative
//
//  Created by Gökhan on 31.08.2022.
//  Copyright © 2022 Facebook. All rights reserved.
//

import Foundation

@objc(KZNInstaScanView)
public class KZNInstaScanView:InstaScanView{
    @objc public var onPincodeRead:RCTBubblingEventBlock?
    
    @objc public func startScan(){
        print("startScan!")
        super.startScan(configuration: self.configuration)
    
    }
    
    @objc public var apiKey:String = ""{
        didSet{
             print("api key: " + apiKey)

            configuration.apiKey = apiKey
        }
    }
    
    override func onPincodeReaded(_ result: InstaScanResult) {
        super.onPincodeReaded(result)
        var event:[String:Any] = [:]
        event["pincode"] = result.pincode
        event["image"] = result.image
        event["configuration"] = result.configuration
        
        onPincodeRead?(event)
    }
    
    
    /*
     @objc public var testColor:UIColor = .red{
         didSet{
             self.backgroundColor = testColor
         }
     }
    @objc public var testBoolean:Bool = true{
        didSet{
            print("Test Booean: \(testBoolean)")
        }
    }
    
    @objc public var testNumber:Int = 1{
        didSet{
            print("Test Number: \(testNumber)")

        }
    }
    
    @objc public var testFloat:Float = 1.0{
        didSet{
            
            print("Test Booean: \(testFloat)")
        }
    }

    
    
    @objc public var guideText:String = ""{
        didSet{
            configuration.guideText = guideText
        }
    }
    
    @objc public var algorithm:InstaScanAlgorithm = .accurate{
        didSet{
            configuration.settings.algorithm = algorithm
        }
    }

    override func changeColor(color: UIColor) {
        super.changeColor(color: color)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            var event = [AnyHashable: Any]()
            event["pincode"] = "ABCDEFGH"
            
            self.onPincodeRead?(event)
        }
    }
 */
    
}
