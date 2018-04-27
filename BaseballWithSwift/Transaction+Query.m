//
//  Transaction+Query.m
//  BaseballQuery
//
//  Created by Mark Knopper on 9/20/13.
//  Copyright (c) 2013-2015 Bulbous Ventures LLC. All rights reserved.
//
#import "Transaction+Query.h"
#import "RetrosheetController.h"

@implementation Transaction (Query)

-(NSString *)descriptionString
{
    NSString *descriptionToReturn = @"";
    // Remove spaces in transaction type (seems to be always 2 characters).
    NSString *transactionType = [self.type stringByReplacingOccurrencesOfString:@" " withString:@""];
    // Get year of transaction, using Gregorian calendar!
    //NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:self.primaryDate];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:self.primaryDate];

    NSString *yearID = [NSString stringWithFormat:@"%ld",(long)[components year]];
    
    NSString *fromTeamName = self.fromTeamIDOrName;
    if ([fromTeamName length]==3)
        fromTeamName = [[RetrosheetController sharedInstance] teamNameFromRetroTeamID:self.fromTeamIDOrName yearID:yearID];
    NSString *toTeamName = self.toTeamIDOrName;
    if ([toTeamName length]==3)
        toTeamName = [[RetrosheetController sharedInstance] teamNameFromRetroTeamID:self.toTeamIDOrName yearID:yearID];
    NSString *roundString = @"";
    NSInteger draft_round = 0;
    if (self.draftRound && [self.draftRound integerValue] > 0)
        roundString = [NSString stringWithFormat:@" round %ld",(long)draft_round];
    NSString *pickNumberString = @"";
    if (self.pickNumber && [self.pickNumber integerValue]>0)
        pickNumberString = [NSString stringWithFormat:@" pick number %ld",(long)[self.pickNumber integerValue]];
    if ([transactionType isEqualToString:@"A"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Assigned from %@ (%@) to %@ (%@) without compensation.",fromTeamName,self.fromLeagueIDOrName,toTeamName,self.toLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"C"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Conditional deal from %@ (%@) to %@ (%@).",fromTeamName,self.fromLeagueIDOrName,toTeamName,self.toLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"Cr"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Returned to %@ (%@) from %@ (%@) after conditional deal",fromTeamName,self.fromLeagueIDOrName,toTeamName,self.toLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"D"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Rule 5 draft pick from %@ (%@) to %@ (%@).",fromTeamName,self.fromLeagueIDOrName,toTeamName,self.toLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"Da"]) {
        NSString *secondaryDateString = [NSDateFormatter localizedStringFromDate:self.secondaryDate dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];
        if (secondaryDateString)
            descriptionToReturn = [NSString stringWithFormat:@"Picked by %@ (%@) in%@%@ of amateur draft. Player signed on %@.",toTeamName,self.toLeagueIDOrName,roundString,pickNumberString,secondaryDateString];
        else
            descriptionToReturn = [NSString stringWithFormat:@"Picked by %@ (%@) in%@%@ of amateur draft.",toTeamName,self.toLeagueIDOrName,roundString,pickNumberString];
    } else if ([transactionType isEqualToString:@"Df"]) {
        descriptionToReturn = [NSString stringWithFormat:@"First year draft pick from %@ (%@) to %@ (%@).",fromTeamName,self.fromLeagueIDOrName,toTeamName,self.toLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"Dm"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Minor league draft pick from %@ (%@) to %@ (%@).",fromTeamName,self.fromLeagueIDOrName,toTeamName,self.toLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"Dn"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Selected by %@ (%@) in amateur draft%@%@ but did not sign.",toTeamName,self.toLeagueIDOrName,roundString,pickNumberString];
    } else if ([transactionType isEqualToString:@"Dr"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Returned to %@ (%@) after draft selection.",toTeamName,self.toLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"Ds"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Special draft pick by %@ (%@).",toTeamName,self.toLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"Dv"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Amateur draft pick voided by %@ (%@).",toTeamName,self.toLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"F"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Free agent signing by %@ (%@).",toTeamName,self.toLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"Fa"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Amateur free agent signing by %@ (%@).",toTeamName,self.toLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"Fb"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Amateur free agent \"bonus baby\" signing, under the 1953-57 rule requiring player to stay on ML roster, by %@ (%@).",toTeamName,self.toLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"Fc"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Free agent compensation pick by %@ (%@).",toTeamName,self.toLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"Fg"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Free agent granted by %@ (%@).",fromTeamName,self.fromLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"Fo"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Free agent signing with first ML team by %@ (%@).",toTeamName,self.toLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"Fv"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Free agent signing by %@ (%@) voided.",toTeamName,self.toLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"J"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Jumped teams - from %@ (%@) to %@ (%@).",fromTeamName,self.fromLeagueIDOrName,toTeamName,self.toLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"Jr"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Returned to %@ (%@) after jumping teams, from %@ (%@).",toTeamName,self.toLeagueIDOrName,fromTeamName,self.fromLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"L"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Loaned to %@ (%@) from %@ (%@).",toTeamName,self.toLeagueIDOrName,fromTeamName,self.fromLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"Lr"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Returned to %@ (%@) after loan from %@ (%@).",toTeamName,self.toLeagueIDOrName,fromTeamName,self.fromLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"M"]) {
        descriptionToReturn = [NSString stringWithFormat:@"%@ (%@) obtained rights when entering into working agreement with minor league team %@ (%@).",toTeamName,self.toLeagueIDOrName,fromTeamName,self.fromLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"Mr"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Returned to %@ (%@) when working agreement with minor league team %@ (%@) ended.",fromTeamName,self.fromLeagueIDOrName,toTeamName,self.toLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"P"] || [transactionType isEqualToString:@"p"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Purchased by %@ (%@) from %@ (%@).",toTeamName,self.toLeagueIDOrName,fromTeamName,self.fromLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"Pr"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Returned to %@ (%@) after purchase.",toTeamName,self.toLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"R"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Released by %@ (%@).",fromTeamName,self.fromLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"T"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Traded from %@ (%@) to %@ (%@).",fromTeamName,self.fromLeagueIDOrName,toTeamName,self.toLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"Tn"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Traded from %@ (%@) but refused to report to %@ (%@).",fromTeamName,self.fromLeagueIDOrName,toTeamName,self.toLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"Tp"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Added to trade (usually because one of the original players refused to report or retired) - from %@ (%@) to %@ (%@).",fromTeamName,self.fromLeagueIDOrName,toTeamName,self.toLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"Tr"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Returned to %@ (%@) from %@ (%@) after trade.",toTeamName,self.toLeagueIDOrName,fromTeamName,self.fromLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"Tv"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Returned to %@ (%@) from %@ (%@) - trade voided.",toTeamName,self.toLeagueIDOrName,fromTeamName,self.fromLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"U"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Sent from %@ (%@) to %@ (%@).",fromTeamName,self.fromLeagueIDOrName,toTeamName,self.toLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"V"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Purchased or assigned to %@ (%@) from league.",toTeamName,self.toLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"Vg"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Assigned to league  control from %@ (%@).",fromTeamName,self.fromLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"W"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Waiver pick from %@ (%@) to %@ (%@).",fromTeamName,self.fromLeagueIDOrName,toTeamName,self.toLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"Wf"]) {
        descriptionToReturn = [NSString stringWithFormat:@"First year waiver pick from %@ (%@) to %@ (%@).",fromTeamName,self.fromLeagueIDOrName,toTeamName,self.toLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"Wr"]) {
        descriptionToReturn = [NSString stringWithFormat:@"returned to original team %@ (%@) after waiver pick by %@ (%@).",toTeamName,self.toLeagueIDOrName,fromTeamName,self.fromLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"Wv"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Waiver pick by %@ (%@) voided, back to %@ (%@).",fromTeamName,self.fromLeagueIDOrName,toTeamName,self.toLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"X"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Expansion draft pick number %@ by %@ (%@) from %@ (%@).",pickNumberString,fromTeamName,self.fromLeagueIDOrName,toTeamName,self.toLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"Xm"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Xm minor league? Expansion draft pick number %@ by %@ (%@) from %@ (%@).",pickNumberString,fromTeamName,self.fromLeagueIDOrName,toTeamName,self.toLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"Xp"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Added as expansion pick at a later date by %@ (%@) from %@ (%@).",toTeamName,self.toLeagueIDOrName,fromTeamName,self.fromLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"Xr"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Xr? expansion draft returned from %@ (%@) to %@ (%@).",fromTeamName,self.fromLeagueIDOrName,toTeamName,self.toLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"Z"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Voluntarily retired from %@ (%@).",fromTeamName,self.fromLeagueIDOrName];
    } else if ([transactionType isEqualToString:@"Zr"]) {
        descriptionToReturn = [NSString stringWithFormat:@"Returned from voluntarily retired list to %@ (%@).",toTeamName,self.toLeagueIDOrName];
    }
    // Add optional info
    if (self.info && [self.info length]>0)
        descriptionToReturn = [NSString stringWithFormat:@"%@ %@",descriptionToReturn, self.info];
    return descriptionToReturn;
}

-(NSFetchRequest *)fetchRequestForRelatedTransactions
{
    NSFetchRequest *relatedFetch = [NSFetchRequest new];
    NSEntityDescription *transEnt = [NSEntityDescription entityForName:@"Transaction" inManagedObjectContext:self.managedObjectContext];
    [relatedFetch setEntity:transEnt];
    NSPredicate *relatedPred = [NSPredicate predicateWithFormat:@"transactionID == %@",self.transactionID];
    [relatedFetch setPredicate:relatedPred];
    return relatedFetch;
}

/*
-(NSArray *)relatedTransactions
{
    NSError *error = nil;
    NSArray *relatedTransactionsToReturn = [self.managedObjectContext executeFetchRequest:[self fetchRequestForRelatedTransactions] error:&error];
    return relatedTransactionsToReturn;
}
*/

-(NSInteger)relatedTransactionsCount
{
    NSError *error = nil;
    return [self.managedObjectContext countForFetchRequest:[self fetchRequestForRelatedTransactions] error:&error];
}

@end
