//
//  SECollectionViewFlowLayout.m
//  SECollectionViewFlowLayout
//
//  Created by Chris Wendel on 2014/1/30.
//  Copyright (c) 2014 Chris Wendel. All rights reserved.
//

#import "SECollectionViewFlowLayout.h"

static NSString * const kSECollectionViewKeyPath = @"collectionView";

@interface SECollectionViewFlowLayout ()

@property (nonatomic, assign, getter = isSelecting) BOOL selecting;

// Pan gesture states
@property (nonatomic, assign) BOOL selectedRow;
@property (nonatomic, assign) BOOL selectRowCancelled;
@property (nonatomic, assign) BOOL pannedFromFirstColumn;
@property (nonatomic, assign) BOOL pannedFromLastColumn;
@property (nonatomic, assign, getter = isDeselecting) BOOL deselecting;

// Touch gesture states
@property (nonatomic, strong) NSIndexPath *initialSelectedIndexPath;

@property (nonatomic, strong) NSIndexPath *previousIndexPath; // Used for auto selecting rows

@end

@implementation SECollectionViewFlowLayout

#pragma mark - Initializers

+ (instancetype)layout
{
    return [[self alloc] init];
}

+ (instancetype)layoutWithAutoSelectRows:(BOOL)autoSelectRows
                           panToDeselect:(BOOL)panToDeselect
           autoSelectCellsBetweenTouches:(BOOL)autoSelectCellsBetweenTouches
{
    return [[self alloc] initWithAutoSelectRows:autoSelectRows panToDeselect:panToDeselect autoSelectCellsBetweenTouches:autoSelectCellsBetweenTouches];
}

- (instancetype)initWithAutoSelectRows:(BOOL)autoSelectRows
                         panToDeselect:(BOOL)panToDeselect
         autoSelectCellsBetweenTouches:(BOOL)autoSelectCellsBetweenTouches
{
    self = [super init];
    
    if (self) {
        _autoSelectRows = autoSelectRows;
        _panToDeselect = panToDeselect;
        _autoSelectCellsBetweenTouches = autoSelectCellsBetweenTouches;
        
        [self initializer];
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        // All default to NO
        _panToDeselect = NO;
        _autoSelectRows = NO;
        _autoSelectCellsBetweenTouches = NO;
        
        [self initializer];
    }
    
    return self;
}

- (void)initializer
{
    // Pan states
    _selectRowCancelled = NO;
    _selecting = NO;
    _selectedRow = NO;
    _pannedFromFirstColumn = NO;
    _deselecting = NO;
    
    // Collection view layout properties
    self.minimumLineSpacing = 2.0;
    self.minimumInteritemSpacing = 2.0;
    self.itemSize = CGSizeMake(75.f, 75.f);
    
    // KVO
    [self addObserver:self forKeyPath:kSECollectionViewKeyPath options:NSKeyValueObservingOptionNew context:nil];
}

- (void)setupCollectionView
{
    // Add tap gesture recognizer
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.collectionView addGestureRecognizer:tapGestureRecognizer];
    
    // Add pan gesture recognizer
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGestureRecognizer.delegate = self;
    [self.collectionView addGestureRecognizer:panGestureRecognizer];
}

#pragma mark - Gesture handling

- (void)handleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer
{
    // Get index path at tapped point
    CGPoint point = [tapGestureRecognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
    
    // Handle tap
    if (indexPath) {
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        if (cell.isSelected) {
            [self deselectCellAtIndexPath:indexPath];
        } else {
            // Check if we should handle auto selecting the cells between two touches
            if (self.autoSelectCellsBetweenTouches) {
                if (self.initialSelectedIndexPath) {
                    [self selectAllItemsFromIndexPath:self.initialSelectedIndexPath toIndexPath:indexPath];
                    self.initialSelectedIndexPath = nil;
                } else {
                    self.initialSelectedIndexPath = indexPath;
                }
            }
            
            [self selectCellAtIndexPath:indexPath];
        }
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer
{
    // Get velocity and point of pan
    CGPoint velocity = [panGestureRecognizer velocityInView:self.collectionView];
    CGPoint point = [panGestureRecognizer locationInView:self.collectionView];
    
    if (!self.collectionView.isDecelerating) {
        // Handle pan
        if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
            // Reset pan states
            self.selecting = NO;
            self.selectedRow = NO;
            self.selectRowCancelled = NO;
            self.pannedFromFirstColumn = NO;
            self.pannedFromLastColumn = NO;
            self.deselecting = NO;
            self.previousIndexPath = nil;
        } else {
            if (fabs(velocity.x) < fabs(velocity.y) && !self.selecting) {
                // Register as scrolling the collection view
                self.selecting = NO;
            }else {
                // Register as selecting the cells, not scrolling the collection view
                self.selecting = YES;
                NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
                if (indexPath) {
                    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
                    if (cell.selected) {
                        if (self.panToDeselect) {
                            if (!self.previousIndexPath && ![self.previousIndexPath isEqual:indexPath]) self.deselecting = YES;
                            if (self.deselecting)   [self deselectCellAtIndexPath:indexPath];
                        }
                    } else {
                        if (!self.deselecting) {
                            [self selectCellAtIndexPath:indexPath];
                    
                            if (self.autoSelectRows) [self handleAutoSelectingRowsAtIndexPath:indexPath];
                        }
                    }
                
                    // Update previousIndexPath
                    self.previousIndexPath = indexPath;
                }
            }
        }
    }
}

#pragma mark - Auto select rows helpers

- (void)handleAutoSelectingRowsAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:indexPath.row + 1 inSection:indexPath.section];
    UICollectionViewCell *nextCell = [self.collectionView cellForItemAtIndexPath:nextIndexPath];
    
    // Check if this is the initial pan from the first column
    if (!self.previousIndexPath) {
        if (cell.frame.origin.x == self.minimumInteritemSpacing) {
            // Is the first cell in the row
            self.pannedFromFirstColumn = YES;
        } else if (!nextCell || nextCell.frame.origin.x < cell.frame.origin.x) {
            self.pannedFromLastColumn = YES;
        }
    }
    
    // Check to make sure we have not panned to another section
    if (abs(self.previousIndexPath.section != indexPath.section)) {
        self.selectedRow = NO;
    }
    
    // Figure out if this cell is in the first or last column
    BOOL didSelectAllItemsInRow = NO;
    if (!nextCell || nextCell.frame.origin.x < cell.frame.origin.x){
        if (self.pannedFromFirstColumn) {
            didSelectAllItemsInRow = [self didSelectAllItemsInRowWithIndexPath:indexPath];
        }
    } else if (cell.frame.origin.x == self.minimumInteritemSpacing) {
        if (self.pannedFromLastColumn) {
            didSelectAllItemsInRow = [self didSelectAllItemsInRowWithIndexPath:indexPath];
        }
    }
    
    // Check if we should cancel the row select
    if (self.previousIndexPath && !didSelectAllItemsInRow && labs(self.previousIndexPath.row - indexPath.row) > 1) {
        self.selectRowCancelled = YES;
    }
}

