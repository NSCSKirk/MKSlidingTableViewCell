//
//  MKTableCellScrollView.h
//  MKSlidingTableViewCell
//
//  Created by Michael Kirk on 8/27/13.
//  Copyright (c) 2013 Michael Kirk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MKTableViewCellScrollViewDelegate;

@interface MKTableCellScrollView : UIScrollView

@property (nonatomic, weak) id<MKTableViewCellScrollViewDelegate> cellDelegate;

@end

@protocol MKTableViewCellScrollViewDelegate <NSObject>
- (void)didTapCellScrollView:(MKTableCellScrollView *)scrollView;
@end
