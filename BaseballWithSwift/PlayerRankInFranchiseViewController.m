//
//  PlayerRankInFranchiseViewController.m
//  BaseballQuery
//
//  Created by Matthew Jones on 6/10/10.
//  Copyright 2010-2018 Bulbous Ventures LLC. All rights reserved.
//
//  A player's single year stats (selected at drill-through)
//  have a rank in all of the single-year stats for the history
//  of the franchise.
//
//  This view controller accepts a set of player stats,
//  a statsDisplay template and a descriptor index for the
//  stat on which the ranking should occur, then produces the
//  ranked list of Player single-season stats for the franchise.
//
//  Each entry is labelled with the year, so some players can
//  be listed multiple times in the rankings.   Witness the Yankees
//  rankings and see Babe Ruth multiple times.
//

#import "PlayerRankInFranchiseViewController.h"
#import "Teams+Query.h"
#import "StatHead.h"

@implementation PlayerRankInFranchiseViewController

- (NSPredicate *)teamSeasonSelectionPredicateWithSource:(id)selection {
	return [NSPredicate predicateWithFormat:@"franchID == %@", [selection valueForKeyPath:@"aTeamSeason.franchID"]];
}

- (void)doCustomSetup
{
    [_spinner startAnimating];
    // Franchise: Batting Average - PNA Franchise
    Teams *ourTeam = [self.toSelect valueForKey:@"teamSeason"];
    self.section0HeaderTitle = [NSString stringWithFormat:@"%@ - %@ Franchise %@",self.statCategoryName,ourTeam.franchID,[StatHead statNameForStatsDisplayStatType:self.statsDisplay.type]];
    self.showAll = NO;
}

-(void)subclassUserInterfaceStuffToDoWhenDataIsReady
{
    [_spinner stopAnimating];
}

@end
