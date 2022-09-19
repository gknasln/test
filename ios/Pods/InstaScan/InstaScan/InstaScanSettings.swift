//
//  SettingsModel.swift
//  PincodeReader
//
//  Created by Can Şener on 11.06.2022.
//

import UIKit
import AVFoundation
import Vision

public class InstaScanSettings: Encodable {
    
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
    
    enum CodingKeys: String, CodingKey {
      case algorithm, zoomFactor, resolution, sampleCount, lang, focusRestriction, minTextHeight, guideAreaAspectRatio,guideAreaWidthRatio,languageCorrection
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(algorithm.rawValue, forKey: .algorithm)
        try container.encode(zoomFactor, forKey: .zoomFactor)
        try container.encode(resolution.rawValue, forKey: .resolution)
        try container.encode(sampleCount, forKey: .sampleCount)
        try container.encode(lang, forKey: .lang)
        try container.encode(focusRestriction.rawValue, forKey: .focusRestriction)
        try container.encode(minTextHeight, forKey: .minTextHeight)
        try container.encode(guideAreaAspectRatio, forKey: .guideAreaAspectRatio)
        try container.encode(guideAreaWidthRatio, forKey: .guideAreaWidthRatio)
        try container.encode(languageCorrection, forKey: .languageCorrection)
    }
    
  

}
