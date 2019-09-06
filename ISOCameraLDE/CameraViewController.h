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

@interface CameraViewController : UIViewController <UIGestureRecognizerDelegate, CameraControlsDelegate>

@property (weak, nonatomic) IBOutlet CameraControlsView *cameraControlsView;
@property (assign) float ISO;
- (void)setISO:(float)ISO;

@property (assign) float focus;
- (void)setFocus:(float)focus;

- (void)incrementFocus:(float)increment;
- (void)decrementFocus:(float)decrement;

- (void)incrementISO:(float)increment;
- (void)decrementISO:(float)decrement;

@end

NS_ASSUME_NONNULL_END
