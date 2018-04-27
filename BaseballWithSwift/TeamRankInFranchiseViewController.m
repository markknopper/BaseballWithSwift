    //
//  TeamRankInFranchiseViewController.m
//  BaseballQuery
//
//  Created by Matthew Jones on 6/13/10.
//  Copyright 2010-2014 Bulbous Ventures LLC. All rights reserved.
//

#import "TeamRankInFranchiseViewController.h"
#import "StatsDisplay.h"
#import "StatDescriptor.h"
#import "BaseballQueryAppDelegate.h"
#import "StatHead.h"
#import "ThisYear.h"

@implementation TeamRankInFranchiseViewController

-(NSString *)cellIdentifier
{
    return @"TeamRankCell1";
}

//   
//   This predicate selects the team seasons to consider for ranking
//   Expand the list of teams to expand the scope of the ranking
//
- (NSPredicate *)teamSeasonSelectionPredicateWithSource:(id)teamToSelect {
    NSString *franchisePredicateFormat = @"franchID == %@";
    BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDel.latest_year_in_database < LATEST_DATA_YEAR) {
        // If haven't purchased the latest,
        franchisePredicateFormat = [NSString stringWithFormat:@"%@ AND yearID < %d",franchisePredicateFormat,LATEST_DATA_YEAR];
    }
	return [NSPredicate predicateWithFormat:franchisePredicateFormat, [teamToSelect valueForKey:@"franchID"]];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [NSString stringWithFormat:@"Franchise %@ Rankings",
            [StatHead statNameForStatsDisplayStatType:self.statsDisplay.type]];
}

@end
