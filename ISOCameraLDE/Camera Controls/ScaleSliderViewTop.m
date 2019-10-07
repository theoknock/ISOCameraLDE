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

@synthesize delegate = _delegate, selectedCameraPropertyValue = _selectedCameraPropertyValue;

- (void)setDelegate:(id<ScaleSliderViewTopDelegate>)delegate
{
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    _delegate = delegate;
//    NSLog(@"%@", [(NSObject *)_delegate description]);
}

- (id<ScaleSliderViewTopDelegate>)delegate
{
    return _delegate;
}

- (NSValue *)selectedCameraPropertyValue
{
    return self->_selectedCameraPropertyValue;
}

- (void)setSelectedCameraPropertyValue:(NSValue *)selectedCameraPropertyValue
{
//    NSLog(@"selectedCameraPropertyValue %@", [(NSValue *)selectedCameraPropertyValue description]);
    self->_selectedCameraPropertyValue = selectedCameraPropertyValue;
    double offset = 166 + 42.0;//((CGRect)[(NSValue *)[self.delegate selectedCameraPropertyFrame] CGRectValue]).origin.x + 42.0;
    [(ScaleSliderLayerTop *)self.layer setMeasurementIndicatorHorizontalOffset:offset];
//    NSLog(@"[self.delegate selectedCameraPropertyFrame].origin.x %f", offset);
}

+ (Class)layerClass
{
    return [ScaleSliderLayerTop class];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    
    
}

@end
