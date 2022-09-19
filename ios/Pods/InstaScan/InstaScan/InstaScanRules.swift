//
//  InstaScanRules.swift
//  InstaScan
//
//  Created by Can Şener on 11.08.2022.
//

import Foundation

public class InstaScanRules : Encodable{
    public var allowedChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    public var minDigits = 6
    public var maxDigits = 12
    public var replaceMap:[String:String] = [:]
}
