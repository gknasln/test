//
//  TestViewManager.swift
//  InstaScanReactNative
//
//  Created by Gökhan on 26.08.2022.
//  Copyright © 2022 Facebook. All rights reserved.
//

import Foundation
import UIKit


extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}


@objc(InstaScanViewManager)
public class InstaScanViewManager : RCTViewManager {

    @objc func startScan(_ node: NSNumber) {
        DispatchQueue.main.async {
            let component =  self.bridge.uiManager.view(
            forReactTag: node
          ) as! KZNInstaScanView
            
            component.startScan()
        }
      }
      
    
    @objc func stopScan(_ node: NSNumber) {
        DispatchQueue.main.async {
            let component =  self.bridge.uiManager.view(
            forReactTag: node
          ) as! KZNInstaScanView
            
            component.stopScan()
        }
      }
      
    @objc func restartScan(_ node: NSNumber) {
        DispatchQueue.main.async {
            let component =  self.bridge.uiManager.view(
            forReactTag: node
          ) as! KZNInstaScanView
            
            component.restartScan()
        }
      }
      
  
    
    public override func view() -> UIView! {
        return KZNInstaScanView()
      }
    
    
    



}


