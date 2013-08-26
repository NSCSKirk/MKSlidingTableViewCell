//
//  MKSlidingTableViewCell.m
//  MKSlidingTableViewCell
//
//  Created by Michael Kirk on 8/15/13.
//  Copyright (c) 2013 Michael Kirk. All rights reserved.
//

#import "MKSlidingTableViewCell.h"

NSString * const MKDrawerWillOpenNotification = @"MKDrawerWillOpenNotification";
NSString * const MKDrawerDidCloseNotification = @"MKDrawerDidCloseNotification";

@interface MKSlidingTableViewCell () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UIView *container;
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
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    self.panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.panGestureRecognizer];
    
    self.container = [[UIView alloc] initWithFrame:self.frame];
    self.open = NO;
    self.drawerRevealAmount = 0.0;
}

#pragma mark - Custom Setters

- (void)setForegroundView:(UITableViewCell *)foregroundView
{
    [_foregroundView removeFromSuperview];
    _foregroundView = foregroundView;
    
    self.container.backgroundColor = self.backgroundColor;
    
    [self.container addSubview:foregroundView];
    [self.contentView addSubview:self.container];
}

#pragma mark - UIGestureRecognizer Methods

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panRecognizer
{
    if ([panRecognizer respondsToSelector:@selector(velocityInView:)] == NO)
    {
        return [super gestureRecognizerShouldBegin:panRecognizer];
    }
    
    CGPoint velocity = [panRecognizer velocityInView:self];
    return ABS(velocity.x) > ABS(velocity.y); // Horizontal panning
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)sender
{    
    switch (sender.state)
    {
        case UIGestureRecognizerStateBegan:
            [self handlePanBegin];
            break;
        case UIGestureRecognizerStateChanged:
            [self handlePanUpdate];
            break;
        case UIGestureRecognizerStateEnded:
            [self handlePanEnd];
            break;
        default:
            break;
    }
}

- (void)handlePanBegin
{
    CGPoint drawerPoint = CGPointMake(self.frame.size.width - self.drawerView.frame.size.width, 0);
    CGRect drawerRect = CGRectMake(drawerPoint.x, drawerPoint.y, self.drawerView.frame.size.width, self.frame.size.height);
    
    self.drawerView.frame = drawerRect;
    [self.contentView insertSubview:self.drawerView belowSubview:self.container];
    
    if (self.isOpen == NO)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:MKDrawerWillOpenNotification object:self];
    }
}

- (void)handlePanUpdate
{
    CGPoint translation = [self.panGestureRecognizer translationInView:self];
    CGPoint contentPosition = self.container.center;
    
    contentPosition.x += translation.x;
    
    if (contentPosition.x > self.center.x)
    {
        return;
    }
    
    self.container.center = contentPosition;
    [self.panGestureRecognizer setTranslation:CGPointZero inView:self];
}

- (void)handlePanEnd
{
    CGFloat containerRightEdge = CGRectGetMaxX(self.container.frame);
    CGFloat drawerLeftSubviewEdge = [self drawerLeftBoundary];
    CGFloat drawerMiddle = [self drawerSubviewMiddleFromLeftEdge:drawerLeftSubviewEdge];
    
    if (containerRightEdge < drawerMiddle && containerRightEdge < drawerLeftSubviewEdge)
    {
        [self animateContainerToDrawerLeftEdgeWithBounce:drawerLeftSubviewEdge];
    }
    else if (containerRightEdge < drawerMiddle && containerRightEdge > drawerLeftSubviewEdge)
    {
        [self animateContainerToDrawerLeftEdge:drawerLeftSubviewEdge];
    }
    else
    {
        [self animateContainerToOriginalPosition];
    }
}

- (CGFloat)drawerLeftBoundary
{
    if (self.drawerRevealAmount != 0)
    {
        return CGRectGetWidth(self.frame) - self.drawerRevealAmount;
    }
    else if ([self.drawerView isKindOfClass:[UITableViewCell class]])
    {
        return [self drawerViewLeftMostSubviewEdge];
    }
    else
    {
        return CGRectGetMinX(self.drawerView.frame);
    }
}

- (CGFloat)drawerViewLeftMostSubviewEdge
{
    CGFloat leftSubviewEdge = CGRectGetMaxX(self.frame);
    NSArray *drawerSubviews = [self drawerSubviews];
    
    for (UIView *subview in drawerSubviews)
    {
        leftSubviewEdge = MIN(leftSubviewEdge, CGRectGetMinX(subview.frame));
    }
    
    return leftSubviewEdge;
}

- (NSArray *)drawerSubviews
{
    UITableViewCell *cell = (UITableViewCell *)self.drawerView;
    return cell.contentView.subviews;
}

- (CGFloat)drawerSubviewMiddleFromLeftEdge:(CGFloat)drawerLeftSubviewEdge
{
    CGFloat drawerRightEdge = CGRectGetMaxX(self.frame);
    CGFloat drawerWidth = drawerRightEdge - drawerLeftSubviewEdge;
    CGFloat drawerMiddle = drawerLeftSubviewEdge + (drawerWidth / 2);
    
    return drawerMiddle;
}

- (void)animateContainerToDrawerLeftEdgeWithBounce:(CGFloat)drawerLeftEdge
{
    CGFloat damping = 0.6;
    CGFloat velocityX = [self.panGestureRecognizer velocityInView:self].x;
    CGFloat velocityByPoints = 320.0/ABS(velocityX);
    CGFloat pointsPerSecond = ABS(velocityX)/60;
    
    if (velocityByPoints < 0.3)
    {
        [UIView animateWithDuration:velocityByPoints * damping delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            CGFloat currentX = self.container.center.x;
            CGFloat newX = currentX - pointsPerSecond;
            CGPoint newCenter = CGPointMake(newX, self.container.center.y);
            self.container.center = newCenter;
        } completion:^(BOOL finished) {
            [self animateContainerToDrawerLeftEdge:drawerLeftEdge];
        }];
    }
    else
    {
        [self animateContainerToDrawerLeftEdge:drawerLeftEdge];
    }
}

- (void)animateContainerToDrawerLeftEdge:(CGFloat)drawerLeftEdge
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGFloat newX = drawerLeftEdge - self.container.frame.size.width / 2;
        CGPoint newCenter = CGPointMake(newX, self.container.center.y);
        self.container.center = newCenter;
    } completion:^(BOOL finished) {
        self.open = YES;
    }];
}

- (void)animateContainerToOriginalPosition
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.container.center = CGPointMake(self.center.x, self.contentView.center.y);
    } completion:^(BOOL finished) {
        [self.drawerView removeFromSuperview];
        self.open = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:MKDrawerDidCloseNotification object:self];
    }];
}

#pragma mark - Public Methods

- (void)closeDrawer
{
    [self animateContainerToOriginalPosition];
}

@end
