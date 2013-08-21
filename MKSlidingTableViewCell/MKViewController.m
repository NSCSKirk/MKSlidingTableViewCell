//
//  MKViewController.m
//  MKSlidingTableViewCell
//
//  Created by Michael Kirk on 8/15/13.
//  Copyright (c) 2013 Michael Kirk. All rights reserved.
//

#import "MKViewController.h"
#import "MKSlidingTableViewCell.h"

@interface MKViewController ()
@property (nonatomic, copy) NSArray *data;
@property (nonatomic, strong) MKSlidingTableViewCell *activeCell;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@end

@implementation MKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.data = @[@"1", @"2", @"3", @"4", @"5"];
    self.tableView.dataSource = self;
    [self addObservers];
}

- (void)setActiveCell:(MKSlidingTableViewCell *)activeCell
{
    [_activeCell closeDrawer];
    _activeCell = activeCell;
}

- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willRevealDrawerViewForCell:) name:MKDrawerWillOpenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didHideDrawerViewForCell:) name:MKDrawerDidCloseNotification object:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MKSlidingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"container"];
    UITableViewCell *foregroundCell = [tableView dequeueReusableCellWithIdentifier:@"foreground"];
    UITableViewCell *backgroundCell = [tableView dequeueReusableCellWithIdentifier:@"background"];
    
    cell.foregroundView = foregroundCell;
    cell.drawerView = backgroundCell;
    
    foregroundCell.textLabel.text = self.data[indexPath.row];
    
    return cell;
}

- (void)willRevealDrawerViewForCell:(NSNotification *)notification
{
    MKSlidingTableViewCell *cell = notification.object;
    
    self.activeCell = cell;
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.tableView addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)didHideDrawerViewForCell:(NSNotification *)notification
{
    MKSlidingTableViewCell *cell = notification.object;
    
    if (cell == self.activeCell)
    {
        self.activeCell = nil;
        [self.tableView removeGestureRecognizer:self.tapGestureRecognizer];
    }
}

- (void)handleTapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    [self.activeCell closeDrawer];
}

@end
