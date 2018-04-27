    //
//  PlayerRankTabBarController.m
//  BaseballQuery
//
//  Created by Matthew Jones on 6/5/10.
//  Copyright 2010-2015 Bulbous Ventures LLC. All rights reserved.
//

#import "StatDescriptor.h"
#import "PlayerRankTabBarController.h"
#import "PlayerRankInTeamViewController.h"
#import "PlayerRankInFranchiseViewController.h"
#import "PlayerRankInYearViewController.h"
#import "PlayerRankInHistoryViewController.h"
#import "StatHead.h"
#import "BaseballQueryAppDelegate.h"
#import "Teams.h"

@implementation PlayerRankTabBarController

-(void)viewWillAppear:(BOOL)animated {
    // Init the same stuff in all view controllers.
    for (id aViewController in self.viewControllers) {
        [aViewController setValue:_toSelect forKey:@"toSelect"]; // StatSource
        [aViewController setValue:_statsDisplay forKey:@"statsDisplay"];
        [aViewController setValue:self.descriptorIndex forKey:@"descriptorIndex"];
        [aViewController setValue:self.yearID forKey:@"yearID"];
    }
    [super viewWillAppear:animated];
}

@end
