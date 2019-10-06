//
//  ScaleSliderLayerTop.m
//  ISOCameraLDE
//
//  Created by Xcode Developer on 10/6/19.
//  Copyright © 2019 The Life of a Demoniac. All rights reserved.
//

#import "ScaleSliderLayerTop.h"

@implementation ScaleSliderLayerTop

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
    CGFloat height_eighth = (CGRectGetHeight(bounds) / 8.0);
    CGFloat height_sixteenth = (CGRectGetHeight(bounds) / 16.0);
    CGFloat height_thirtyseconth = (CGRectGetHeight(bounds) / 16.0);
    CGContextSetStrokeColorWithColor(ctx, [[UIColor yellowColor] CGColor]);
    CGContextSetLineWidth(ctx, 2.0);
    CGContextMoveToPoint(ctx, CGRectGetMidX(bounds), (CGRectGetMinY(bounds) + height_eighth) - height_thirtyseconth);
    CGContextAddLineToPoint(ctx, CGRectGetMidX(bounds), (CGRectGetMidY(bounds) - height_eighth) - height_thirtyseconth);
        CGContextStrokePath(ctx);
}

@end
