//
//  InstaScanConfiguration.swift
//  InstaScan
//
//  Created by Can Şener on 11.08.2022.
//

import Foundation

public class InstaScanConfiguration: Encodable, CustomStringConvertible {
    var apiKey:String!
    public var settings:InstaScanSettings = InstaScanSettings()
    public var style:InstaScanStyle = InstaScanStyle()
    public var rules:InstaScanRules = InstaScanRules()
    public var guideText:String = ""
    
    public convenience init(apiKey:String){
        self.init()
        self.apiKey = apiKey
    }
    public var description: String{
        let encoder = JSONEncoder()
        
        if let data = try? encoder.encode(self), let string = String(data: data, encoding: .utf8) {
            return string
        }
        
        return ""
    }
    
}
