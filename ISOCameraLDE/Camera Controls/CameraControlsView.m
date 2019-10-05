//
//  CameraControlsView.m
//  ISOCameraLDE
//
//  Created by Xcode Developer on 9/5/19.
//  Copyright © 2019 The Life of a Demoniac. All rights reserved.
//

#import "CameraControlsView.h"
//#import "CollectionViewCell.h"
#import "ScaleSliderLayer.h"

@interface CameraControlsView ()
{
    CGPoint firstTouchInView;
    CAScrollLayer *scrollLayer;
    ScaleSliderLayer *scaleSliderLayer;
    __block SetCameraPropertyValueBlock setCameraPropertyValueBlock;
}

@end

@implementation CameraControlsView

static NSString * const reuseIdentifier = @"CollectionViewCellReuseIdentifier";

@synthesize delegate = _delegate;

//+ (Class)layerClass
//{
//    return [ScaleSliderLayer class];
//}

- (void)setDelegate:(id<CameraControlsDelegate>)delegate
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    _delegate = delegate;
    NSLog(@"%@", [(NSObject *)_delegate description]);
}

- (id<CameraControlsDelegate>)delegate
{
    return _delegate;
}

//+ (CameraControlsView *)cameraControls
//{
//    static CameraControlsView *_sharedInstance = nil;
//    static dispatch_once_t onceSecurePredicate;
//    dispatch_once(&onceSecurePredicate,^
//                  {
//        _sharedInstance = [[self alloc] init];
//    });
//    return _sharedInstance;
//}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.scaleSliderControlView addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];
    
    CGFloat inset = CGRectGetMidX(self.frame);
    [self.scaleSliderScrollView setContentInset:UIEdgeInsetsMake(0.0, inset, 0.0, inset)];
    
    //    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    //    [self setOpaque:FALSE];
    //    [self setBackgroundColor:[UIColor clearColor]];
    //
//    [self setupGestureRecognizers];
    
    //    scrollLayer = [CAScrollLayer new];
    //    [scrollLayer setFrame:[self viewWithTag:6].bounds];
    ////    [scrollLayer setPosition:CGPointMake(self.bounds.size.width/2, self .bounds.size.height/2)]; // 10
    //    [scrollLayer setScrollMode:kCAScrollHorizontally];
    //
    //
    //
    //    scaleSliderLayer = [ScaleSliderLayer new];
    //    CGRect frame = CGRectMake(scrollLayer.frame.origin.x, scrollLayer.frame.origin.y, scrollLayer.frame.size.width * 2.0, scrollLayer.frame.size.height);
    //    [scaleSliderLayer setFrame:frame];
    //    [scrollLayer addSublayer:scaleSliderLayer];
    //     [[[self viewWithTag:6] layer] addSublayer:scrollLayer];
    ////
    //    [self.layer setPosition:scaleSliderLayer.frame.origin];
    //
    //    [scrollLayer setNeedsDisplay];
    //    [scaleSliderLayer setNeedsDisplay];
    //    [self.layer setNeedsDisplay];
}

