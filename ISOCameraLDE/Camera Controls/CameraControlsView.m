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
    ScaleSliderLayer *scaleSliderLayer;
    __block SetCameraPropertyValueBlock setCameraPropertyValueBlock;
    CATextLayer *textLayer;
}

@end

@implementation CameraControlsView

static NSString * const reuseIdentifier = @"CollectionViewCellReuseIdentifier";

@synthesize delegate = _delegate, measuringUnit = _measuringUnit;

//+ (Class)layerClass
//{
//    return [ScaleSliderLayer class];
//}

- (void)setDelegate:(id<CameraControlsDelegate>)delegate
{
    //    NSLog(@"%s", __PRETTY_FUNCTION__);
    _delegate = delegate;
    //    NSLog(@"%@", [(NSObject *)_delegate description]);
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
    
    textLayer = [CATextLayer layer];
    [self.layer addSublayer:textLayer];
    [(ScaleSliderViewTop *)self.scaleSliderViewTop setDelegate:(id<ScaleSliderViewTopDelegate> _Nullable)self];
    
    //    [self.scaleSliderControlView addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];
    
    CGFloat inset = CGRectGetMidX(self.frame);
    [self.scaleSliderScrollView setContentInset:UIEdgeInsetsMake(0.0, inset, 0.0, inset)];
    
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
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.tapGestureRecognizer setNumberOfTapsRequired:1];
    [self.tapGestureRecognizer setNumberOfTouchesRequired:1];
    self.tapGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.tapGestureRecognizer];
    
    self.gestureRecognizers = @[self.tapGestureRecognizer];
}

- (NSNumberFormatter *)numberFormatter
{
    NSNumberFormatter * formatter = [[ NSNumberFormatter alloc ] init ] ;
    [ formatter setFormatWidth:1 ] ;
    [ formatter setPaddingCharacter:@" " ] ;
    [ formatter setFormatterBehavior:NSNumberFormatterBehavior10_4 ] ;
    [ formatter setNumberStyle:NSNumberFormatterDecimalStyle ] ;
    [ formatter setMinimumFractionDigits:2 ] ;
    [ formatter setMaximumFractionDigits:2 ] ;
    
    return formatter;
}

//- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//    if ([object isEqual:self.scaleSliderControlView]) {
//        if ([keyPath isEqualToString:@"hidden"]) {
//            if ([self.scaleSliderControlView isHidden]) {
//                [self.cameraControlButtonsStackView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                    if ([obj isKindOfClass:[UIButton class]])
//                    {
////                        NSLog(@"button %lu", [obj tag]);
//                        UIImage *large_symbol = [[(UIButton *)obj currentImage] imageByApplyingSymbolConfiguration:[UIImageSymbolConfiguration configurationWithTextStyle:UIFontTextStyleLargeTitle]];
//                        [(UIButton *)obj setImage:large_symbol forState:UIControlStateNormal];
//                        [self setMeasuringUnit:[NSString stringWithFormat:@"%@", @""]];
//                    }
//                }];
//                    [self cameraControlAction:(UIButton *)[self viewWithTag:[self selectedCameraProperty]]];
//            } else {
//                float value = [self.delegate valueForCameraProperty:[self selectedCameraProperty]];
////                NSLog(@"Value out: %f", value);
////                CGRect scrollRect = CGRectMake(-CGRectGetMidX(self.scaleSliderScrollView.frame) + (CGRectGetWidth(self.scaleSliderScrollView.frame) * value), self.scaleSliderScrollView.frame.origin.y, (CGRectGetMaxX(self.scaleSliderScrollView.frame)) + fabs(CGRectGetMidX(self.scaleSliderScrollView.frame)),  CGRectGetHeight(self.scaleSliderScrollView.frame));
//                [self.scaleSliderScrollView setContentOffset:CGPointMake(-CGRectGetMidX(self.scaleSliderScrollView.frame) + (self.scaleSliderScrollView.contentSize.width * value), 0.0) animated:TRUE];//  scrollRectToVisible:scrollRect animated:FALSE];
//                [self setMeasuringUnit:[[self numberFormatter] stringFromNumber:[NSNumber numberWithFloat:(value * 10)]]];
//            }
//        }
//    }
//    });
//}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //    NSUInteger index = [[touch gestureRecognizers] indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    //        BOOL isTapGesture = ([(UIGestureRecognizer *)obj isKindOfClass:[UITapGestureRecognizer class]]) ? TRUE : FALSE;
    //        *stop = isTapGesture;
    //
    //        if ([[touch view] isKindOfClass:[UIButton class]])
    //        {
    //            NSLog(@"UIButton tapped");
    //        }
    //
    //        return isTapGesture;
    //    }];
    //    NSLog(@"Index %lu", index);
    //    return (index != NSNotFound) ? TRUE : FALSE;
    return TRUE;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    NSLog(@"Point was inside camera controls view");
    NSUInteger index = [self.stackViewButtons indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL isPointInsideButton = ([(UIButton *)obj pointInside:[self convertPoint:point toView:(UIButton *)obj] withEvent:event])/* && ([(UIButton *)obj tag] != [selectedCameraControlButton tag]))*/ ? TRUE : FALSE;
        *stop = isPointInsideButton;
        NSLog(@"Point was%@inside button with tag: %lu", (isPointInsideButton) ? @" " : @" NOT ", [(UIButton *)obj tag]);
        
        if (isPointInsideButton)
        {
            //            dispatch_async(dispatch_get_main_queue(), ^{
            //                // TOGGLE SELECTED CAMERA CONTROL BUTTON(S)
            //                [self cameraControlAction:selectedCameraControlButton];
            //            });
            // SECOND, SHOW THE SCALE SLIDER AND POSITION AT VALUE OF SELECTED BUTTON
            if (!self.scaleSliderControlView.isHidden)
            {
                if ([self.cameraControlButtons containsObject:(UIButton *)obj])
                {
                    [(UIButton *)obj sendAction:@selector(cameraControlAction:) to:self forEvent:event];
                } else {
                     switch ((ControlButtonTag)[(UIButton *)obj tag]) {
                         case ControlButtonTagRecord:
                         {
                               [(UIButton *)obj sendAction:@selector(recordActionHandler:) to:self forEvent:event];
                               break;
                         }
                             
                             case ControlButtonTagExposureDuration:
                             {
                                   [(UIButton *)obj sendAction:@selector(exposureDuration:) to:self forEvent:event];
                                   break;
                             }
                               
                           default:
                               break;
                       }
                     }
            }
        }
        
        return isPointInsideButton;
    }];
    
    return TRUE;//[super pointInside:point withEvent:event]; //(index != NSNotFound) ? TRUE : FALSE;
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

- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CameraProperty cameraProperty = [self selectedCameraProperty];
        if (cameraProperty != NSNotFound && (scrollView.isDragging || scrollView.isTracking || scrollView.isDecelerating))
        {
            CGFloat location = normalize(scrollView.contentOffset.x, 0.0, 1.0, -(CGRectGetMidX(scrollView.frame)), (CGRectGetMaxX(scrollView.frame)) + fabs(CGRectGetMidX(scrollView.frame)));
            //        NSLog(@"location: %f, contentOffset.x: %f, MidX: %f, MaxX + MidX(abs): %f", location, scrollView.contentOffset.x, -(CGRectGetMidX(scrollView.frame)), (CGRectGetMaxX(scrollView.frame)) + fabs(CGRectGetMidX(scrollView.frame)));
            location = (location < 0.0) ? 0.0 : (location > 1.0) ? 1.0 : location;
            //            NSLog(@"Value in: %f", location);
            setCameraPropertyValueBlock = (!setCameraPropertyValueBlock) ? [self.delegate setCameraProperty:[self selectedCameraProperty]] : setCameraPropertyValueBlock;
            setCameraPropertyValueBlock(cameraProperty, location);
            [self setMeasuringUnit:[[self numberFormatter] stringFromNumber:[NSNumber numberWithFloat:(location * 10)]]];
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
    //    NSLog(@"forwardingTargetForSelector");
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
            
        case ExposureDurationModeShort:
            return kCMTimeInvalid;
            break;
            
        default:
            return kCMTimeInvalid;
            break;
    }
};

- (IBAction)exposureDuration:(UIButton *)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //        NSLog(@"%s", __PRETTY_FUNCTION__);
        [sender setEnabled:FALSE];
        
        ExposureDurationMode targetExposureDurationMode = ([sender isSelected]) ? ExposureDurationModeShort : ExposureDurationModeLong;
        CMTime targetExposureDuration = exposureDurationForMode(targetExposureDurationMode);
        [self.delegate targetExposureDuration:targetExposureDuration withCompletionHandler:^(CMTime currentExposureDuration) {
            [sender setEnabled:TRUE];
            BOOL shouldHighlightExposureDurationModeButton = (targetExposureDurationMode == ExposureDurationModeLong) ? TRUE : FALSE;
            [sender setSelected:shouldHighlightExposureDurationModeButton];
            [(UIButton *)sender setHighlighted:shouldHighlightExposureDurationModeButton];
        }];
    });
}

