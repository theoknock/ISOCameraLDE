//
//  CameraControlsView.h
//  ISOCameraLDE
//
//  Created by James Alan Bush on 9/5/19.
//  Copyright © 2019 The Life of a Demoniac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ControlButtonTag) {
    ControlButtonTagRecord = 1,
    ControlButtonTagExposureDuration = 2,
    ControlButtonTagISO   = 3,
    ControlButtonTagFocus = 4,
    ControlButtonTagTorch = 5
};

typedef NS_ENUM(NSUInteger, ExposureDurationMode) {
    ExposureDurationModeNormal,
    ExposureDurationModeLong
};

typedef NS_ENUM(NSUInteger, CameraProperty) {
    CameraPropertyFocus = 4,
    CameraPropertyISO = 3,
    CameraPropertyTorch = 5
};

typedef void (^SetCameraPropertyBlock)(CameraProperty property, CGFloat value);

@protocol CameraControlsDelegate <NSObject>

@required

@property (nonatomic) AVCaptureDevice *videoDevice;

- (void)targetExposureDuration:(CMTime)exposureDuration withCompletionHandler:(void (^)(CMTime currentExposureDuration))completionHandler;

@property (assign) float ISO;
- (void)setISO:(float)ISO;
- (void)autoExposureWithCompletionHandler:(void (^)(double ISO))completionHandler;

@property (assign) float focus;
- (void)setFocus:(float)focus;
- (void)autoFocusWithCompletionHandler:(void (^)(double focus))completionHandler;

- (void)setTorchLevel:(float)torchLevel;

- (void)toggleRecordingWithCompletionHandler:(void (^)(BOOL isRunning, NSError *error))completionHandler;

- (void)toggleTorchWithCompletionHandler:(void (^)(BOOL isTorchActive))completionHandler;

- (void)scrollSliderControlToItemAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)lockDevice;
- (SetCameraPropertyBlock)setCameraProperty;
- (void)unlockDevice;

@end

@interface CameraControlsView : UIView <UIGestureRecognizerDelegate, CALayerDelegate>

//+ (nonnull CameraControlsView *)cameraControls;

@property (nonatomic, assign, nullable) id<CameraControlsDelegate> delegate;

@property (nonatomic, nullable) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, nullable) UITapGestureRecognizer *tapGestureRecognizer;

@end

NS_ASSUME_NONNULL_END
