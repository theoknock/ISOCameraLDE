//
//  ScaleSliderControlView.m
//  ISOCameraLDE
//
//  Created by James Bush on 9/23/19.
//  Copyright © 2019 The Life of a Demoniac. All rights reserved.
//

#import "ScaleSliderControlView.h"

@interface ScaleSliderControlView ()
{
    CAGradientLayer *gradientLayer;
}

@end

@implementation ScaleSliderControlView




- (void)awakeFromNib
{
//    self.scrollView = (UIScrollView *)[self viewWithTag:-1];
//    [self.scrollView setDelegate:(id<UIScrollViewDelegate> _Nullable)self];
    
    self.ticks = 100;
    
    [(ScaleView *)[self viewWithTag:-2] setDelegate:(id<ScaleViewDelegate> _Nullable)self];
//    [self.contentView.layer setDelegate:(id<CALayerDelegate> _Nullable)self];
//    [[self scrollView] scrollRectToVisible:CGRectMake(CGRectGetMidX(self.frame), self.frame.origin.y, self.frame.size.width, self.frame.size.height) animated:TRUE];
//    [self.layer setDelegate:(id<CALayerDelegate> _Nullable)self];
    [super awakeFromNib];
}

//
//- (void)layoutSubviews
//{
//    self.scrollView.contentSize = CGSizeMake(
//                                             self.contentView.frame.size.width,
//                                             self.contentView.frame.size.height + 300
//                                             );
//}

//- (UIImageView *)contentView
//{
//    __block UIImageView *cv = self->_contentView;
//    if (!cv)
//    {
//        static dispatch_once_t onceToken;
//        dispatch_once(&onceToken, ^{
//            cv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contentViewImage.png"]];
//            [cv setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width * 2.0, self.frame.size.height)];
//        });
//
//        self->_contentView = cv;
//    }
//
//    return cv;
//}
//
//- (UIScrollView *)scrollView
//{
//    __block UIScrollView *sv = self->_scrollView;
//    if (!sv)
//    {
//        static dispatch_once_t onceToken;
//        dispatch_once(&onceToken, ^{
//            //    [contentView.layer addSublayer:[self gradientLayer]];
//            //    [gradientLayer setFrame:contentView.bounds];
//            sv = [[UIScrollView alloc] initWithFrame:self.bounds];
//            [sv setBackgroundColor:[UIColor grayColor]];
//            sv.contentSize = CGSizeMake(self.frame.size.width * 2.0, self.frame.size.height);
//            sv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//            [sv setScrollEnabled:TRUE];
//            [sv setContentInset:UIEdgeInsetsMake(0.0, 100.0, 0.0, 100)];
//            [sv addSubview:[self contentView]];
//            [self addSubview:sv];
//            [sv setDelegate:(id<UIScrollViewDelegate>)self];
//
//            self->_scrollView = sv;
//
//        });
//    }
//    return sv;
//}

- (CAGradientLayer *)gradientLayer
{
    gradientLayer = [CAGradientLayer new];
    gradientLayer.colors = @[[UIColor clearColor], [UIColor blackColor], [UIColor blackColor], [UIColor clearColor]];
    gradientLayer.locations = @[@(0), @(0.4), @(0.6), @(1)];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 0);
    
    return gradientLayer;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
