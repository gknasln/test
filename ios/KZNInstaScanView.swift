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
    @objc public var onInstaScanError:RCTBubblingEventBlock?

    @objc public func startScan(){
        super.startScan(configuration: self.configuration)
    
    }
    
    override func onError(_ error: Error) {
        super.onError(error)
        var event:[String:Any] = [:]
        let err = error as NSError
        event["code"] = err.code
        event["description"] = err.localizedDescription
        event["recoverySuggestion"] = err.localizedRecoverySuggestion ?? ""
        event["failureReason"] = err.localizedFailureReason ?? ""
        onInstaScanError?(event)
    }

    override func onPincodeReaded(_ result: InstaScanResult) {
        super.onPincodeReaded(result)
        var event:[String:Any] = [:]
        event["pincode"] = result.pincode
        let jpegData = result.image.jpegData(compressionQuality: 0.8)
        let tempPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let filePath = tempPath.appendingPathComponent("\(UUID().uuidString).jpeg")
        if let image = result.image, let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: filePath)
        }
        event["imagePath"] = filePath.absoluteString
        event["configuration"] = result.configuration.description
        onPincodeRead?(event)
    }
    
    @objc public var torchStatus:Bool{
        get{
            return getTorchStatus()
        }
    }
    
    //MARK: Root Configuration
    @objc public var apiKey:String = ""{
        didSet{
            configuration.apiKey = apiKey
        }
    }
    
    @objc public var guideText:String = ""{
        didSet{
            configuration.guideText = guideText
        }
    }
    
    //MARK: Settings
    @objc public var algorithm:InstaScanAlgorithm = .accurate{
        didSet{
            settings.algorithm = algorithm
        }
    }
    
    @objc public var resolution:InstaScanResolution = .hdw1280h720{
        didSet{
            settings.resolution = resolution
        }
    }
    
    @objc public var focusRestriction:InstaScanFocusRestriction = .near{
        didSet{
           settings.focusRestriction = focusRestriction
        }
    }

    @objc public var zoomFactor:Double = 2.0{
        didSet{
           settings.zoomFactor = zoomFactor
        }
    }
    
    @objc public var sampleCount:Int = 10{
        didSet{
           settings.sampleCount = sampleCount
        }
    }
    
    @objc public var lang:String = "en-US"{
        didSet{
           settings.lang = lang
        }
    }
    
    @objc public var languageCorrection:Bool = false{
        didSet{
           settings.languageCorrection = languageCorrection
        }
    }
    
    @objc public var minTextHeight:Double = 0.5{
        didSet{
           settings.minTextHeight = minTextHeight
        }
    }
    
    @objc public var guideAreaAspectRatio:Double = 5.0{
        didSet{
           settings.guideAreaAspectRatio = guideAreaAspectRatio
        }
    }
    
    @objc public var guideAreaWidthRatio:Double = 0.8{
        didSet{
           settings.guideAreaWidthRatio = guideAreaWidthRatio
        }
    }
    
    //MARK: Rules
    @objc public var allowedChars:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"{
        didSet{
           rules.allowedChars = allowedChars
        }
    }
    
    @objc public var minDigits:Int = 6{
        didSet{
           rules.minDigits = minDigits
        }
    }
    
    @objc public var maxDigits:Int = 12{
        didSet{
           rules.maxDigits = minDigits
        }
    }
    
    @objc public var replaceMap:[String:String]  = [:]{
        didSet{
           rules.replaceMap = replaceMap
        }
    }
    
    //MARK: Style
    @objc public var overlayColor:String = ""{
        didSet{
           style.overlayColor = UIColor.init(hexString: overlayColor)
        }
    }
    
    @objc public var guideTextColor:String = ""{
        didSet{
           style.guideTextColor = UIColor.init(hexString: guideTextColor)
        }
    }
    
    @objc public var validTextHighlightColor:String = ""{
        didSet{
           style.validTextHighlightColor = UIColor.init(hexString: validTextHighlightColor)
        }
    }
    
    @objc public var invalidTextHighlightColor:String = ""{
        didSet{
           style.invalidTextHighlightColor = UIColor.init(hexString: invalidTextHighlightColor)
        }
    }
    
    @objc public var guideTextFontName:String = ""{
        didSet{
           
            style.guideTextFont = UIFont(name: guideTextFontName, size: CGFloat(guideTextFontSize)) ?? UIFont.systemFont(ofSize: CGFloat(guideTextFontSize), weight: .semibold)
        }
    }
    
    @objc public var guideTextFontSize:Float = 15{
        didSet{
            if (!guideTextFontName.isEmpty){
                style.guideTextFont = UIFont(name: guideTextFontName, size: CGFloat(guideTextFontSize)) ?? UIFont.systemFont(ofSize: CGFloat(guideTextFontSize), weight: .semibold)
            }
        }
    }
    
    
}
