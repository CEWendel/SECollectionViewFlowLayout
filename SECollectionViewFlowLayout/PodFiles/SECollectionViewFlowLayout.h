//
//  SECollectionViewFlowLayout.h
//  SECollectionViewFlowLayout
//
//  Created by Chris Wendel on 2014/1/30.
//  Copyright (c) 2014 Chris Wendel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SECollectionViewFlowLayout : UICollectionViewFlowLayout <UIGestureRecognizerDelegate>

@property (nonatomic) BOOL panToDeselect; // If set to YES, enables the deselecting of cells by panning around on a touch down
@property (nonatomic) BOOL autoSelectRows; // If set to YES, a pan across a row and then down a column will auto-select all cells in each row as you scroll down (used to easily select a lot of cells rather than panning over every cell)
@property (nonatomic) BOOL autoSelectCellsBetweenTouches; // If set to YES, enables auto-selecting all cells between a first and second selected cell

+ (instancetype)layout;

+ (instancetype)layoutWithAutoSelectRows:(BOOL)autoSelectRows
                           panToDeselect:(BOOL)panToDeselect
           autoSelectCellsBetweenTouches:(BOOL)autoSelectCellsBetweenTouches;

@end
