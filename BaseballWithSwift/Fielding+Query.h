//
//  Fielding+Query.h
//  BaseballQuery
//
//  Created by Matthew Jones on 5/15/10.
//  Copyright 2010-14 Bulbous Ventures LLC. All rights reserved.
//

#import "Fielding.h"

@interface Fielding (Query)

@property (nonatomic, readonly) Teams *aTeamSeason;

-(NSString *)displayStringForStat:(NSString *)statName;
-(BOOL)justSayNoToRanking;
-(NSString *)kindName;

@end


