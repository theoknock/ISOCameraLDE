//
//  ScaleSliderViewTop.m
//  ISOCameraLDE
//
//  Created by Xcode Developer on 10/6/19.
//  Copyright © 2019 The Life of a Demoniac. All rights reserved.
//

#import "ScaleSliderViewTop.h"
#import "ScaleSliderLayerTop.h"

@implementation ScaleSliderViewTop

+ (Class)layerClass
{
    return [ScaleSliderLayerTop class];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

@end
