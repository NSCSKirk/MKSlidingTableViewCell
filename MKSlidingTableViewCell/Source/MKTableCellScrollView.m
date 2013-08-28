//
//  MKTableCellScrollView.m
//  MKSlidingTableViewCell
//
//  Created by Michael Kirk on 8/27/13.
//  Copyright (c) 2013 Michael Kirk. All rights reserved.
//

#import "MKTableCellScrollView.h"

@implementation MKTableCellScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.enabled = YES;
        tapGesture.cancelsTouchesInView = NO;
        [self addGestureRecognizer:tapGesture];
    }
    
    return self;
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    [self.cellDelegate didTapCellScrollView:self];
}

@end
