//
//  ScaleSliderControlView.m
//  ISOCameraLDE
//
//  Created by Xcode Developer on 10/3/19.
//  Copyright © 2019 The Life of a Demoniac. All rights reserved.
//

#import "ScaleSliderControlView.h"

@implementation ScaleSliderControlView

- (void)awakeFromNib
{
    [self setUserInteractionEnabled:TRUE];
    [self setMultipleTouchEnabled:TRUE];
    [self setExclusiveTouch:TRUE];
        
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.tapGestureRecognizer setNumberOfTapsRequired:1];
    [self.tapGestureRecognizer setNumberOfTouchesRequired:1];
    self.tapGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.tapGestureRecognizer];
    
    self.gestureRecognizers = @[self.tapGestureRecognizer];
    
    [super awakeFromNib];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setHidden:TRUE];
    });
}

- (void)show:(BOOL)show sender:(id)sender
{
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
