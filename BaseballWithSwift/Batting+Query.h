//
//  Batting+Query.h
//  BaseballQuery
//
//  Created by Matthew Jones on 4/14/10.
//  Copyright 2010-2015 Bulbous Ventures LLC. All rights reserved.
//

#import "Batting.h"

@interface Batting (Query)

@property (nonatomic, readonly) Teams *aTeamSeason;

-(NSString *)displayStringForStat:(NSString *)statName;
-(NSString *)kindName;

@end

