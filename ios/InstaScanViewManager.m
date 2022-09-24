//
//  TestView.m
//  InstaScanReactNative
//
//  Created by Gökhan on 26.08.2022.
//  Copyright © 2022 Facebook. All rights reserved.
//

#import <React/RCTViewManager.h>


@interface RCT_EXTERN_REMAP_MODULE(KZNInstaScanView, InstaScanViewManager, RCTViewManager)

    RCT_EXTERN_METHOD(startScan:(nonnull NSNumber *)node)
    RCT_EXTERN_METHOD(stopScan:(nonnull NSNumber *)node)
    RCT_EXTERN_METHOD(restartScan:(nonnull NSNumber *)node)
    RCT_EXTERN_METHOD(toggleTorch:(nonnull NSNumber *)node)
    RCT_EXTERN_METHOD(setTorch:(nonnull NSNumber *)node :(BOOL)status)
    RCT_EXTERN_METHOD(updateGuideText:(nonnull NSNumber *)node :(NSString)text)

    RCT_EXTERN_METHOD(getTorchStatus:(nonnull NSNumber *)node resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)

    RCT_EXPORT_VIEW_PROPERTY(torchStatus, BOOL)

    RCT_EXPORT_VIEW_PROPERTY(apiKey, NSString)
    RCT_EXPORT_VIEW_PROPERTY(guideText, NSString)

    RCT_EXPORT_VIEW_PROPERTY(algorithm, NSInteger)
    RCT_EXPORT_VIEW_PROPERTY(resolution, NSInteger)
    RCT_EXPORT_VIEW_PROPERTY(focusRestriction, NSInteger)
    RCT_EXPORT_VIEW_PROPERTY(zoomFactor, double)
    RCT_EXPORT_VIEW_PROPERTY(sampleCount, NSInteger)
    RCT_EXPORT_VIEW_PROPERTY(lang, NSString)
    RCT_EXPORT_VIEW_PROPERTY(languageCorrection, BOOL)
    RCT_EXPORT_VIEW_PROPERTY(minTextHeight, double)
    RCT_EXPORT_VIEW_PROPERTY(guideAreaAspectRatio, double)
    RCT_EXPORT_VIEW_PROPERTY(guideAreaWidthRatio, double)

    RCT_EXPORT_VIEW_PROPERTY(allowedChars, NSString)
    RCT_EXPORT_VIEW_PROPERTY(minDigits, NSInteger)
    RCT_EXPORT_VIEW_PROPERTY(maxDigits, NSInteger)
    RCT_EXPORT_VIEW_PROPERTY(replaceMap, NSDictionary)


    RCT_EXPORT_VIEW_PROPERTY(overlayColor, NSString)
    RCT_EXPORT_VIEW_PROPERTY(guideTextColor, NSString)
    RCT_EXPORT_VIEW_PROPERTY(validTextHighlightColor, NSString)
    RCT_EXPORT_VIEW_PROPERTY(invalidTextHighlightColor, NSString)
    RCT_EXPORT_VIEW_PROPERTY(guideTextFontName, NSString)
    RCT_EXPORT_VIEW_PROPERTY(guideTextFontSize, float)


    RCT_EXPORT_VIEW_PROPERTY(onPincodeRead, RCTBubblingEventBlock)
    RCT_EXPORT_VIEW_PROPERTY(onInstaScanError, RCTBubblingEventBlock)


@end
