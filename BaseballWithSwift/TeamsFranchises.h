//
//  TeamsFranchises.h
//  BaseballQuery
//
//  Created by Mark Knopper on 7/1/14.
//  Copyright (c) 2014 Bulbous Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FranchiseTotals, Teams;

@interface TeamsFranchises : NSManagedObject

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSString * franchID;
@property (nonatomic, retain) NSString * franchName;
@property (nonatomic, retain) NSString * nAassoc;
@property (nonatomic, retain) FranchiseTotals *franchiseTotals;
@property (nonatomic, retain) NSSet *teamSeasons;
@end

@interface TeamsFranchises (CoreDataGeneratedAccessors)

- (void)addTeamSeasonsObject:(Teams *)value;
- (void)removeTeamSeasonsObject:(Teams *)value;
- (void)addTeamSeasons:(NSSet *)values;
- (void)removeTeamSeasons:(NSSet *)values;

@end
