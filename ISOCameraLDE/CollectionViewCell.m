//
//  CollectionViewCell.m
//  ISOCameraLDE
//
//  Created by Xcode Developer on 9/21/19.
//  Copyright © 2019 The Life of a Demoniac. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

@synthesize measuringUnit = _measuringUnit;

- (void)prepareForReuse
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.contentView.layer.sublayers = nil;
    });
}

- (NSString *)measuringUnit
{
    return _measuringUnit;
}

- (void)setMeasuringUnit:(NSString *)measuringUnit
{
    self->_measuringUnit = measuringUnit;
    
    CATextLayer *textLayer = [CATextLayer layer];
    NSMutableParagraphStyle *centerAlignedParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    centerAlignedParagraphStyle.alignment                = NSTextAlignmentCenter;
    NSDictionary *centerAlignedTextAttributes            = @{NSForegroundColorAttributeName:[UIColor systemBlueColor],
                                                            NSFontAttributeName:[UIFont systemFontOfSize:32.0],
                                                            NSParagraphStyleAttributeName:centerAlignedParagraphStyle};
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:_measuringUnit
                                                                           attributes:centerAlignedTextAttributes];
    dispatch_async(dispatch_get_main_queue(), ^{
        __block CGFloat textLayerFrameY = CGRectGetMinY(self.contentView.bounds);
        [textLayer setOpaque:FALSE];
        [textLayer setAlignmentMode:kCAAlignmentCenter];
        textLayer.string = attributedString;
        
        CGSize textLayerframeSize = [self suggestFrameSizeWithConstraints:self.contentView.bounds.size forAttributedString:attributedString];
        CGRect frame = CGRectMake(CGRectGetMinX(self.contentView.bounds), (CGRectGetMinY(self.contentView.bounds) + textLayerFrameY), /*textLayerframeSize.width*/CGRectGetWidth(self.contentView.frame), textLayerframeSize.height);
        textLayer.frame = frame;
        textLayerFrameY += textLayerframeSize.height;
        
        [self.contentView.layer addSublayer:textLayer];
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

@end
