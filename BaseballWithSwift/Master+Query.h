//
//  Master+Query.h
//  BaseballQuery
//
//  Created by Matthew Jones on 4/14/10.
//  Copyright 2010-2018 Bulbous Ventures LLC. All rights reserved.
//

#import "Master.h"
#import "Teams+Query.h"

@interface Master (Query)

@property (nonatomic, readonly) NSString *fullName;

//
//  Generic (and somewhat ugly) form of the function is more
//  easily used from generic browsing code, as the statsSelector
//  is available in the StatsDescriptor.
//
-(NSArray *)stats:(SEL)statsSelector forYear:(NSNumber *)yearID;

-(NSArray *)fieldingRecordsForTeamSeason:(Teams *)aTeamSeason;
-(NSArray *)battingSeasonsForTeamSeason:(Teams *)aTeamSeason;
-(NSArray *)pitchingSeasonsForTeamSeason:(Teams *)aTeamSeason;
-(NSArray *)managerSeasonsForTeamSeason:(Teams *)aTeamSeason;
-(NSArray *)fieldingRecordsForYear:(NSNumber *)yearID;
-(NSArray *)battingSeasonsForYear:(NSNumber *)yearID;
-(NSArray *)pitchingSeasonsForYear:(NSNumber *)yearID;
-(NSArray *)managerSeasonsForYear:(NSNumber *)yearID;
-(NSArray *)fieldingRecordsByPosition;
-(NSArray *)fieldingPostSeasonRecordsForYear:(NSNumber *)yearID;
-(NSArray *)battingPostSeasonRecordsForYear:(NSNumber *)yearID;
-(NSArray *)pitchingPostSeasonRecordsForYear:(NSNumber *)yearID;

//
//  Instead of [master valueForKeyPath:@"battingSeasons.@sum.G"]
//
//  we use this function:
//         [master sumAllExceptMissingForStatKind:@"battingSeasons" stat:@"G"];
//  because it filters out the missing data, which would otherwise make
//  the totals wrong (missing values are -1)
//
-(NSNumber *)sumAllExceptMissingForStatKind:(NSString *)statKind stat:(NSString *)statName;
//
//   Array of batting stints
//
//   Inner array is array of stats ordered by year (all for the same team)
//   Outer array is array of inner arrays ordered total number of games?
//         Could also order by year, but what about split stints?
//
//   The permits career data to be grouped by Team, and then provides
//   the natural start point for
//
//   Question remains about how to deal with team changes within a franchise?
//   Records extend across those boundaries, so maybe need a different grouping
//   criteria?
//
//-(NSArray *)battingSeasonsByFranchise;

-(NSString *)heightString;
-(NSString *)birthDateString;
-(NSString *)birthPlaceString;
-(NSString *)deathDateString;
-(NSString *)deathPlaceString;
-(NSArray *)allYearsForPlayer;
-(BOOL)checkIfPlayedInLatestYear;
-(NSString *)hofInductedYear;

+(Master *)masterRecordWithPlayerID:(NSString *)aPlayerID;
-(NSString *)debutFinalYearsString;
-(NSURL *)urlOnWebSite:(NSString *)webSite;

@end

