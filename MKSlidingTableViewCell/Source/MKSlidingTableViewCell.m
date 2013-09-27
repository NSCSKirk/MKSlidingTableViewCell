//
//  MKSlidingTableViewCell.m
//  MKSlidingTableViewCell
//
//  Created by Michael Kirk on 8/15/13.
//  Copyright (c) 2013 Michael Kirk. All rights reserved.
//

#import "MKSlidingTableViewCell.h"
#import "MKTableCellScrollView.h"

NSString * const MKDrawerDidOpenNotification = @"MKDrawerDidOpenNotification";
NSString * const MKDrawerDidCloseNotification = @"MKDrawerDidCloseNotification";

@interface MKSlidingTableViewCell () <UIScrollViewDelegate>
@property (nonatomic, strong) MKTableCellScrollView *containerScrollView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, getter = isOpen) BOOL open;
@end

@implementation MKSlidingTableViewCell

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        [self initializeCell];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [self initializeCell];
}

- (void)initializeCell
{
    self.open = NO;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutContainerScrollView];
    [self layoutDrawerView];
    [self layoutForegroundView];
}

- (void)layoutContainerScrollView
{
    CGRect scrollViewRect = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    CGSize scrollViewContentSize = CGSizeMake(CGRectGetWidth(self.bounds) + self.drawerRevealAmount, CGRectGetHeight(self.bounds));
    MKTableCellScrollView *containerScrollView = [[MKTableCellScrollView alloc] initWithFrame:scrollViewRect];
    
    containerScrollView.contentSize = scrollViewContentSize;
    containerScrollView.delegate = self;
    containerScrollView.showsHorizontalScrollIndicator = NO;
    containerScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.containerScrollView = containerScrollView;
    
    [self.contentView addSubview:containerScrollView];
}

- (void)layoutForegroundView
{
    self.containerScrollView.backgroundColor = self.backgroundColor;
    
    CGRect foregroundRect = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    self.foregroundView.frame = foregroundRect;
    
    [self.containerScrollView addSubview:self.foregroundView];
    [self addGestureRecognizerToForegroundView];
}

- (void)addGestureRecognizerToForegroundView
{
    [self.foregroundView removeGestureRecognizer:self.tapGestureRecognizer];
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    self.tapGestureRecognizer.numberOfTapsRequired = 1;
    self.tapGestureRecognizer.numberOfTouchesRequired = 1;
    [self.foregroundView addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if ([self.delegate respondsToSelector:@selector(didSelectSlidingTableViewCell:)])
    {
        [self.delegate didSelectSlidingTableViewCell:self];
    }
}

- (void)layoutDrawerView
{
    CGRect drawerRect = CGRectMake(CGRectGetWidth(self.bounds) - self.drawerRevealAmount, 0, self.drawerRevealAmount, CGRectGetHeight(self.bounds));
    self.drawerView.frame = drawerRect;
    
    [self.containerScrollView addSubview:self.drawerView];
}

#pragma mark - Custom Setters

- (void)setContainerScrollView:(MKTableCellScrollView *)containerScrollView
{
    [self.containerScrollView removeFromSuperview];
    _containerScrollView = containerScrollView;
}

- (void)setDrawerView:(UIView *)drawerView
{
    [self.drawerView removeFromSuperview];
    _drawerView = drawerView;
    [self setNeedsLayout];
}

- (void)setForegroundView:(UITableViewCell *)foregroundView
{
    [_foregroundView removeFromSuperview];
    _foregroundView = foregroundView;
    [self setNeedsLayout];
}

- (void)setDrawerRevealAmount:(CGFloat)drawerRevealAmount
{
    _drawerRevealAmount = drawerRevealAmount;
    [self setNeedsLayout];
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.containerScrollView.contentOffset.x < 0)
    {
        scrollView.contentOffset = CGPointZero;
    }
    
    CGFloat drawerX = scrollView.contentOffset.x + (CGRectGetWidth(self.bounds) - self.drawerRevealAmount);
    self.drawerView.frame = CGRectMake(drawerX, 0, self.drawerRevealAmount, CGRectGetHeight(self.bounds));
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (scrollView.contentOffset.x > (self.drawerRevealAmount / 2))
    {
        if (velocity.x < -0.4)
        {
            *targetContentOffset = CGPointZero;
            [self postCloseDrawerNotification];
        }
        else
        {
            [self openDrawerWithTargetContentOffset:targetContentOffset];
        }
    }
    else
    {
        if (velocity.x > 0.4)
        {
            [self openDrawerWithTargetContentOffset:targetContentOffset];
        }
        else
        {
            *targetContentOffset = CGPointZero;
            [self postCloseDrawerNotification];
        }
    }
}

- (void)openDrawerWithTargetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (!self.isOpen)
    {
        self.open = YES;
        
        NSNotification *notification = [NSNotification notificationWithName:MKDrawerDidOpenNotification object:self];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
    
    targetContentOffset->x  = self.drawerRevealAmount;
}

- (void)postCloseDrawerNotification
{
    if (self.isOpen)
    {
        self.open = NO;
        
        NSNotification *notification = [NSNotification notificationWithName:MKDrawerDidCloseNotification object:self];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

- (void)animateDrawerClose
{
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.containerScrollView.contentOffset = CGPointZero;
    } completion:nil];
}

#pragma mark - Public Methods

- (void)openDrawer
{
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.containerScrollView.contentOffset = CGPointMake(150, 0);
    } completion:nil];
}

- (void)closeDrawer
{
    [self animateDrawerClose];
    [self postCloseDrawerNotification];
}

@end
