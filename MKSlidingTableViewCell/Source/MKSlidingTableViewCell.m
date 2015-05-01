//
//  MKSlidingTableViewCell.m
//  MKSlidingTableViewCell
//
//  Created by Michael Kirk on 8/15/13.
//  Copyright (c) 2013 Michael Kirk. All rights reserved.
//

#import "MKSlidingTableViewCell.h"

NSString * const MKDrawerDidOpenNotification = @"MKDrawerDidOpenNotification";
NSString * const MKDrawerDidCloseNotification = @"MKDrawerDidCloseNotification";

@interface MKSlidingTableViewCell () <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *containerScrollView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
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

- (void)prepareForReuse
{
    self.open = NO;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutContainerScrollView];
    [self layoutDrawerView];
    [self layoutForegroundView];
    [self setScrollViewOffsetIfDrawerIsOpen];
}

- (void)setScrollViewOffsetIfDrawerIsOpen
{
    if (self.isOpen)
    {
        self.containerScrollView.contentOffset = CGPointMake(self.drawerRevealAmount, 0.0f);
    }
}

- (void)layoutContainerScrollView
{
    CGRect scrollViewRect = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    CGSize scrollViewContentSize = CGSizeMake(CGRectGetWidth(self.bounds) + self.drawerRevealAmount, CGRectGetHeight(self.bounds));
    UIScrollView *containerScrollView = [[UIScrollView alloc] initWithFrame:scrollViewRect];
    
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

- (void)setContainerScrollView:(UIScrollView *)containerScrollView
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

- (void)setOpen:(BOOL)open
{
    _open = open;
    if (open) {
        [self installCloseDrawerAction];
    } else {
        [self installOpenDrawerAction];
    }
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
        }
        else
        {
            [self openDrawerWithTargetContentOffset:targetContentOffset];
        }
    }
    else if (scrollView.contentOffset.x == 0)
    {
        [self postCloseDrawerNotification];
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
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x == 0)
    {
        [self postCloseDrawerNotification];
    }
}

- (void)openDrawerWithTargetContentOffset:(inout CGPoint *)targetContentOffset
{
    targetContentOffset->x = self.drawerRevealAmount;
    [self postOpenDrawerNotification];
}

- (void)postOpenDrawerNotification
{
    if (!self.isOpen)
    {
        self.open = YES;
        
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self);
        NSNotification *notification = [NSNotification notificationWithName:MKDrawerDidOpenNotification object:self];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

- (void)postCloseDrawerNotification
{
    if (self.isOpen)
    {
        self.open = NO;
        
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self);
        NSNotification *notification = [NSNotification notificationWithName:MKDrawerDidCloseNotification object:self];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

- (void)animateDrawerClose:(void(^)())completion
{
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.containerScrollView.contentOffset = CGPointZero;
    } completion:^(BOOL finished) {
        [self postCloseDrawerNotification];
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - Public Methods

- (void)openDrawer
{
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.containerScrollView.contentOffset = CGPointMake(150, 0);
    } completion:^(BOOL finished) {
        [self postOpenDrawerNotification];
    }];
}

- (void)closeDrawer
{
    [self animateDrawerClose:nil];
}

- (void)closeDrawer:(void(^)())completion
{
    [self animateDrawerClose:completion];
}

#pragma mark - Invocation Handling

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return self.foregroundView;
}

#pragma mark - Accessibility

- (NSInteger)accessibilityElementCount
{
    return 1;
}

- (id)accessibilityElementAtIndex:(NSInteger)index
{
    if (index == 0) {
        if (self.open) {
            return self.drawerView;
        } else {
            return self.foregroundView;
        }
    }
    return nil;
}

- (NSInteger)indexOfAccessibilityElement:(id)element
{
    if (element == self.drawerView || element == self.foregroundView) {
        return 0;
    }
    return NSNotFound;
}

- (void)installOpenDrawerAction
{
    // UIAccessibilityCustomAction was just added in iOS 8.
    if (NSClassFromString(@"UIAccessibilityCustomAction") != nil) {
        UIAccessibilityCustomAction *action = [[UIAccessibilityCustomAction alloc] initWithName:@"More options"
                                                                                         target:self
                                                                                       selector:@selector(openDrawer)];
        self.accessibilityCustomActions = @[action];
    }
}

- (void)installCloseDrawerAction
{
    // UIAccessibilityCustomAction was just added in iOS 8.
    if (NSClassFromString(@"UIAccessibilityCustomAction") != nil) {
        UIAccessibilityCustomAction *action = [[UIAccessibilityCustomAction alloc] initWithName:@"Fewer options"
                                                                                         target:self
                                                                                       selector:@selector(closeDrawer)];
        self.accessibilityCustomActions = @[action];
    }
}

@end
