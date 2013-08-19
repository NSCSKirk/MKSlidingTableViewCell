//
//  MKSlidingTableViewCell.h
//  MKSlidingTableViewCell
//
//  Created by Michael Kirk on 8/15/13.
//  Copyright (c) 2013 Michael Kirk. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const MKDrawerWillOpenNotification;
extern NSString * const MKDrawerDidCloseNotification;

@protocol MKSlidingTableViewCellDelegate;

@interface MKSlidingTableViewCell : UITableViewCell

@property (nonatomic, weak) id<MKSlidingTableViewCellDelegate> delegate;
@property (nonatomic, strong) UIView *foregroundView;
@property (nonatomic, strong) UIView *drawerView;

- (void)closeDrawer;

@end

@protocol MKSlidingTableViewCellDelegate <NSObject>
@optional
- (NSArray *)subviewsForDrawerViewInCell:(MKSlidingTableViewCell *)cell;
@end
