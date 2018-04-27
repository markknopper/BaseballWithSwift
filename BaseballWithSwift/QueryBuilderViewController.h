//
//  QueryBuilderViewController.h
//  BaseballWithSwift
//
//  Created by Matthew Jones on 4/23/10.
//  Copyright 2010-2018 Bulbous Ventures LLC. All rights reserved.
//

@import  UIKit;
#import "YearPickerViewController.h"
#import "StatPickerViewController.h"

@interface QueryBuilderViewController : UIViewController <YearPickerDelegate,StatPickerViewControllerDelegate>

@property (nonatomic, strong) NSString *statKind; // the name of the Entity for the stat "Batting", "Fielding", etc...
@property (nonatomic, strong) NSDictionary *statKinds;
@property (nonatomic, strong) NSDictionary *statKindsMore;
//@property (nonatomic, strong) NSString *pickVariableName;
// So variableBindings is a dictionary with key $PICK000000 having value of picked beginning year value, and $PICK000001 having value of picked ending year value.
@property (nonatomic, strong) NSMutableDictionary *variableBindings;
@property (nonatomic, strong) NSMutableArray *queryTableContent;
@property (nonatomic, strong) NSMutableArray *originalContent;
@property (nonatomic, strong) NSMutableDictionary *originalStatSection;
@property (nonatomic, strong) NSMutableDictionary *originalFieldingPositionSection;
@property (nonatomic, strong) NSMutableArray *predicates;
// predicates is an array of strings in the Builder. But when passing to Results, it is an NSCompoundPredicate.
//@property (nonatomic, strong) NSCompoundPredicate *predicates;
@property (nonatomic, strong) NSString *statDisplayName;
@property (nonatomic, strong) NSString *statInternalName;
@property (nonatomic, strong) NSString *fieldingPositionSelected;
@property (nonatomic, strong) NSNumber *resultSize;
@property (nonatomic, strong) NSNumber *sortAscending;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) StatPickerViewController *actionStatPicker;
@property (weak, nonatomic) IBOutlet UISegmentedControl *seasonCareerChooser;

- (IBAction)tappedSeasonCareer:(id)sender;

@end
