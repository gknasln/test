//
//  TestView.m
//  InstaScanReactNative
//
//  Created by Gökhan on 26.08.2022.
//  Copyright © 2022 Facebook. All rights reserved.
//

#import <React/RCTViewManager.h>


@interface RCT_EXTERN_MODULE(TestViewManager, RCTViewManager)
    RCT_EXTERN_METHOD(changeColor:(nonnull NSNumber *)node colorHex:(nonnull NSString*)colorHex)
    //RCT_EXPORT_VIEW_PROPERTY(zoomFactor, float)
    RCT_EXPORT_VIEW_PROPERTY(guideText, NSString)
    RCT_EXPORT_VIEW_PROPERTY(testColor, UIColor)
    RCT_EXPORT_VIEW_PROPERTY(testBoolean, BOOL)
    RCT_EXPORT_VIEW_PROPERTY(testNumber, NSInteger)
    RCT_EXPORT_VIEW_PROPERTY(testFloat, float)
    RCT_EXPORT_VIEW_PROPERTY(algorithm, NSInteger)
    RCT_EXPORT_VIEW_PROPERTY(onPincodeRead, RCTBubblingEventBlock)
    //RCT_EXPORT_VIEW_PROPERTY(testObject, NSDictionary)
@end
