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
    __block SetCameraPropertyBlock setCameraPropertyBlock;
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
    //    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    //    [self setOpaque:FALSE];
    //    [self setBackgroundColor:[UIColor clearColor]];
    //
    [self setupGestureRecognizers];
    
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

- (void)setupGestureRecognizers
{
    [self setUserInteractionEnabled:TRUE];
    [self setMultipleTouchEnabled:TRUE];
    [self setExclusiveTouch:TRUE];
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.panGestureRecognizer setMaximumNumberOfTouches:1];
    [self.panGestureRecognizer setMinimumNumberOfTouches:1];
    self.panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.panGestureRecognizer];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.tapGestureRecognizer setNumberOfTapsRequired:1];
    [self.tapGestureRecognizer setNumberOfTouchesRequired:1];
    self.tapGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.tapGestureRecognizer];
    
    self.gestureRecognizers = @[self.panGestureRecognizer, self.tapGestureRecognizer];
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

- (void)handlePanGesture:(UIPanGestureRecognizer *)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateChanged) {
            CGFloat location = [sender locationOfTouch:nil inView:sender.view.superview].x / CGRectGetWidth(self.superview.frame);
            setCameraPropertyBlock = (!setCameraPropertyBlock) ? [self.delegate setCameraProperty] : setCameraPropertyBlock;
            
            setCameraPropertyBlock((sender.state == UIGestureRecognizerStateEnded) ? FALSE : TRUE, [self selectedCameraProperty], location);
        }
    });
}

- (CameraProperty)selectedCameraProperty
{
    for (NSUInteger t = 3; t < 6; t++)
    {
        if ([(UIButton *)[self viewWithTag:t] isSelected])
        {
            return t;
        }
    }
    
    return 0;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
    //    NSLog(@"%s", __PRETTY_FUNCTION__);
    dispatch_async(dispatch_get_main_queue(), ^{
        //        CGRect scrollRect = ((UICollectionView *)[self viewWithTag:6]).frame;
        if ([(UIButton *)[self viewWithTag:ControlButtonTagFocus] isSelected])
        {
            [self.delegate autoFocusWithCompletionHandler:^(double focus) {
                //                [self.delegate scrollSliderControlToItemAtIndexPath:[NSIndexPath indexPathForItem:(long)(focus) * 10.0 inSection:0]];
            }];
        } else if ([(UIButton *)[self viewWithTag:ControlButtonTagISO] isSelected] && ![(UIButton *)[self viewWithTag:ControlButtonTagExposureDuration] isSelected])
        {
            [self.delegate autoExposureWithCompletionHandler:^(double ISO) {
                //                if ([(UIButton *)[self viewWithTag:ControlButtonTagExposureDuration] isSelected]) [self.delegate setISO:ISO];
                //                [self.delegate scrollSliderControlToItemAtIndexPath:[NSIndexPath indexPathForItem:(long)(ISO) * 10.0 inSection:0]];
            }];
        }
        
    });
}

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
    [self toggleSelectionStateForControlButtonWithTag:(ControlButtonTag)[sender tag] selectedState:((UIButton *)sender).isSelected];
}

- (IBAction)exposureDuration:(UIButton *)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"%s", __PRETTY_FUNCTION__);
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

- (void)toggleSelectionStateForControlButtonWithTag:(NSUInteger)buttonTag selectedState:(BOOL)isSelected
{
    for (NSUInteger t = 3; t < 6; t++)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [(UIButton *)[self viewWithTag:t] setSelected:(buttonTag == t) ? !isSelected : FALSE];
            [(UIButton *)[self viewWithTag:t] setHighlighted:[(UIButton *)[self viewWithTag:t] isSelected]];
        });
    }
    if (buttonTag == ControlButtonTagTorch) {
        [self.delegate toggleTorchWithCompletionHandler:^(BOOL isTorchActive) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [(UIButton *)[self viewWithTag:ControlButtonTagTorch] setHighlighted:isTorchActive];
                [(UIButton *)[self viewWithTag:ControlButtonTagTorch] setSelected:isTorchActive];
                NSString *torchButtonImage = [NSString stringWithFormat:(isTorchActive) ? @"bolt.circle.fill" : @"bolt.circle"];
                [(UIButton *)[self viewWithTag:ControlButtonTagTorch] setImage:[UIImage systemImageNamed:torchButtonImage] forState:(isTorchActive) ? UIControlStateSelected : UIControlStateNormal];
            });
        }];
    }
    [[self.superview viewWithTag:7] setHidden:![[self.superview viewWithTag:7] isHidden]];
}

@end
