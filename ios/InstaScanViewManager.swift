//
//  TestViewManager.swift
//  InstaScanReactNative
//
//  Created by Gökhan on 26.08.2022.
//  Copyright © 2022 Facebook. All rights reserved.
//

import Foundation
import UIKit

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
      
    @objc func toggleTorch(_ node: NSNumber) {
        DispatchQueue.main.async {
            let component =  self.bridge.uiManager.view(
            forReactTag: node
          ) as! KZNInstaScanView
            
            component.toggleTorch()
        }
      }
    
    @objc func setTorch(_ node: NSNumber, _ status:Bool) {
        DispatchQueue.main.async {
            let component =  self.bridge.uiManager.view(
            forReactTag: node
          ) as! KZNInstaScanView
            
            component.setTorch(status)
        }
      }
    
    @objc func updateGuideText(_ node: NSNumber, _ text: NSString) {
        
        DispatchQueue.main.async {
            let component =  self.bridge.uiManager.view(
            forReactTag: node
          ) as! KZNInstaScanView
            
            component.updateGuideText(text as String)
        }
      }
  
    @objc func getTorchStatus(_ node: NSNumber, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
       
       DispatchQueue.main.async {
           let component =  self.bridge.uiManager.view(
           forReactTag: node
         ) as! KZNInstaScanView
           
           let status = component.getTorchStatus()
          
           resolve(status)
           
       }
     }
    
    
    public override func view() -> UIView! {
        return KZNInstaScanView()
      }
    
    
    public override class func requiresMainQueueSetup() -> Bool {
        return true
    }



}


