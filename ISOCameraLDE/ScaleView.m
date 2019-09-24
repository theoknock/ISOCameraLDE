//
//  ScaleView.m
//  ISOCameraLDE
//
//  Created by Xcode Developer on 9/24/19.
//  Copyright © 2019 The Life of a Demoniac. All rights reserved.
//

#import "ScaleView.h"

@implementation ScaleView

@synthesize delegate = _delegate;

- (id<ScaleViewDelegate>)delegate
{
    return _delegate;
}

- (void)setDelegate:(id<ScaleViewDelegate>)delegate
{
    _delegate = delegate;
}

 - (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    CGRect bounds = [self.superview frame];
    CGContextTranslateCTM(ctx, CGRectGetMinX(bounds), CGRectGetMinY(bounds));

    id presentationLayer = [layer presentationLayer];
    CGContextSetStrokeColorWithColor(ctx, [[UIColor systemBlueColor] CGColor]);
    CGContextSetLineWidth(ctx, 2.0);

    unsigned int stepSize = ((unsigned int)CGRectGetWidth(bounds) * 2.0) / self.delegate.ticks;
    for (int t = 0; t <= self.delegate.ticks; t++) {
        unsigned int x = ((unsigned int)CGRectGetMinX(bounds) + (stepSize * t));
        CGContextMoveToPoint(ctx, x, CGRectGetMaxY(bounds));
        CGContextAddLineToPoint(ctx, x, (t % 10 == 0) ? CGRectGetMinY(bounds) : CGRectGetMidY(bounds));
    }

    CGContextStrokePath(ctx);
}

@end
