//
//  QueryResultsViewController.h
//  BaseballQuery
//
//  Created by Matthew Jones on 4/21/10.
//  Copyright 2010-2018 Bulbous Ventures LLC. All rights reserved.
//

@import UIKit;
#import "Teams.h"

@interface QueryResultsViewController : UITableViewController <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSString *sectionTitle;
@property (nonatomic, strong) NSArray *results;

// Following properties are passed in from QueryBuilderVC
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
// So variableBindings is a dictionary with key $PICK000000 having value of picked beginning year value, and $PICK000001 having value of picked ending year value.
@property (nonatomic, strong) NSDictionary *variableBindings; // variables to be substituted in the predicate
// predicates is an NSCompoundPredicate passed from QueryBuilderVC
// Predicates could be an empty array I think, but never nil.
@property (nonatomic, strong) NSCompoundPredicate *predicates; // to direct the query
@property (nonatomic, strong) NSString *statKind; // Entity name for the stat in question. Batting, Pitching, etc...
@property (nonatomic, strong) NSString *statDisplayName; // name of ranking stat
@property (nonatomic, strong) NSString *statInternalName;
@property (nonatomic, unsafe_unretained) NSNumber *resultSize; // limit number returned
@property (nonatomic, unsafe_unretained) NSNumber *sortAscending; // sort High to Low?
@property (nonatomic, strong) NSString *sectionTitleSuffix;
@property (assign) BOOL career;

-(void)dataIsReloaded:(UITableView *)offScreenTableView;

@end