- (IBAction)cameraControlAction:(UIButton *)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CameraProperty selectedButtonCameraProperty = [self selectedCameraProperty];
        CameraProperty senderButtonCameraProperty = (CameraProperty)[sender tag];
        BOOL cameraPropertiesIdentical = (senderButtonCameraProperty == selectedButtonCameraProperty) ? TRUE : FALSE;
        
        [self deselectCameraControlButtonForCameraProperty:selectedButtonCameraProperty];
        [self selectCameraControlButtonForCameraProperty:(cameraPropertiesIdentical) ? nil : senderButtonCameraProperty];
        //    dispatch_async(dispatch_get_main_queue(), ^{
        //        // Hide the slider? TRUE if the sender button is selected || if the sender button is not selected && if the slider is showing (TRUE)
        //        [self.scaleSliderControlView setHidden:([(UIButton *)sender isSelected] && !(self.scaleSliderControlView.isHidden))]; // is the sender is not already selected (and, therefore, displaying the slider,
        //        [self.cameraControlButtons enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //            dispatch_async(dispatch_get_main_queue(), ^{
        //                BOOL shouldSelect = ([sender isEqual:obj]) ? TRUE : FALSE; // if the enumerated button and the sender button are the same AND the sender button is not already selected...
        //                [obj setSelected:shouldSelect];
        //                [obj setHighlighted:shouldSelect];
        //                UIImage *symbol = (shouldSelect) ? [[(UIButton *)obj currentImage] imageByApplyingSymbolConfiguration:[UIImageSymbolConfiguration configurationWithTextStyle:UIFontTextStyleTitle2 /* configurationWithScale:UIImageSymbolScaleSmall*/]] : [[(UIButton *)obj currentImage] imageByApplyingSymbolConfiguration:[UIImageSymbolConfiguration configurationWithTextStyle:UIFontTextStyleLargeTitle]];
        //                [(UIButton *)obj setImage:symbol forState:UIControlStateNormal];
        //                if (shouldSelect)
        //                {
        //                    //                    [self.scaleSliderControlView setHidden:(!shouldSelect)];
        //                    [self.scaleSliderViewTop setSelectedCameraPropertyValue:[self selectedCameraPropertyFrame]];
        //                    [self.scaleSliderViewTop setNeedsDisplay];
        //
        //                    float value = [self.delegate valueForCameraProperty:(CameraProperty)[(UIButton *)obj tag]];
        //                    [self.scaleSliderScrollView setContentOffset:CGPointMake(-CGRectGetMidX(self.scaleSliderScrollView.frame) + (self.scaleSliderScrollView.contentSize.width * value), 0.0) animated:TRUE];//  scrollRectToVisible:scrollRect animated:FALSE];
        //                    [self setMeasuringUnit:[[self numberFormatter] stringFromNumber:[NSNumber numberWithFloat:(value * 10)]]];
        //                    //                    NSLog(@"origin x (1): %f", ((UIButton *)obj).frame.origin.x);
        //                }
        //            });
        //        }];
    });
}

- (void)selectCameraControlButtonForCameraProperty:(CameraProperty)cameraProperty
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (cameraProperty)
        {
            UIButton *selectedButton = (UIButton *)[self viewWithTag:cameraProperty];
            // if the enumerated button and the sender button are the same AND the sender button is not already selected...
            [selectedButton setSelected:TRUE];
            [selectedButton setHighlighted:TRUE];
            UIImage *symbol = [[(UIButton *)selectedButton currentImage] imageByApplyingSymbolConfiguration:[UIImageSymbolConfiguration configurationWithTextStyle:UIFontTextStyleTitle2]];
            [(UIButton *)selectedButton setImage:symbol forState:UIControlStateNormal];
            [self.scaleSliderControlView setHidden:FALSE];
            [self.scaleSliderViewTop setSelectedCameraPropertyValue:[self selectedCameraPropertyFrame]];
            [self.scaleSliderViewTop setNeedsDisplay];
            
            float value = [self.delegate valueForCameraProperty:cameraProperty];
            [self.scaleSliderScrollView setContentOffset:CGPointMake(-CGRectGetMidX(self.scaleSliderScrollView.frame) + (self.scaleSliderScrollView.contentSize.width * value), 0.0) animated:TRUE];
            [self setMeasuringUnit:[[self numberFormatter] stringFromNumber:[NSNumber numberWithFloat:(value * 10)]]];
        }
    });
}

