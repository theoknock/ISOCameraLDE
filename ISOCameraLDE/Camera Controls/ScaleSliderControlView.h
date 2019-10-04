//
//  ScaleSliderControlView.h
//  ISOCameraLDE
//
//  Created by Xcode Developer on 10/3/19.
//  Copyright © 2019 The Life of a Demoniac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScaleSliderControlView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, nullable) UITapGestureRecognizer *tapGestureRecognizer;

- (void)show:(BOOL)show sender:(id)sender;

@end

NS_ASSUME_NONNULL_END
