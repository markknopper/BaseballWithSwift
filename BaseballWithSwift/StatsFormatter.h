//
//  StatsFormatter.h
//  BaseballQuery
//
//  Created by Matthew Jones on 5/28/10.
//  Copyright 2010-2015 Bulbous Ventures LLC. All rights reserved.
//

//  Stats formatting functions
//  This is the central place for all of them to reduce code and
//  bugs.
//

@import UIKit;

@interface StatsFormatter : NSObject

+(NSString *)averageInThousandFormPaddedToFiveChars:(NSInteger)average;
+(NSString *)averageInThousandFormForNSNumber:(NSNumber *)averageFloatInNSNumber;
+(NSString *)averageInThousandFormForNSNumberPaddedToFiveChars:(NSNumber *)averageFloatInNSNumber;
+(NSString *)averageInThousandForm:(NSInteger)average;
+(NSString *)standardERAForm:(double)anERA;
+(NSString *)standardWHIPForm:(double)aWHIP;
+(NSString *)standardWHIPFormForNSNumber:(NSNumber *)aWHIPInNSNumber;
+(NSString *)inningsInDecimalFormFromInningOuts:(NSInteger)inning_outs;
+(NSString *)percentagePaddedToFiveChars:(NSInteger)integer_percentage_value;
+(NSString *)largeNumberInCommaFormWithNSNumber:(NSNumber *)largeNumber;
+(NSString *)yearStringFromDateField:(NSString *)dateField;

NSString * format_stat_int(NSInteger the_stat,NSInteger width);
NSString * format_stat(NSNumber *theStat,NSInteger width);
NSInteger tally_with_na_check(NSInteger the_total, NSNumber * yearStat);

@end
