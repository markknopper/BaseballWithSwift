//
//  TeamRankTabBarController.m
//  BaseballQuery
//
//  Created by Matthew Jones on 6/5/10.
//  Copyright 2010-2014 Bulbous Ventures LLC. All rights reserved.
//

#import "TeamRankTabBarController.h"
#import "TeamRankInYearViewController.h"
#import "TeamRankInFranchiseViewController.h"
#import "TeamRankInHistoryViewController.h"
#import "StatDescriptor.h"

@implementation TeamRankTabBarController

- (void)viewDidLoad
{
    TeamRankInYearViewController *rankInYearVC = (self.viewControllers)[0];
    rankInYearVC.showRankingInUnifiedList = YES;
    TeamRankInFranchiseViewController *rankInFranchiseVC = (self.viewControllers)[1];
    rankInFranchiseVC.showRankingInUnifiedList = NO;
    TeamRankInHistoryViewController *rankInHistoryVC = (self.viewControllers)[2];
    rankInHistoryVC.showRankingInUnifiedList = NO;
    for (id aVC in self.viewControllers) {
        [aVC setValue:_toSelect forKey:@"toSelect"];
        [aVC setValue:_statsDisplay forKey:@"statsDisplay"];
        [aVC setValue:_descriptorIndex forKey:@"descriptorIndex"];
    }
    [super viewDidLoad];
}

@end
