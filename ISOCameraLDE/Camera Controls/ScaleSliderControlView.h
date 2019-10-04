//
//  ScaleSliderControlView.h
//  ISOCameraLDE
//
//  Created by James Bush on 9/23/19.
//  Copyright © 2019 The Life of a Demoniac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScaleView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ScaleSliderControlView : UIView <UIScrollViewDelegate, ScaleViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;

@property (assign) NSInteger ticks;

@end

NS_ASSUME_NONNULL_END
