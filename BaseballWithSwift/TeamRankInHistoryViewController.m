    //
//  TeamRankInHistoryViewController.m
//  BaseballQuery
//
//  Created by Matthew Jones on 6/13/10.
//  Copyright 2010-2014 Bulbous Ventures LLC. All rights reserved.
//

#import "TeamRankInHistoryViewController.h"
#import "StatsDisplay.h"
#import "StatDescriptor.h"
#import "StatHead.h"

@implementation TeamRankInHistoryViewController

-(NSString *)cellIdentifier
{
    return @"TeamRankCell2";
}

//
//   
//   This predicate selects the team seasons to consider for ranking
//   Expand the list of teams to expand the scope of the ranking
//
- (NSPredicate *)teamSeasonSelectionPredicateWithSource:(id)teamToSelect {
	return [NSPredicate predicateWithValue:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"All-Time %@ Rankings",[StatHead statNameForStatsDisplayStatType:self.statsDisplay.type]];
    //[[self.statsDisplay.statDescriptors objectAtIndex:[self.descriptorIndex integerValue]] valueForKey:@"label"];
}



@end
