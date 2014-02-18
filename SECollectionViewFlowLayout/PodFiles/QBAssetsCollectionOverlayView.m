//
//  QBAssetsCollectionOverlayView.m
//  QBImagePickerController
//
//  Created by Tanaka Katsuma on 2014/01/01.
//  Copyright (c) 2014年 Katsuma Tanaka. All rights reserved.
//

#import "QBAssetsCollectionOverlayView.h"
#import <QuartzCore/QuartzCore.h>

// Views
#import "QBAssetsCollectionCheckmarkView.h"

@interface QBAssetsCollectionOverlayView ()

@end

@implementation QBAssetsCollectionOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        // View settings
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        
        // Create a checkmark view
        QBAssetsCollectionCheckmarkView *checkmarkView = [[QBAssetsCollectionCheckmarkView alloc] initWithFrame:CGRectMake(self.bounds.size.width - (4.0 + 24.0), self.bounds.size.height - (4.0 + 24.0), 24.0, 24.0)];
        checkmarkView.autoresizingMask = UIViewAutoresizingNone;
        
        [self addSubview:checkmarkView];
    }
    
    return self;
}

@end