- (void)deselectCameraControlButtonForCameraProperty:(CameraProperty)cameraProperty
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (cameraProperty)
        {
            UIButton *selectedButton = (UIButton *)[self viewWithTag:(!cameraProperty) ? cameraProperty : [self selectedCameraProperty]];
            // if the enumerated button and the sender button are the same AND the sender button is not already selected...
            [selectedButton setSelected:FALSE];
            [selectedButton setHighlighted:FALSE];
            UIImage *symbol = [[(UIButton *)selectedButton currentImage] imageByApplyingSymbolConfiguration:[UIImageSymbolConfiguration configurationWithTextStyle:UIFontTextStyleLargeTitle]];
            [(UIButton *)selectedButton setImage:symbol forState:UIControlStateNormal];
        }
        [self.scaleSliderControlView setHidden:TRUE];
        [self.scaleSliderViewTop setNeedsDisplay];
        [self setMeasuringUnit:@""];
    });
}


- (NSString *)measuringUnit
{
    return _measuringUnit;
}

- (void)setMeasuringUnit:(NSString *)measuringUnit
{
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        self.layer.sublayers = nil;
    //    });
    
    self->_measuringUnit = measuringUnit;
    
    NSMutableParagraphStyle *centerAlignedParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    centerAlignedParagraphStyle.alignment                = NSTextAlignmentCenter;
    NSDictionary *centerAlignedTextAttributes            = @{NSForegroundColorAttributeName:[UIColor systemYellowColor],
                                                             NSFontAttributeName:[UIFont systemFontOfSize:14.0],
                                                             NSParagraphStyleAttributeName:centerAlignedParagraphStyle};
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:_measuringUnit
                                                                           attributes:centerAlignedTextAttributes];
    dispatch_async(dispatch_get_main_queue(), ^{
        [textLayer setOpaque:FALSE];
        [textLayer setAlignmentMode:kCAAlignmentCenter];
        [textLayer setWrapped:TRUE];
        textLayer.string = attributedString;
        
        CGSize textLayerframeSize = [self suggestFrameSizeWithConstraints:self.layer.bounds.size forAttributedString:attributedString]; // this creates the right size frame now (so work it back in)
        CGRect buttonFrame = [[self selectedCameraPropertyFrame] CGRectValue];
        CGRect buttonFrameInSuperView = [self convertRect:buttonFrame toView:self];
        
        CGRect frame = CGRectMake(CGRectGetMidX(buttonFrameInSuperView) - (textLayerframeSize.width / 2.0), textLayerframeSize.height * 2.0, textLayerframeSize.width, textLayerframeSize.height);
        //        CGRect frame = CGRectMake(CGRectGetMidX([[self viewWithTag:[self selectedCameraProperty]] convertRect:[[self selectedCameraPropertyFrame] CGRectValue] toView:self]), /*(CGRectGetMidX([[self selectedCameraPropertyFrame] CGRectValue]).origin.x - ([[self selectedCameraPropertyFrame] CGRectValue].size.width / 2.0)) + 83.0*/, ((((CGRectGetMinY(self.bounds) + CGRectGetMidY(self.bounds)) / 2.0) + 6.0) + textLayerFrameY), 48.0, textLayerframeSize.height);
        
        textLayer.frame = frame;
        //        [textLayer setBackgroundColor:[UIColor redColor].CGColor];
        
        
    });
    
}

- (CGSize)suggestFrameSizeWithConstraints:(CGSize)size forAttributedString:(NSAttributedString *)attributedString
{
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFMutableAttributedStringRef)attributedString);
    CFRange attributedStringRange = CFRangeMake(0, attributedString.length);
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, attributedStringRange, NULL, size, NULL);
    CFRelease(framesetter);
    
    return suggestedSize;
}

- (NSValue *)selectedCameraPropertyFrame
{
    CGRect selectedCameraPropertyFrame = CGRectMake(CGRectGetMinX( (CGRect)[(UIButton *)[self viewWithTag:[self selectedCameraProperty]] frame] ),
                                                    CGRectGetMinY( (CGRect)[(UIButton *)[self viewWithTag:[self selectedCameraProperty]] frame] ),
                                                    CGRectGetWidth((CGRect)[(UIButton *)[self viewWithTag:[self selectedCameraProperty]] frame]),
                                                    CGRectGetHeight((CGRect)[(UIButton *)[self viewWithTag:[self selectedCameraProperty]] frame]));
    NSValue *selectedCameraPropertyValue = [NSValue valueWithCGRect:selectedCameraPropertyFrame];
    //    NSLog(@"selectedCameraPropertyFrame (2): %f", selectedCameraPropertyFrame.origin.x);
    
    return selectedCameraPropertyValue;
}

- (UIButton *)selectedCameraControlButton
{
    UIButton *selectedCameraControlButton = (UIButton *)[self viewWithTag:[self selectedCameraProperty]];
    
    return selectedCameraControlButton;
}
   

@end
