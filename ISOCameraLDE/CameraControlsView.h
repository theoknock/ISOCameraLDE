//
//  CameraControlsView.h
//  ISOCameraLDE
//
//  Created by Xcode Developer on 9/5/19.
//  Copyright © 2019 The Life of a Demoniac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CameraControlsDelegate

@required

@property (assign) float ISO;
- (void)setISO:(float)ISO;

@property (assign) float focus;
- (void)setFocus:(float)focus;

- (void)incrementFocus:(float)increment;
- (void)decrementFocus:(float)decrement;

- (void)incrementISO:(float)increment;
- (void)decrementISO:(float)decrement;

@end

@interface CameraControlsView : UIView <UIGestureRecognizerDelegate>

//+ (nonnull CameraControlsView *)cameraControls;

@property (nonatomic, assign, nullable) id<CameraControlsDelegate> delegate;

@property (nonatomic, nullable) UIPanGestureRecognizer *panGestureRecognizer;

@end

NS_ASSUME_NONNULL_END
