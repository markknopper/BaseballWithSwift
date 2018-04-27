//
//  Teams+Query.h
//  BaseballQuery
//
//  Created by Matthew Jones on 5/12/10.
//  Copyright 2010-18 Bulbous Ventures LLC. All rights reserved.
//

#import "Teams.h"

//
//  Model should have knowledge about what makes someone a batter, or a pitcher, etc...
//  When computing team totals, do we need to make sure to discount the non-batters
//  from the batting stats calculations?
//
@interface Teams (Query)

- (NSArray *)rosterInNameOrder;
- (NSArray *)rosterKind:(NSString *)rosterKind inStatOrder:(NSString *)statKey ascending:(BOOL)ascending;
-(NSString *)displayStringForStat:(NSString *)statName;
-(NSNumber *) shouldRankForBattingAverage;

+(Teams *)teamWithTeamID:(NSString *)teamID andYear:(NSNumber *)yearID inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@property (nonatomic) NSNumber *oPS;

@end
