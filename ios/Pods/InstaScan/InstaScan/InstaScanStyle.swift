//
//  InstaScanStyle.swift
//  InstaScan
//
//  Created by Can Şener on 8.08.2022.
//

import Foundation
import UIKit
public class InstaScanStyle {

    public var validTextHighlightColor = UIColor(red: 16/255.0, green: 107/255.0, blue: 33/225.0, alpha: 1.0)
    public var invalidTextHighlightColor = UIColor(red: 148/255.0, green: 0/255.0, blue: 8/225.0, alpha: 1.0)
    public var guideTextColor = UIColor.white
    public var guideTextFont:UIFont = UIFont.systemFont(ofSize: 15.0, weight: .semibold)
    public var overlayColor = UIColor.black.withAlphaComponent(0.6)

    public init(){
        
    }

}
