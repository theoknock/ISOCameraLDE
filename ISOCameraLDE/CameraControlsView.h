//
//  CameraControlsView.h
//  ISOCameraLDE
//
//  Created by Xcode Developer on 9/5/19.
//  Copyright © 2019 The Life of a Demoniac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ControlButtonTag) {
    ControlButtonTagFocus = 2,
    ControlButtonTagISO   = 1,
    ControlButtonTagTorch = 3
};

typedef NS_ENUM(NSUInteger, ExposureDurationMode) {
    ExposureDurationModeNormal,
    ExposureDurationModeLong
};

@protocol CameraControlsDelegate <NSObject>

@required

@property (nonatomic) AVCaptureDevice *videoDevice;

- (void)targetExposureDuration:(CMTime)exposureDuration withCompletionHandler:(void (^)(CMTime currentExposureDuration))completionHandler;

@property (assign) float ISO;
- (void)setISO:(float)ISO;

@property (assign) float focus;
- (void)setFocus:(float)focus;

- (void)setTorchLevel:(float)torchLevel;

- (void)toggleRecordingWithCompletionHandler:(void (^)(BOOL isRunning, NSError *error))completionHandler;

- (void)toggleTorchWithCompletionHandler:(void (^)(BOOL isTorchActive))completionHandler;
@end

@interface CameraControlsView : UIView <UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

//+ (nonnull CameraControlsView *)cameraControls;

@property (nonatomic, assign, nullable) id<CameraControlsDelegate> delegate;

@property (nonatomic, nullable) UIPanGestureRecognizer *panGestureRecognizer;

@end

NS_ASSUME_NONNULL_END
