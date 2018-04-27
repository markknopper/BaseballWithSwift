//
//  Transaction.h
//  BaseballQuery
//
//  Created by Mark Knopper on 9/18/13.
//  Copyright (c) 2013-2015 Bulbous Ventures LLC. All rights reserved.
//

@import Foundation;
@import CoreData;

@interface Transaction : NSManagedObject

@property (nonatomic, retain) NSNumber * approximatePrimary;
@property (nonatomic, retain) NSNumber * approximateSecondary;
@property (nonatomic, retain) NSNumber * draftRound;
@property (nonatomic, retain) NSString * draftType;
@property (nonatomic, retain) NSString * fromLeagueIDOrName;
@property (nonatomic, retain) NSString * fromTeamIDOrName;
@property (nonatomic, retain) NSString * info;
@property (nonatomic, retain) NSNumber * pickNumber;
@property (nonatomic, retain) NSString * playerIDOrName;
@property (nonatomic, retain) NSDate * primaryDate;
@property (nonatomic, retain) NSDate * secondaryDate;
@property (nonatomic, retain) NSString * toLeagueIDOrName;
@property (nonatomic, retain) NSString * toTeamIDOrName;
@property (nonatomic, retain) NSString * transactionID;
@property (nonatomic, retain) NSString * type;

@end
