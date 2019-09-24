//
//  ScaleSliderControlView.h
//  ISOCameraLDE
//
//  Created by James Bush on 9/23/19.
//  Copyright © 2019 The Life of a Demoniac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScaleSliderControlView : UIView <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *contentView;

@end

NS_ASSUME_NONNULL_END
