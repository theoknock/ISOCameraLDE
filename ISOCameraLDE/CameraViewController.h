//
//  CameraViewController.h
//  ISOCameraLDE
//
//  Created by Xcode Developer on 6/17/19.
//  Copyright © 2019 The Life of a Demoniac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>
#import "CameraControlsView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CameraViewController : UIViewController <CameraControlsDelegate>

@property (nonatomic) AVCaptureDevice *videoDevice;

@property (nonatomic, assign) float ISO;
- (void)setISO:(float)ISO;

@property (assign) float focus;
- (void)setFocus:(float)focus;

- (void)toggleRecordingWithCompletionHandler:(void (^)(BOOL isRunning, NSError *error))completionHandler;
- (void)targetExposureDuration:(CMTime)exposureDuration withCompletionHandler:(void (^)(CMTime currentExposureDuration))completionHandler;
- (void)toggleTorchWithCompletionHandler:(void (^)(BOOL isTorchActive))completionHandler;

- (void)setTorchLevel:(float)torchLevel;

@end

NS_ASSUME_NONNULL_END
