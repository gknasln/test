//
//  TestViewManager.swift
//  InstaScanReactNative
//
//  Created by Gökhan on 26.08.2022.
//  Copyright © 2022 Facebook. All rights reserved.
//

import Foundation
import UIKit


@objc(TestViewManager)
public class TestViewManager : RCTViewManager {
    public override func view() -> UIView! {
    return TestView()
  }
    


}


