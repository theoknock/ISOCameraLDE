//
//  CameraControlsView.m
//  ISOCameraLDE
//
//  Created by Xcode Developer on 9/5/19.
//  Copyright © 2019 The Life of a Demoniac. All rights reserved.
//

#import "CameraControlsView.h"
#import "CollectionViewCell.h"

@interface CameraControlsView ()
{
    CGPoint firstTouchInView;
}

@end

@implementation CameraControlsView

static NSString * const reuseIdentifier = @"CollectionViewCellReuseIdentifier";

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
    //    if (self) 
    [super awakeFromNib];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self setOpaque:FALSE];
    [self setBackgroundColor:[UIColor clearColor]];
    
    [self setupGestureRecognizers];
    //    }
    //    return self;
    
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
            //            [self adjustCameraSetting:([(UIButton *)[self viewWithTag:ControlButtonTagFocus] isSelected]) ? ControlButtonTagFocus : ControlButtonTagISO usingTouchAtPoint:CGPointZero];
            CGFloat location = [sender locationInView:self].x / CGRectGetWidth(self.frame);
            CGRect scrollRect = ((UICollectionView *)[self viewWithTag:6]).frame;
            [self.delegate scrollSliderControlToItemAtIndexPath:[NSIndexPath indexPathForItem:(long)([sender locationInView:self].x / CGRectGetWidth(scrollRect) * 10.0) inSection:0]];
//            [(UICollectionView *)[self viewWithTag:6] scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:(long)(self.delegate.focus * 10.0) inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:TRUE]; // scrollRectToVisible:CGRectMake(scrollRect.size.width * location, scrollRect.origin.y, 150.0, scrollRect.size.height) animated:TRUE];
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

- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate autoFocus];
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
        [(UICollectionView *)[self viewWithTag:6] setHidden:!([sender isSelected])];
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

- (IBAction)iso:(UIButton *)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self deselectAllControlButtonsExceptWithTag:ControlButtonTagISO];
        [sender setSelected:![sender isSelected]];
        [(UIButton *)sender setHighlighted:[sender isSelected]];
        [(UICollectionView *)[self viewWithTag:6] setHidden:!([sender isSelected])];
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
            NSString *torchButtonImage = [NSString stringWithFormat:(isTorchActive) ? @"bolt.circle.fill" : @"bolt.circle"];
            [(UIButton *)[self viewWithTag:ControlButtonTagTorch] setImage:[UIImage systemImageNamed:torchButtonImage] forState:(isTorchActive) ? UIControlStateSelected : UIControlStateNormal];
//            [(UIButton *)[self viewWithTag:ControlButtonTagTorch] setEnabled:TRUE];
            [(UICollectionView *)[self viewWithTag:6] setHidden:!isTorchActive];
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

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    [cell.contentView setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.25]];
    [cell setMeasuringUnit:[NSString stringWithFormat:@"| | | | %lu | | | |", indexPath.item]];
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return 1;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 11;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CGRectGetWidth(self.frame), 50.0);
}

@end
