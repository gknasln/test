//
//  SettingsModel.swift
//  PincodeReader
//
//  Created by Can Şener on 11.06.2022.
//

import UIKit
import AVFoundation
import Vision

public class InstaScanSettings {
    
    //Default values
    public var algorithm = InstaScanAlgorithm.accurate
    public var zoomFactor = 2.0
    public var resolution = InstaScanResolution.hdw1280h720
    public var sampleCount = 10
    public var lang = "en-US"
    public var focusRestriction = InstaScanFocusRestriction.near
    public var minTextHeight = 0.5
    public var guideAreaAspectRatio = 5.0
    public var guideAreaWidthRatio = 0.8
    public var languageCorrection = false
    
    public init(){
        
    }
    

}
