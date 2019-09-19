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

typedef NS_ENUM(NSUInteger, ControlButtonTag) {
    ControlButtonTagFocus = 2,
    ControlButtonTagISO = 1
};

typedef NS_ENUM(NSUInteger, ExposureDurationMode) {
    ExposureDurationModeNormal,
    ExposureDurationModeLong
};

typedef void (^ExposureDurationModeConfigurationCompletionBlock)(CMTime currentExposureDuration);

@protocol CameraControlsDelegate <NSObject>

@required

- (void)targetExposureDuration:(CMTime)exposureDuration withCompletionHandler:(ExposureDurationModeConfigurationCompletionBlock)completionBlock;

@property (assign) float ISO;
- (void)setISO:(float)ISO;

@property (assign) float focus;
- (void)setFocus:(float)focus;

- (void)toggleRecordingWithCompletionHandler:(void (^)(BOOL isRunning, NSError *error))completionHandler;

@end

@interface CameraControlsView : UIView <UIGestureRecognizerDelegate>

//+ (nonnull CameraControlsView *)cameraControls;

@property (nonatomic, assign, nullable) id<CameraControlsDelegate> delegate;

@property (nonatomic, nullable) UIPanGestureRecognizer *panGestureRecognizer;
- (IBAction)record:(id)sender;
- (IBAction)focus:(UIButton *)sender;
- (IBAction)exposureDuration:(UIButton *)sender;
- (IBAction)iso:(UIButton *)sender;

@end

NS_ASSUME_NONNULL_END