//- (void)setupGestureRecognizers
//{
//    [self setUserInteractionEnabled:TRUE];
//    [self setMultipleTouchEnabled:TRUE];
//    [self setExclusiveTouch:TRUE];
//
////    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
////    [self.panGestureRecognizer setMaximumNumberOfTouches:1];
////    [self.panGestureRecognizer setMinimumNumberOfTouches:1];
////    self.panGestureRecognizer.delegate = self;
////    [self addGestureRecognizer:self.panGestureRecognizer];
//
//    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
//    [self.tapGestureRecognizer setNumberOfTapsRequired:1];
//    [self.tapGestureRecognizer setNumberOfTouchesRequired:1];
//    self.tapGestureRecognizer.delegate = self;
//    [self addGestureRecognizer:self.tapGestureRecognizer];
//
//    self.scaleSliderControlView.gestureRecognizers = @[self.tapGestureRecognizer];
//}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    dispatch_async(dispatch_get_main_queue(), ^{
    if ([object isEqual:self.scaleSliderControlView]) {
        if ([keyPath isEqualToString:@"hidden"]) {
            if ([self.scaleSliderControlView isHidden]) {
                    [self cameraControlAction:(UIButton *)[self viewWithTag:[self selectedCameraProperty]]];
            } else {
                float value = [self.delegate valueForCameraProperty:[self selectedCameraProperty]];
                NSLog(@"Value out: %f", value);
//                CGRect scrollRect = CGRectMake(-CGRectGetMidX(self.scaleSliderScrollView.frame) + (CGRectGetWidth(self.scaleSliderScrollView.frame) * value), self.scaleSliderScrollView.frame.origin.y, (CGRectGetMaxX(self.scaleSliderScrollView.frame)) + fabs(CGRectGetMidX(self.scaleSliderScrollView.frame)),  CGRectGetHeight(self.scaleSliderScrollView.frame));
                [self.scaleSliderScrollView setContentOffset:CGPointMake(-CGRectGetMidX(self.scaleSliderScrollView.frame) + (self.scaleSliderScrollView.contentSize.width * value), 0.0) animated:TRUE];//  scrollRectToVisible:scrollRect animated:FALSE];
                
            }
        }
    }
    });
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

float normalize(float unscaledNum, float minAllowed, float maxAllowed, float min, float max) {
    return (maxAllowed - minAllowed) * (unscaledNum - min) / (max - min) + minAllowed;
}

//- (void)handlePanGesture:(UIPanGestureRecognizer *)sender {
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        if (sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateChanged) {
    //            CGFloat location = [sender locationOfTouch:nil inView:sender.view.superview].x / CGRectGetWidth(self.superview.frame);
    //            setCameraPropertyBlock = (!setCameraPropertyBlock) ? [self.delegate setCameraProperty] : setCameraPropertyBlock;
    //            setCameraPropertyBlock((sender.state == UIGestureRecognizerStateEnded) ? FALSE : TRUE, [self selectedCameraProperty], location);
    //        }
    //    });
//}

//- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
//        dispatch_async(dispatch_get_main_queue(), ^{
//    //        if (sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateChanged) {
//    //            CGFloat location = [sender locationOfTouch:nil inView:sender.view.superview].x / CGRectGetWidth(self.superview.frame);
//    //            setCameraPropertyBlock = (!setCameraPropertyBlock) ? [self.delegate setCameraProperty] : setCameraPropertyBlock;
//    //            setCameraPropertyBlock((sender.state == UIGestureRecognizerStateEnded) ? FALSE : TRUE, [self selectedCameraProperty], location);
//    //        }
//        });
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CameraProperty cameraProperty = [self selectedCameraProperty];
        if (cameraProperty != NSNotFound && (scrollView.isDragging || scrollView.isTracking || scrollView.isDecelerating))
        {
            CGFloat location = normalize(scrollView.contentOffset.x, 0.0, 1.0, -(CGRectGetMidX(scrollView.frame)), (CGRectGetMaxX(scrollView.frame)) + fabs(CGRectGetMidX(scrollView.frame)));
    //        NSLog(@"location: %f, contentOffset.x: %f, MidX: %f, MaxX + MidX(abs): %f", location, scrollView.contentOffset.x, -(CGRectGetMidX(scrollView.frame)), (CGRectGetMaxX(scrollView.frame)) + fabs(CGRectGetMidX(scrollView.frame)));
            location = (location < 0.0) ? 0.0 : (location > 1.0) ? 1.0 : location;
            NSLog(@"Value in: %f", location);
            setCameraPropertyValueBlock = (!setCameraPropertyValueBlock) ? [self.delegate setCameraProperty:[self selectedCameraProperty]] : setCameraPropertyValueBlock;
            setCameraPropertyValueBlock(cameraProperty, location);
        }
    });
}

//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    [self.scaleSliderControlView setHidden:TRUE];
//}


