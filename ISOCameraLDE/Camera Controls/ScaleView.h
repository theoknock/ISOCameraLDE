//
//  ScaleView.h
//  ISOCameraLDE
//
//  Created by Xcode Developer on 9/24/19.
//  Copyright © 2019 The Life of a Demoniac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ScaleViewDelegate <NSObject>

@property (assign) NSInteger ticks;

@end

@interface ScaleView : UIView

@property (weak, nonatomic) id<ScaleViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
