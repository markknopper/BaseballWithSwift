    //
//  TeamRankInYearViewController.m
//  BaseballQuery
//
//  Created by Matthew Jones on 6/13/10.
//  Copyright 2010-2014 Bulbous Ventures LLC. All rights reserved.
//

#import "TeamRankInYearViewController.h"

@implementation TeamRankInYearViewController

-(NSString *)cellIdentifier
{
    return @"TeamRankCell0";
}

//   
//   This predicate selects the team seasons to consider for ranking
//   Expand the list of teams to expand the scope of the ranking
//
- (NSPredicate *)teamSeasonSelectionPredicateWithSource:(id)teamToSelect {
	return [NSPredicate predicateWithFormat:@"yearID == %d", [[teamToSelect valueForKey:@"yearID"] intValue]];
}

@end
