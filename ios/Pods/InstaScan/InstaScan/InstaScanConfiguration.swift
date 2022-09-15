//
//  InstaScanConfiguration.swift
//  InstaScan
//
//  Created by Can Şener on 11.08.2022.
//

import Foundation

public class InstaScanConfiguration {
    var apiKey:String!
    public var settings:InstaScanSettings = InstaScanSettings()
    public var style:InstaScanStyle = InstaScanStyle()
    public var rules:InstaScanRules = InstaScanRules()
    public var guideText:String = ""
    
    public convenience init(apiKey:String){
        self.init()
        self.apiKey = apiKey
    }
   
    
}
