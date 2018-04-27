//
//  PlayerRankInTeamViewController.m
//  BaseballQuery
//
//  Created by Matthew Jones on 6/10/10.
//  Copyright 2010-2017 Bulbous Ventures LLC. All rights reserved.
//
//
#import "PlayerRankInTeamViewController.h"
#import "StatHead.h"
#import "BaseballQueryAppDelegate.h"
#import "Fielding+Query.h"

// Player rank in team-year.

@implementation PlayerRankInTeamViewController

- (NSPredicate *)teamSeasonSelectionPredicateWithSource:(id)selection {
	return nil;
}

- (void)doCustomSetup
{
    BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (self.yearID != nil) {
        // Batting Average - 1871 Philadelphia Athletics
        self.section0HeaderTitle = [NSString stringWithFormat:@"%@ - %@ %@ %@",self.statCategoryName,self.yearID,[StatHead teamNameFromTeamID:[self.toSelect valueForKey:@"teamID"] andYear:self.yearID managedObjectContext:[appDel managedObjectContext]],[StatHead statNameForStatsDisplayStatType:self.statsDisplay.type]];
    }
    else // no year, must be career ranking. Does career just work other than title?? Let's assume it does and see how far we get.
        self.section0HeaderTitle = self.title;
    self.showAll = YES;
}

@end
