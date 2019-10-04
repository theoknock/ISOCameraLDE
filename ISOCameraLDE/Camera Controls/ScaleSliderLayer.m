//
//  ScaleSliderLayer.m
//  ISOCameraLDE
//
//  Created by Xcode Developer on 10/3/19.
//  Copyright © 2019 The Life of a Demoniac. All rights reserved.
//

#import "ScaleSliderLayer.h"

@implementation ScaleSliderLayer

- (CGColorRef)backgroundColor
{
    return [[UIColor clearColor] CGColor];
}

- (BOOL)isOpaque
{
    return FALSE;
}

- (void)drawInContext:(CGContextRef)ctx
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    CGRect bounds = [self bounds];
    CGContextTranslateCTM(ctx, CGRectGetMinX(bounds), CGRectGetMinY(bounds));

    CGFloat stepSize = (CGRectGetMaxX(bounds) / 100.0);
    for (int t = 0; t <= 100; t++) {
        CGFloat x = (CGRectGetMinX(bounds) + (stepSize * t));
        if (t % 10 == 0)
        {
            CGContextSetStrokeColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
            CGContextSetLineWidth(ctx, 1.0);
            CGContextMoveToPoint(ctx, x, CGRectGetMidY(bounds) + (CGRectGetMidY(bounds) / 2.0));
            CGContextAddLineToPoint(ctx, x, CGRectGetMinY(bounds) + (CGRectGetMidY(bounds) / 2.0));
        }
        else
        {
            CGContextSetStrokeColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
            CGContextSetLineWidth(ctx, 0.25);
            CGContextMoveToPoint(ctx, x, CGRectGetMidY(bounds) + (CGRectGetMidY(bounds) / 4.0));
            CGContextAddLineToPoint(ctx, x, CGRectGetMinY(bounds) + (CGRectGetMidY(bounds) / 4.0));
        }
        
        
        CGContextStrokePath(ctx);
    }
}

@end
