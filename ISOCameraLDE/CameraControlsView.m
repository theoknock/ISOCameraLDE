//
//  CameraControlsView.m
//  ISOCameraLDE
//
//  Created by Xcode Developer on 9/5/19.
//  Copyright © 2019 The Life of a Demoniac. All rights reserved.
//

#import "CameraControlsView.h"
#import "CameraViewController.h"

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

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (sender.state == UIGestureRecognizerStateBegan) {
            firstTouchInView = [sender locationInView:self];
        } else if (sender.state == UIGestureRecognizerStateEnded) {
            firstTouchInView.x = 0;
            //        if ([(UIButton *)[self viewWithTag:2] isSelected])
            //        {
            //             [(UIButton *)[self viewWithTag:2] setImage:[UIImage systemImageNamed:@"sun.max.fill"] forState:UIControlStateSelected];
            //        } else if ([(UIButton *)[self viewWithTag:1] isSelected]) {
            //            [(UIButton *)[self viewWithTag:2] setImage:[UIImage systemImageNamed:@"viewfinder.circle.fill"] forState:UIControlStateSelected];
            //        }
        } else if (sender.state == UIGestureRecognizerStateChanged) {
            CGPoint location = [sender locationInView:self];
            if ([(UIButton *)[self viewWithTag:ControlButtonTagFocus] isSelected])
            {
                [self.delegate setFocus:location.x / CGRectGetWidth(sender.view.frame)];
              NSString *numberedImageName = [NSString stringWithFormat:@"%ld.square.fill", (long)(self.delegate.focus * 10.0)];
                [(UIButton *)[self viewWithTag:ControlButtonTagFocus] setImage:[UIImage systemImageNamed:numberedImageName] forState:UIControlStateSelected];
            } else if ([(UIButton *)[self viewWithTag:ControlButtonTagISO] isSelected]) {
                [self.delegate setISO:location.x / CGRectGetWidth(sender.view.frame)];
            }
        }
    });
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    NSLog(@"forwardingTargetForSelector");
    return self.delegate;
}

- (IBAction)record:(id)sender
{
    [self.delegate toggleRecordingWithCompletionHandler:^(BOOL isRunning, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isRunning)
                [(UIButton *)[self viewWithTag:4] setImage:[UIImage systemImageNamed:@"camera.circle.fill"] forState:UIControlStateNormal];
            else
                [(UIButton *)[self viewWithTag:4] setImage:[UIImage systemImageNamed:@"camera.circle"] forState:UIControlStateNormal];
        });
    }];
}

// When focus button is selected, the exposure duration changes to 1/30th of second
- (IBAction)focus:(UIButton *)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [(UIButton *)[self viewWithTag:ControlButtonTagISO] setSelected:FALSE];
        [(UIButton *)[self viewWithTag:ControlButtonTagISO] setHighlighted:FALSE];
        NSLog(@"%s", __PRETTY_FUNCTION__);
        [sender setSelected:![sender isSelected]];
        [(UIButton *)sender setHighlighted:[sender isSelected]];
    });
}

- (IBAction)exposureDuration:(UIButton *)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"%s", __PRETTY_FUNCTION__);
        [sender setSelected:![sender isSelected]];
        [(UIButton *)sender setHighlighted:[sender isSelected]];
        [self.delegate normalizeExposureDuration:[sender isSelected]];
    });
}

- (IBAction)iso:(UIButton *)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [(UIButton *)[self viewWithTag:ControlButtonTagFocus] setSelected:FALSE];
        [(UIButton *)[self viewWithTag:ControlButtonTagFocus] setHighlighted:FALSE];
        NSLog(@"%s", __PRETTY_FUNCTION__);
        [sender setSelected:![sender isSelected]];
        [(UIButton *)sender setHighlighted:[sender isSelected]];
    });
}

@end
