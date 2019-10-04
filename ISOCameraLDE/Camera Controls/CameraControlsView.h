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
    CameraPropertyISO = 3,
    CameraPropertyFocus = 4,
    CameraPropertyTorch = 5
};

typedef void (^SetCameraPropertyValueBlock)(CameraProperty cameraProperty, CGFloat value);

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
- (SetCameraPropertyValueBlock)setCameraProperty:(CameraProperty)cameraProperty;
- (void)unlockDevice;
- (float)valueForCameraProperty:(CameraProperty)cameraProperty;

@end

@interface CameraControlsView : UIView <CALayerDelegate, UIScrollViewDelegate>

//+ (nonnull CameraControlsView *)cameraControls;

@property (nonatomic, assign, nullable) id<CameraControlsDelegate> delegate;

//@property (nonatomic, nullable) UIPanGestureRecognizer *panGestureRecognizer;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *cameraControlButtons;
@property (weak, nonatomic) IBOutlet UIView *scaleSliderControlView;
@property (weak, nonatomic) IBOutlet UIScrollView *scaleSliderScrollView;
@property (weak, nonatomic) IBOutlet UIStackView *cameraControlButtonsStackView;

@end

NS_ASSUME_NONNULL_END
