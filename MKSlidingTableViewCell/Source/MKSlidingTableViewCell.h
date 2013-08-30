//
//  MKSlidingTableViewCell.h
//  MKSlidingTableViewCell
//
//  Created by Michael Kirk on 8/15/13.
//  Copyright (c) 2013 Michael Kirk. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const MKDrawerDidOpenNotification;
extern NSString * const MKDrawerDidCloseNotification;

@protocol MKSlidingTableViewCellDelegate;

@interface MKSlidingTableViewCell : UITableViewCell

@property (nonatomic, weak) id<MKSlidingTableViewCellDelegate> delegate;
@property (nonatomic, strong) UIView *foregroundView;
@property (nonatomic, strong) UIView *drawerView;
@property (nonatomic, assign) CGFloat drawerRevealAmount;

- (void)openDrawer;
- (void)closeDrawer;

@end

@protocol MKSlidingTableViewCellDelegate <NSObject>
@optional
- (void)didSelectSlidingTableViewCell:(MKSlidingTableViewCell *)cell;
@end
