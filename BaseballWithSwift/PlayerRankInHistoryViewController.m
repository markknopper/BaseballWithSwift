//
//  PlayerRankInHistoryViewController.m
//  BaseballQuery
//
//  Created by Matthew Jones on 6/14/10.
//  Copyright 2010-2017 Bulbous Ventures LLC. All rights reserved.
//

#import "PlayerRankInHistoryViewController.h"
#import "Batting+Query.h"
#import "StatHead.h"

@implementation PlayerRankInHistoryViewController

- (NSPredicate *)teamSeasonSelectionPredicateWithSource:(id)selection {
	return [NSPredicate predicateWithValue:YES];
}

- (void)doCustomSetup
{
    [_spinner startAnimating];
    // eg: Batting Average - All Time with optional "- POS"
    NSString *positionSuffix = @"";
    if (self.statsDisplay.type == (StatsDisplayStatScopeCareer|StatsDisplayStatTypeFielding))
        positionSuffix = [NSString stringWithFormat:@" - %@",[self.toSelect valueForKey:@"pos"]];
    self.section0HeaderTitle = [NSString stringWithFormat:@"%@ - All Time%@ %@", [StatHead statNameForStatsDisplayStatType:self.statsDisplay.type],positionSuffix, self.statCategoryName];
    self.showAll = NO;
}

-(void)subclassUserInterfaceStuffToDoWhenDataIsReady
{
    [_spinner stopAnimating]; // hides when stopped
}

@end