- (CameraProperty)selectedCameraProperty
{
    NSUInteger index = [self.cameraControlButtons indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        *stop = [obj isSelected];
        return [obj isSelected];
    }];
    
    CameraProperty cameraProperty = (index != NSNotFound) ? (CameraProperty)[[self.cameraControlButtons objectAtIndex:index] tag] : index;
//    NSLog(@"camera property == %lu", cameraProperty);
    
    return cameraProperty;
}

//- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
//    //    NSLog(@"%s", __PRETTY_FUNCTION__);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        //        CGRect scrollRect = ((UICollectionView *)[self viewWithTag:6]).frame;
//        if ([(UIButton *)[self viewWithTag:ControlButtonTagFocus] isSelected])
//        {
//            [self.delegate autoFocusWithCompletionHandler:^(double focus) {
//                //                [self.delegate scrollSliderControlToItemAtIndexPath:[NSIndexPath indexPathForItem:(long)(focus) * 10.0 inSection:0]];
//            }];
//        } else if ([(UIButton *)[self viewWithTag:ControlButtonTagISO] isSelected] && ![(UIButton *)[self viewWithTag:ControlButtonTagExposureDuration] isSelected])
//        {
//            [self.delegate autoExposureWithCompletionHandler:^(double ISO) {
//                //                if ([(UIButton *)[self viewWithTag:ControlButtonTagExposureDuration] isSelected]) [self.delegate setISO:ISO];
//                //                [self.delegate scrollSliderControlToItemAtIndexPath:[NSIndexPath indexPathForItem:(long)(ISO) * 10.0 inSection:0]];
//            }];
//        }
//
//    });
//}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    NSLog(@"forwardingTargetForSelector");
    return self.delegate;
}

- (IBAction)recordActionHandler:(UIButton *)sender {
    [self.delegate toggleRecordingWithCompletionHandler:^(BOOL isRunning, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [(UIButton *)[self viewWithTag:ControlButtonTagRecord] setSelected:isRunning];
            [(UIButton *)[self viewWithTag:ControlButtonTagRecord] setHighlighted:isRunning];
        });
    }];
}

static CMTime (^exposureDurationForMode)(ExposureDurationMode) = ^CMTime(ExposureDurationMode exposureDurationMode)
{
    switch (exposureDurationMode) {
        case ExposureDurationModeNormal:
            return CMTimeMakeWithSeconds(1.0/30.0, 1000*1000*1000);
            break;
            
        case ExposureDurationModeLong:
            return CMTimeMakeWithSeconds(1.0/3.0, 1000*1000*1000);
            break;
            
        default:
            return kCMTimeInvalid;
            break;
    }
};

- (IBAction)cameraControlAction:(id)sender {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.scaleSliderControlView setHidden:TRUE];
//    });
    
    [self.cameraControlButtons enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL shouldSelect = ([sender isEqual:obj]) ? ![sender isSelected] : FALSE;
            [obj setSelected:shouldSelect];
            [obj setHighlighted:shouldSelect];
            if (shouldSelect)
            {
                [self.scaleSliderControlView setHidden:FALSE];
            }
        });
    }];
}

- (IBAction)exposureDuration:(UIButton *)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"%s", __PRETTY_FUNCTION__);
        [sender setEnabled:FALSE];
        
        ExposureDurationMode targetExposureDurationMode = ([sender isSelected]) ? ExposureDurationModeNormal : ExposureDurationModeLong;
        CMTime targetExposureDuration = exposureDurationForMode(targetExposureDurationMode);
        [self.delegate targetExposureDuration:targetExposureDuration withCompletionHandler:^(CMTime currentExposureDuration) {
            [sender setEnabled:TRUE];
            BOOL shouldHighlightExposureDurationModeButton = (targetExposureDurationMode == ExposureDurationModeLong) ? TRUE : FALSE;
            [sender setSelected:shouldHighlightExposureDurationModeButton];
            [(UIButton *)sender setHighlighted:shouldHighlightExposureDurationModeButton];
        }];
    });
}

@end
