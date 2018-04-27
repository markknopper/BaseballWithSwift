//
//  Manager+Query.h
//  BaseballQuery
//
//  Created by Matthew Jones on 4/14/10.
//  Copyright 2010-2015 Bulbous Ventures LLC. All rights reserved.
//
#import "Master.h"
#import "Managers.h"

@interface Managers (Query)

@property (nonatomic, readonly) NSString *percentage;

-(NSString *)displayStringForStat:(NSString *)statName;
-(NSString *)kindName;

@end