#pragma mark - Selection helpers

- (void)selectCellAtIndexPath:(NSIndexPath *)indexPath
{
    [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    [self.collectionView.delegate collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
}

- (void)deselectCellAtIndexPath:(NSIndexPath *)indexPath
{
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self.collectionView.delegate collectionView:self.collectionView didDeselectItemAtIndexPath:indexPath];
}

- (void)selectAllItemsFromIndexPath:(NSIndexPath *)initialIndexPath toIndexPath:(NSIndexPath *)finalIndexPath
{
    if (initialIndexPath.section == finalIndexPath.section) {
        // Check if initial and final index paths should be swapped
        if (finalIndexPath.row < initialIndexPath.row) {
            // Swap them
            NSIndexPath *tempFinalIndex = [NSIndexPath indexPathForItem:finalIndexPath.row inSection:finalIndexPath.section];
            finalIndexPath = initialIndexPath;
            initialIndexPath = tempFinalIndex;
        }
        
        // Select cells
        NSIndexPath *indexPath = initialIndexPath;
        for (NSInteger i = initialIndexPath.row; i < finalIndexPath.row; i++) {
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            if (!cell.isSelected) {
                [self selectCellAtIndexPath:indexPath];
            }
            indexPath = [NSIndexPath indexPathForItem:indexPath.row + 1 inSection:indexPath.section];
        }
    }
}

- (BOOL)didSelectAllItemsInRowWithIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectedRow) {
        // A row has been selected, so select all cells in row
        if (!self.selectRowCancelled) {
            if (self.pannedFromFirstColumn)
                [self selectRowFromLastColumnWithIndexPath:indexPath];
            else
                [self selectRowFromFirstColumnWithIndexPath:indexPath];
            
            return YES;
        }
    } else {
        self.selectedRow = YES;
    }
    
    return NO;
}

- (void)selectRowFromFirstColumnWithIndexPath:(NSIndexPath *)indexPath;
{
    NSIndexPath *rowIndexPath = indexPath;
    UICollectionViewCell *cell;
    
    // Used for figuring out when we are at the last cell on the column
    UICollectionViewCell *nextCell;
    NSIndexPath *nextIndexPath;
    
    // Loop through the cells on this row (from left to right)
    do {
        rowIndexPath = [NSIndexPath indexPathForItem:rowIndexPath.row + 1 inSection:rowIndexPath.section];
        cell = [self.collectionView cellForItemAtIndexPath:rowIndexPath];
        if (!cell.isSelected)   [self selectCellAtIndexPath:rowIndexPath];
        
        nextIndexPath = [NSIndexPath indexPathForItem:rowIndexPath.row + 1 inSection:rowIndexPath.section];
        nextCell = [self.collectionView cellForItemAtIndexPath:nextIndexPath];
    } while (nextCell.frame.origin.x > cell.frame.origin.x);
}

- (void)selectRowFromLastColumnWithIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *rowIndexPath = indexPath;
    UICollectionViewCell *cell;
    
    // Loop through the cells on this row (from right to left)
    do {
        rowIndexPath = [NSIndexPath indexPathForItem:rowIndexPath.row - 1 inSection:rowIndexPath.section];
        cell = [self.collectionView cellForItemAtIndexPath:rowIndexPath];
        if (!cell.isSelected)   [self selectCellAtIndexPath:rowIndexPath];
    } while (cell.frame.origin.x != self.minimumInteritemSpacing); // TODO
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    BOOL recognizeSimultaneously = !self.isSelecting;
    return recognizeSimultaneously;
}

#pragma mark - Key-Value Observing methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:kSECollectionViewKeyPath]) {
        if (self.collectionView != nil) {
            [self setupCollectionView];
        }
    }
}

#pragma mark - Dealloc

- (void)dealloc
{
    [self removeObserver:self forKeyPath:kSECollectionViewKeyPath];
}

@end
