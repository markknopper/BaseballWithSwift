//
//  StatHead.h
//  BaseballQuery
//
//  Created by Matthew Jones on 5/29/10.
//  Copyright 2010-2018 Bulbous Ventures LLC. All rights reserved.
//
//
//  StatHead contains the knowledge necessary to compute various baseball stats.
//  The provides uniform calculations and reduces the amount of code everywhere.
//  The unconventional interface permits the StatHead class to be used to compute
//  stats in any context.
//

#import "Master.h"
#import "StatsDisplayStatType.h"

@interface StatHead : NSObject

+(NSString *)statNameForStatsDisplayStatType:(StatsDisplayStatType)stat_type;
+(StatsDisplayStatType)statsDisplayStatTypeForTypeName:(NSString *)typeName scopeName:(NSString *)scopeName;
+(NSInteger)battingAverageWithHits:(NSNumber *)H atBats:(NSNumber *)AB;
+(NSInteger)on_BasePctWithHits:(NSNumber *)H atBats:(NSNumber *)AB walks:(NSNumber *)BB hitByPitch:(NSNumber *)HBP sacFlies:(NSNumber *)SF;
+(NSInteger)sluggingPctWithHits:(NSNumber *)H atBats:(NSNumber *)AB doubles:(NSNumber *)doubles_2B triples:(NSNumber *)triples_3B homeRuns:(NSNumber *)HR;
+(double)WHIPWithWalks:(NSNumber *)BB hits:(NSNumber *)H outsPitched:(NSNumber *)IPouts;
+(NSInteger)inningsPitchedWithOutsPitched:(NSNumber *)IPouts;
+(BOOL)enoughAtBatsForBattingAverageRanking:(NSNumber *)AB;
+(BOOL)enoughOutsPitchedForERARank:(NSNumber *)IPouts;
+(NSString *)pitcherKindDeducedFromGames:(NSNumber *)G starts:(NSNumber *)GS saves:(NSNumber *)SV;
+(NSInteger)fieldingPercentageWithPutouts:(NSNumber *)putouts assists:(NSNumber *)assists errors:(NSNumber *)errors;
+(NSString *)leagueNameFromLeagueID:(NSString *)leagueID;
+(NSString *)divisionNameFromDivisionID:(NSString *)divisionID;
+(NSString *)teamNameFromTeamID:(NSString *)teamID andYear:(NSNumber *)yearID managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+(NSString *)playerNameFromPlayerID:(NSString *)playerID managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+(NSNumber *)firstYearInHistory;
+(NSNumber *)lastYearInHistory;
+(NSString *)positionNameFromPositionNumber:(NSNumber *)positionNumber;
+(BOOL)isCurrentTeam:(NSString *)teamName;

@end
