//
//  CameraControlsView.h
//  ISOCameraLDE
//
//  Created by Xcode Developer on 9/5/19.
//  Copyright © 2019 The Life of a Demoniac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CameraControlsDelegate <NSObject>

@required

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

@interface CameraControlsView : UIView <UIGestureRecognizerDelegate>

//+ (nonnull CameraControlsView *)cameraControls;

@property (nonatomic, assign, nullable) id<CameraControlsDelegate> delegate;

@property (nonatomic, nullable) UIPanGestureRecognizer *panGestureRecognizer;
- (IBAction)record:(id)sender;
- (IBAction)focus:(id)sender;

@end

NS_ASSUME_NONNULL_END
