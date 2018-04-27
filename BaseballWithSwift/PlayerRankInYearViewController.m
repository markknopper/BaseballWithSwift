
//
//  PlayerRankInYearViewController.m
//  BaseballQuery
//
//  Created by Matthew Jones on 6/10/10.
//  Copyright 2010-2017 Bulbous Ventures LLC. All rights reserved.
//
//

#import "PlayerRankInYearViewController.h"
#import "StatHead.h"

@implementation PlayerRankInYearViewController

- (NSPredicate *)teamSeasonSelectionPredicateWithSource:(id)selection {
	return [NSPredicate predicateWithFormat:@"yearID == %d", [[selection valueForKeyPath:@"aTeamSeason.yearID"] intValue]];
}

- (void)doCustomSetup
{
    // Season: Batting Average - 1871
    self.section0HeaderTitle = [NSString stringWithFormat:@"%@ - %@ %@",self.statCategoryName,self.yearID,[StatHead statNameForStatsDisplayStatType:self.statsDisplay.type]];
    self.showAll = NO;
}

@end
