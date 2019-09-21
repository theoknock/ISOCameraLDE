//
//  CollectionViewCell.h
//  ISOCameraLDE
//
//  Created by Xcode Developer on 9/21/19.
//  Copyright © 2019 The Life of a Demoniac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

NS_ASSUME_NONNULL_BEGIN

@interface CollectionViewCell : UICollectionViewCell

@property (copy, nonatomic, setter=setMeasuringUnit:) NSString *measuringUnit;

@end

NS_ASSUME_NONNULL_END
