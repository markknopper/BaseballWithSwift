//
//  NotifyTableView.m
//  BaseballQuery
//
//  Created by Mark Knopper on 1/20/12.
//  Copyright (c) 2012-2016 Bulbous Ventures LLC. All rights reserved.
//

#import "NotifyTableView.h"
#import "QueryResultsViewController.h"

@implementation NotifyTableView

- (void)reloadData
{
    [super reloadData];
    [self.delegate performSelector:@selector(dataIsReloaded:) withObject:self];
}

@end
