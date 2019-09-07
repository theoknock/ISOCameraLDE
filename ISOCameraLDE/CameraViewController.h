//
//  CameraViewController.h
//  ISOCameraLDE
//
//  Created by Xcode Developer on 6/17/19.
//  Copyright © 2019 The Life of a Demoniac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraControlsView.h"

NS_ASSUME_NONNULL_BEGIN

@class CameraControlsView;

@interface CameraViewController : UIViewController

@property (assign) float ISO;
- (void)setISO:(float)ISO;

@property (assign) float focus;
- (void)setFocus:(float)focus;
- (void)normalizeExposureDuration:(BOOL)shouldNormalizeExposureDuration;

- (void)incrementFocus;
- (void)decrementFocus;

- (void)incrementISO;
- (void)decrementISO;

- (void)toggleRecordingWithCompletionHandler:(void (^)(BOOL isRunning, NSError *error))completionHandler;

@end

NS_ASSUME_NONNULL_END
