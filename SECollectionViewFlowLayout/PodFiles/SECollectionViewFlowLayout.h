//
//  SECollectionViewFlowLayout.h
//  SECollectionViewFlowLayout
//
//  Created by Chris Wendel on 2014/1/30.
//  Copyright (c) 2014 Chris Wendel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SECollectionViewFlowLayout : UICollectionViewFlowLayout <UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (nonatomic) BOOL panToDeselect;
@property (nonatomic) BOOL autoSelectRows;
@property (nonatomic) BOOL autoSelectCellsBetweenTouches;

+ (instancetype)layout;

+ (instancetype)layoutWithAutoSelectRows:(BOOL)autoSelectRows
                           panToDeselect:(BOOL)panToDeselect
           autoSelectCellsBetweenTouches:(BOOL)autoSelectCellsBetweenTouches;

@end
