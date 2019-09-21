//
//  CameraControlsView.m
//  ISOCameraLDE
//
//  Created by Xcode Developer on 9/5/19.
//  Copyright © 2019 The Life of a Demoniac. All rights reserved.
//

#import "CameraControlsView.h"

@interface CameraControlsView ()
{
    CGPoint firstTouchInView;
}

@end

@implementation CameraControlsView

@synthesize delegate = _delegate;

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
    //    self = [super init];
    //    if (self) {
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self setOpaque:FALSE];
    [self setBackgroundColor:[UIColor clearColor]];
    
    [self setupGestureRecognizers];
    //    }
    //    return self;
    [super awakeFromNib];
}

- (void)setupGestureRecognizers
{
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.panGestureRecognizer setMaximumNumberOfTouches:1];
    [self.panGestureRecognizer setMinimumNumberOfTouches:1];
    self.panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.panGestureRecognizer];
    self.gestureRecognizers = @[self.panGestureRecognizer];
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
            //            [self adjustCameraSetting:([(UIButton *)[self viewWithTag:ControlButtonTagFocus] isSelected]) ? ControlButtonTagFocus : ControlButtonTagISO usingTouchAtPoint:CGPointZero];
            CGFloat location = [sender locationInView:self].x / CGRectGetWidth(self.frame);
            if ([(UIButton *)[self viewWithTag:ControlButtonTagFocus] isSelected])
            {
                [self.delegate setFocus:location];
                NSString *numberedImageName = [NSString stringWithFormat:@"%ld.square.fill", (long)(self.delegate.focus * 10.0)];
                [(UIButton *)[self viewWithTag:ControlButtonTagFocus] setImage:[UIImage systemImageNamed:numberedImageName] forState:UIControlStateSelected];
            } else if ([(UIButton *)[self viewWithTag:ControlButtonTagISO] isSelected])
            {
                [self.delegate setISO:location];
            } else if ([(UIButton *)[self viewWithTag:ControlButtonTagTorch] isSelected])
            {
                [self.delegate setTorchLevel:location];
            }
        }
    });
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    NSLog(@"forwardingTargetForSelector");
    return self.delegate;
}

- (IBAction)record:(UIButton *)sender
{
    [self.delegate toggleRecordingWithCompletionHandler:^(BOOL isRunning, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [(UIButton *)[self viewWithTag:ControlButtonTagISO] setSelected:isRunning];
            [(UIButton *)[self viewWithTag:ControlButtonTagISO] setHighlighted:isRunning];
            [(UIButton *)[self viewWithTag:4] setImage:[UIImage systemImageNamed:(isRunning) ? @"camera.circle.fill" : @"camera.circle"] forState:UIControlStateNormal];
        });
    }];
}

// When focus button is selected, the exposure duration changes to 1/30th of second
- (IBAction)focus:(UIButton *)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self deselectAllControlButtonsExceptWithTag:ControlButtonTagFocus];
        [sender setSelected:![sender isSelected]];
        [(UIButton *)sender setHighlighted:[sender isSelected]];
    });
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

- (IBAction)exposureDuration:(UIButton *)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"%s", __PRETTY_FUNCTION__);
        if ([sender isEnabled])
        {
            [sender setEnabled:FALSE];
            ExposureDurationMode targetExposureDurationMode = ([sender isSelected]) ? ExposureDurationModeNormal : ExposureDurationModeLong;
            CMTime targetExposureDuration = exposureDurationForMode(targetExposureDurationMode);
            [self.delegate targetExposureDuration:targetExposureDuration withCompletionHandler:^(CMTime currentExposureDuration) {
                [sender setEnabled:TRUE];
                BOOL shouldHighlightExposureDurationModeButton = (targetExposureDurationMode == ExposureDurationModeLong) ? TRUE : FALSE;
                [sender setSelected:shouldHighlightExposureDurationModeButton];
                [(UIButton *)sender setHighlighted:shouldHighlightExposureDurationModeButton];
            }];
        }
    });
}

- (IBAction)iso:(UIButton *)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self deselectAllControlButtonsExceptWithTag:ControlButtonTagISO];
        [sender setSelected:![sender isSelected]];
        [(UIButton *)sender setHighlighted:[sender isSelected]];
    });
}

- (IBAction)torch:(UIButton *)sender
{
    NSLog(@"torch level %f", [[self.delegate videoDevice] torchLevel]);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self deselectAllControlButtonsExceptWithTag:ControlButtonTagTorch];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate toggleTorchWithCompletionHandler:^(BOOL isTorchActive) {
            [(UIButton *)[self viewWithTag:ControlButtonTagTorch] setHighlighted:isTorchActive];
            [(UIButton *)[self viewWithTag:ControlButtonTagTorch] setSelected:isTorchActive];
//            [(UIButton *)[self viewWithTag:ControlButtonTagTorch] setEnabled:TRUE];
        }];
    });
}


- (void)deselectAllControlButtonsExceptWithTag:(ControlButtonTag)tag
{
    dispatch_async(dispatch_get_main_queue(), ^{
    for (ControlButtonTag t = 1; t < 4; t++)
    {
        if (t != tag)
        {
            [(UIButton *)[self viewWithTag:t] setSelected:FALSE];
            [(UIButton *)[self viewWithTag:t] setHighlighted:FALSE];
        }
    }
    });
}

@end
