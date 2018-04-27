//
//  StatsFormatter.m
//  BaseballQuery
//
//  Created by Matthew Jones on 5/28/10.
//  Copyright 2010-2015 Bulbous Ventures LLC. All rights reserved.
//

#import "StatsFormatter.h"

@implementation StatsFormatter

+(NSString *)averageInThousandFormPaddedToFiveChars:(NSInteger)average {
    NSString *averageToReturn = [self averageInThousandForm:average];
    if ([averageToReturn length]==4)
        averageToReturn = [NSString stringWithFormat:@" %@",averageToReturn];
    return averageToReturn;
}

+(NSString *)averageInThousandFormForNSNumberPaddedToFiveChars:(NSNumber *)averageFloatInNSNumber
{
    NSString *averageToReturn = [self averageInThousandFormForNSNumber:averageFloatInNSNumber];
    if ([averageToReturn length]==4)
        averageToReturn = [NSString stringWithFormat:@" %@",averageToReturn];
    return averageToReturn;
}

+(NSString *)averageInThousandFormForNSNumber:(NSNumber *)averageFloatInNSNumber
{
    NSString *thousandForm = @"-1";
    CGFloat average_real = [averageFloatInNSNumber floatValue];
	if (average_real >= 1.0)
        // It seems that %*.*f rounds up.
        thousandForm = [NSString stringWithFormat:@"%1.3f", average_real];
    else if (average_real >= 0) {
        // For int, need to round up ourselves.
        NSInteger integer_form = average_real * 1000.0 + .5;
        thousandForm = [NSString stringWithFormat:@".%03ld", (long)integer_form];
    }
    return thousandForm;
}

+(NSString *)averageInThousandForm:(NSInteger)average {
	NSString *thousandForm = @"-1";
	if (average >= 1000) {
		thousandForm = [NSString stringWithFormat:@"%1.3f", (double)average/1000.0];
	} else if (average >= 0) {
		thousandForm = [NSString stringWithFormat:@".%03ld",(long)average];
	}
	return thousandForm;					
}

+(NSString *)standardERAForm:(double)anERA {
	NSString *ERAForm = nil;
	if (anERA >= 0) {
		ERAForm = [NSString stringWithFormat:@"%1.2f",anERA];	
	} else {
		ERAForm = @"-1";
	}
	return ERAForm;
}

+(NSString *)standardWHIPForm:(double)aWHIP {
	NSString *WHIPForm = nil;
	if (aWHIP >= 0) {
		WHIPForm = [NSString stringWithFormat:@"%1.3f",aWHIP];
	} else {
		WHIPForm = @"-1";
	}
	return WHIPForm;
}

+(NSString *)standardWHIPFormForNSNumber:(NSNumber *)aWHIPInNSNumber
{
    NSString *thousandForm = @"-1";
    CGFloat whip_real = [aWHIPInNSNumber floatValue];
    whip_real += .0005; // Round up.
    thousandForm = [NSString stringWithFormat:@"%1.3f", whip_real];
    return thousandForm;
}

//
// inningsInDecimalFormFromInningOuts:
// Use .1, .2 convention like Baseball-Reference.com, ie.
// 1 inning is 0.1, 2 innings is 0.2.
//
+(NSString *)inningsInDecimalFormFromInningOuts:(NSInteger)inning_outs {
    if (inning_outs == -1) return @"-1";
    float innings = inning_outs/(float)3;
    NSInteger whole_innings = (NSInteger)innings;
    float fractional_inning = innings - (float)whole_innings;
    NSInteger fractional_outs = 0;
    if (fractional_inning > (float)0.6) fractional_outs = 2;
        else if (fractional_inning > (float)0.3) fractional_outs = 1;
    return ([NSString stringWithFormat:@"%ld.%ld",(long)whole_innings,(long)fractional_outs]);
}

+(NSString *)largeNumberInCommaFormWithNSNumber:(NSNumber *)largeNumber {
    NSString *displayStringToReturn = @"";
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.maximumFractionDigits = 0;
    displayStringToReturn = [formatter stringFromNumber:largeNumber];
    return displayStringToReturn;
}

#pragma mark Format functions

//
// format_stat - return a number formatted as a 3 character string. Or could be NA.
//

NSString * format_stat(NSNumber *theStat,NSInteger width) {
	NSString *returnedString;
	NSInteger the_stat = [theStat integerValue];
	if (the_stat < 0)
	{
		NSString *padString = [@"" stringByPaddingToLength:width-2 withString:@" " startingAtIndex:0];
		returnedString = [NSString stringWithFormat:@"%@NA",padString];
	}
	else {
		NSString *formatString = [NSString stringWithFormat:@"%%%ldd",(long)width];
		returnedString = [NSString stringWithFormat:formatString,the_stat];
	}
	return returnedString;
}

NSString * format_stat_int(NSInteger the_stat,NSInteger width) {
	NSString *returnedString;
	if (the_stat < 0)
	{
		NSString *padString = [@"" stringByPaddingToLength:width-2 withString:@" " startingAtIndex:0];
		returnedString = [NSString stringWithFormat:@"%@NA",padString];
	}
	else {
		NSString *formatString = [NSString stringWithFormat:@"%%%ldd",(long)width];
		returnedString = [NSString stringWithFormat:formatString,the_stat];
	}
	return returnedString;
}

/*
It should be like this:
total_G = tally_with_na_check(total_G, [aBattingRecord.g integerValue])
and what tally_with_na_check should do is check that total_G and the value aren't -1. If either of them are, return -1. Else do the addition and return the sum.
Then at the end for the totals you have format_stat_int or whatever that checks for total of -1s.
*/
NSInteger tally_with_na_check(NSInteger the_total, NSNumber * yearStat) {
    NSInteger year_stat = [yearStat integerValue];
    if (the_total < 0 || year_stat < 0)
        return -1;
    return the_total + year_stat;
}

+(NSString *)percentagePaddedToFiveChars:(NSInteger)integer_percentage_value
{
	NSString *wLPercentage = [StatsFormatter averageInThousandForm:integer_percentage_value];
	if ([wLPercentage length] == 4) wLPercentage = [NSString stringWithFormat:@" %@",wLPercentage];
	return wLPercentage;
}

+(NSString *)yearStringFromDateField:(NSString *)dateField
{
    // Date formats can be: mm/dd/yyyy or yyyy-mm-dd. No particular reason why.
    NSString *yearString = nil;
    NSDateFormatter *biFormatter = [[NSDateFormatter alloc] init];
    NSDate *formatterDate;
    if (dateField) {
        [biFormatter setDateFormat:@"yyyy-MM-dd"];
        formatterDate = [biFormatter dateFromString:dateField];
        if (!formatterDate) {
            [biFormatter setDateFormat:@"MM/dd/yyyy"];
            formatterDate = [biFormatter dateFromString:dateField];
        }
        if (formatterDate) {
            [biFormatter setDateFormat:@"yyyy"];
            yearString = [biFormatter stringFromDate:formatterDate];
        }
    }
    return yearString;
}

@end
