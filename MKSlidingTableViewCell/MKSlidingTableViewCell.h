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

@interface MKSlidingTableViewCell : UITableViewCell

@property (nonatomic, strong) UIView *foregroundView;
@property (nonatomic, strong) UIView *drawerView;
@property (nonatomic, assign) CGFloat drawerRevealAmount;

- (void)closeDrawer;

@end
